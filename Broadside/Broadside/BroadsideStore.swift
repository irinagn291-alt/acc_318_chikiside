import Foundation
import UIKit

/// Store role. Sole writer. Views talk only to this type.
/// Memory is the source of truth. The defaults key is a projection.
@MainActor
final class BroadsideStore {
    nonisolated static let storageKey = "bsd.spread.v1"
    nonisolated static let backupKey = "bsd.spread.v1.bak"
    nonisolated static let onboardKey = "bsd.onboard.v1"
    nonisolated static let debounceNanoseconds: UInt64 = 400_000_000

    private let defaults: UserDefaults
    private let pool: [Stock]
    private var chart: SpreadChart
    private var saveTask: Task<Void, Never>?
    private var saveGeneration = 0
    private let flushWatch = FlushWatch()

    /// Set when both the chart and its backup failed to decode.
    private(set) var recoveryNote: String?
    private(set) var writeFailure: String?

    init(defaults: UserDefaults, pool: [Stock]? = nil, now: Date = Date(), calendar: Calendar = .current) {
        self.defaults = defaults
        let shelf = pool ?? StockShelf.load()
        self.pool = shelf
        let loaded = Self.loadChart(from: defaults, pool: shelf, now: now, calendar: calendar)
        self.chart = loaded.chart
        self.recoveryNote = loaded.note
        armFlushWatch()
        if loaded.dealt {
            scheduleSave()
        }
    }

    var fold: BroadsideFold { chart.fold }
    var islands: [Int] { chart.islands }
    var runs: [InkMark] { chart.runs }
    var rhumbs: [Waive] { chart.rhumbs }
    var sessions: Broadside? { chart.sessions }
    var onboardingComplete: Bool { defaults.bool(forKey: Self.onboardKey) }

    func markOnboardingComplete() {
        defaults.set(true, forKey: Self.onboardKey)
    }

    func openBroadside(on date: Date = Date(), now: Date = Date(), calendar: Calendar = .current) throws -> Broadside {
        var next = chart.fold
        let page = try next.openBroadside(on: date, pool: pool, now: now, calendar: calendar)
        commit(next)
        return page
    }

    func ink(on date: Date = Date(), deed: String, now: Date = Date(), calendar: Calendar = .current) throws -> InkMark {
        var next = chart.fold
        let mark = try next.ink(on: date, deed: deed, now: now, calendar: calendar)
        commit(next)
        return mark
    }

    func waive(on date: Date = Date(), now: Date = Date(), calendar: Calendar = .current) throws -> Waive {
        var next = chart.fold
        let record = try next.waive(on: date, now: now, calendar: calendar)
        commit(next)
        return record
    }

    /// Files today's Shut leaf from `pool[dayOrdinalInYear % count]` when that daykey is missing.
    /// A chart decoded from an earlier day does not already contain it.
    func ensureToday(now: Date = Date(), calendar: Calendar = .current) {
        var next = chart.fold
        _ = next.ensureShutToday(pool: pool, now: now, calendar: calendar)
        guard next != chart.fold else { return }
        commit(next)
    }

    func fileShut(on date: Date, calendar: Calendar = .current) {
        var next = chart.fold
        next.fileShut(on: date, pool: pool, calendar: calendar)
        commit(next)
    }

    func peel(on date: Date = Date(), today: Date = Date(), calendar: Calendar = .current) throws -> Broadside {
        var next = chart.fold
        let page = try next.peel(on: date, today: today, calendar: calendar)
        commit(next)
        return page
    }

    /// Removes the chart key and its backup. In-memory state returns to a Shut leaf for today.
    func resetAllData(now: Date = Date(), calendar: Calendar = .current) {
        saveTask?.cancel()
        saveTask = nil
        defaults.removeObject(forKey: Self.storageKey)
        defaults.removeObject(forKey: Self.backupKey)
        recoveryNote = nil
        chart = Self.freshChart(pool: pool, now: now, calendar: calendar)
    }

    /// Writes immediately. Scene resignation and destructive actions use this path.
    func flush() async {
        saveTask?.cancel()
        saveTask = nil
        saveGeneration += 1
        await writeSnapshot(chart, token: saveGeneration)
    }

    func applyDemoSeedIfNeeded(now: Date = Date(), calendar: Calendar = .current) async {
        #if targetEnvironment(simulator)
        guard !defaults.bool(forKey: DemoSeed.flagKey) else { return }
        DemoSeed.plant(into: self, now: now, calendar: calendar)
        defaults.set(true, forKey: DemoSeed.flagKey)
        await flush()
        #else
        _ = now
        _ = calendar
        #endif
    }

    private func commit(_ fold: BroadsideFold) {
        chart = SpreadChart(fold: fold, islands: pool.map(\.index))
        scheduleSave()
    }

    private func scheduleSave() {
        saveTask?.cancel()
        saveGeneration += 1
        let snapshot = chart
        let token = saveGeneration
        saveTask = Task { [weak self] in
            try? await Task.sleep(nanoseconds: Self.debounceNanoseconds)
            guard !Task.isCancelled else { return }
            await self?.writeSnapshot(snapshot, token: token)
        }
    }

    /// Encode off the main thread, then write the single key. A newer snapshot wins if this one is stale.
    private func writeSnapshot(_ snapshot: SpreadChart, token: Int) async {
        let encoded: Data
        do {
            encoded = try await Task.detached(priority: .utility) {
                try JSONEncoder().encode(snapshot)
            }.value
        } catch {
            writeFailure = "Chart encode failed."
            return
        }
        guard token == saveGeneration, !Task.isCancelled else { return }
        writeFailure = nil
        if let previous = defaults.data(forKey: Self.storageKey) {
            defaults.set(previous, forKey: Self.backupKey)
        }
        defaults.set(encoded, forKey: Self.storageKey)
    }

    private func armFlushWatch() {
        flushWatch.arm { [weak self] in
            Task { @MainActor in
                await self?.flush()
            }
        }
    }

    private static func freshChart(pool: [Stock], now: Date, calendar: Calendar) -> SpreadChart {
        var fold = BroadsideFold()
        _ = fold.ensureShutToday(pool: pool, now: now, calendar: calendar)
        return SpreadChart(fold: fold, islands: pool.map(\.index))
    }

    private static func loadChart(
        from defaults: UserDefaults,
        pool: [Stock],
        now: Date,
        calendar: Calendar
    ) -> (chart: SpreadChart, note: String?, dealt: Bool) {
        if let data = defaults.data(forKey: storageKey), let chart = decode(data) {
            let filed = filingToday(chart, pool: pool, now: now, calendar: calendar)
            return (filed.chart, nil, filed.dealt)
        }
        if defaults.data(forKey: storageKey) != nil,
           let backup = defaults.data(forKey: backupKey),
           let chart = decode(backup) {
            defaults.set(backup, forKey: storageKey)
            let filed = filingToday(chart, pool: pool, now: now, calendar: calendar)
            return (filed.chart, nil, filed.dealt)
        }
        if defaults.data(forKey: storageKey) != nil || defaults.data(forKey: backupKey) != nil {
            let chart = freshChart(pool: pool, now: now, calendar: calendar)
            return (chart, "Chart unreadable. Started a shut broadside for today.", false)
        }
        return (freshChart(pool: pool, now: now, calendar: calendar), nil, false)
    }

    /// A decoded chart keeps earlier days. Today's Shut leaf is dealt here when the daykey is absent.
    private static func filingToday(
        _ chart: SpreadChart,
        pool: [Stock],
        now: Date,
        calendar: Calendar
    ) -> (chart: SpreadChart, dealt: Bool) {
        var fold = chart.fold
        _ = fold.ensureShutToday(pool: pool, now: now, calendar: calendar)
        let dealt = fold != chart.fold
        return (SpreadChart(fold: fold, islands: chart.islands), dealt)
    }

    private static func decode(_ data: Data) -> SpreadChart? {
        try? JSONDecoder().decode(SpreadChart.self, from: data)
    }
}

/// Owns notification tokens and removes them in `deinit`.
/// The store stays `@MainActor`, so it cannot touch the token array from its own deinit.
/// `@unchecked Sendable` is safe here: `arm` runs once on the main actor before any
/// other reference exists, and `deinit` is the only later reader of `tokens`.
private final class FlushWatch: @unchecked Sendable {
    private var tokens: [any NSObjectProtocol] = []

    func arm(_ flush: @escaping @Sendable () -> Void) {
        let center = NotificationCenter.default
        let names = [
            UIApplication.willResignActiveNotification,
            UIApplication.didEnterBackgroundNotification
        ]
        for name in names {
            let token = center.addObserver(forName: name, object: nil, queue: .main) { _ in
                flush()
            }
            tokens.append(token)
        }
    }

    deinit {
        let center = NotificationCenter.default
        for token in tokens {
            center.removeObserver(token)
        }
    }
}

enum DemoSeed {
    static let flagKey = "bsd.demo.v1"

    @MainActor
    static func plant(into store: BroadsideStore, now: Date, calendar: Calendar) {
        store.markOnboardingComplete()
        let today = calendar.startOfDay(for: now)
        for offset in 1...4 {
            guard let day = calendar.date(byAdding: .day, value: -offset, to: today) else { continue }
            if let opened = try? store.openBroadside(on: day, now: now, calendar: calendar) {
                _ = try? store.ink(on: day, deed: opened.microAction, now: now, calendar: calendar)
            }
        }
        if let waivedDay = calendar.date(byAdding: .day, value: -5, to: today) {
            _ = try? store.openBroadside(on: waivedDay, now: now, calendar: calendar)
            _ = try? store.waive(on: waivedDay, now: now, calendar: calendar)
        }
        if let shutDay = calendar.date(byAdding: .day, value: -6, to: today) {
            store.fileShut(on: shutDay, calendar: calendar)
        }
        _ = try? store.openBroadside(on: today, now: now, calendar: calendar)
    }
}
