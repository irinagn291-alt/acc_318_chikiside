import XCTest
@testable import Broadside

@MainActor
final class BroadsideTests: XCTestCase {
    private var calendar: Calendar!

    override func setUp() {
        super.setUp()
        var gregorian = Calendar(identifier: .gregorian)
        gregorian.timeZone = TimeZone(secondsFromGMT: 0) ?? TimeZone.gmt
        calendar = gregorian
    }

    private func date(_ year: Int, _ month: Int, _ day: Int) -> Date {
        var parts = DateComponents()
        parts.year = year
        parts.month = month
        parts.day = day
        parts.hour = 12
        return calendar.date(from: parts) ?? Date(timeIntervalSince1970: 0)
    }

    private func makeStore() throws -> (BroadsideStore, UserDefaults, String) {
        let name = "bsd.test." + UUID().uuidString
        guard let defaults = UserDefaults(suiteName: name) else {
            XCTFail("Private suite unavailable")
            return (BroadsideStore(defaults: UserDefaults()), UserDefaults.standard, name)
        }
        defaults.removePersistentDomain(forName: name)
        let store = BroadsideStore(defaults: defaults, pool: StockShelf.fallback, now: date(2026, 3, 15), calendar: calendar)
        return (store, defaults, name)
    }

    func testLeafIsOrdinalModuloPoolCount() {
        let pool = StockShelf.fallback
        let day = date(2026, 3, 15)
        let ordinal = Daykey.dayOrdinalInYear(for: day, calendar: calendar)
        XCTAssertEqual(ordinal, 31 + 28 + 15)
        let index = Daykey.leafIndex(dayOrdinalInYear: ordinal, count: pool.count)
        XCTAssertEqual(index, ordinal % pool.count)
        let leaf = BroadsideFold.leaf(on: day, pool: pool, calendar: calendar)
        XCTAssertEqual(leaf?.index, index)
        XCTAssertEqual(leaf?.word, "Water")
    }

    func testWrapUsesTheSameLeafAfterAFullCycle() {
        let pool = StockShelf.fallback
        let first = date(2026, 3, 15)
        let wrapped = calendar.date(byAdding: .day, value: pool.count, to: calendar.startOfDay(for: first)) ?? first
        let left = BroadsideFold.leaf(on: first, pool: pool, calendar: calendar)
        let right = BroadsideFold.leaf(on: wrapped, pool: pool, calendar: calendar)
        XCTAssertEqual(left?.index, right?.index)
        let again = BroadsideFold.leaf(on: first, pool: pool, calendar: calendar)
        XCTAssertEqual(left, again)
    }

    func testInkOnShutIsRefusedAndOpenThenInkFilesKept() throws {
        var fold = BroadsideFold()
        let today = date(2026, 3, 15)
        _ = fold.ensureShutToday(pool: StockShelf.fallback, now: today, calendar: calendar)
        XCTAssertThrowsError(try fold.ink(on: today, deed: "Wrote the sentence.", now: today, calendar: calendar)) { error in
            XCTAssertEqual(error as? SpreadRefusal, .inkOnShut)
        }
        XCTAssertThrowsError(try fold.ink(on: today, deed: "   ", now: today, calendar: calendar)) { error in
            XCTAssertEqual(error as? SpreadRefusal, .blankDeed)
        }
        let opened = try fold.openBroadside(on: today, pool: StockShelf.fallback, now: today, calendar: calendar)
        XCTAssertEqual(opened.fold, .opened)
        XCTAssertEqual(fold.yearCell(on: opened.daykey), .shut)
        let mark = try fold.ink(on: today, deed: "Wrote the sentence.", now: today, calendar: calendar)
        XCTAssertEqual(mark.deed, "Wrote the sentence.")
        XCTAssertEqual(fold.yearCell(on: opened.daykey), .kept)
        XCTAssertEqual(fold.runs.count, 1)
    }

    func testSecondOpenAndRedrawAreRefused() throws {
        var fold = BroadsideFold()
        let today = date(2026, 3, 15)
        _ = try fold.openBroadside(on: today, pool: StockShelf.fallback, now: today, calendar: calendar)
        XCTAssertThrowsError(try fold.openBroadside(on: today, pool: StockShelf.fallback, now: today, calendar: calendar)) { error in
            XCTAssertEqual(error as? SpreadRefusal, .alreadyOpen)
        }
        let key = Daykey.make(from: today, calendar: calendar)
        var redrawn = BroadsideFold()
        let foreign = Stock(index: 99, word: "Other", quote: "No.", microAction: "Skip.")
        redrawn.books[key] = Broadside.shutLeaf(daykey: key, stock: foreign)
        XCTAssertThrowsError(try redrawn.openBroadside(on: today, pool: StockShelf.fallback, now: today, calendar: calendar)) { error in
            XCTAssertEqual(error as? SpreadRefusal, .redrawRefused)
        }
    }

    func testWaiveLeavesAnEmptyCellAndPeelRestoresOpened() throws {
        var fold = BroadsideFold()
        let today = date(2026, 3, 15)
        _ = try fold.openBroadside(on: today, pool: StockShelf.fallback, now: today, calendar: calendar)
        _ = try fold.waive(on: today, now: today, calendar: calendar)
        XCTAssertEqual(fold.yearCell(on: Daykey.make(from: today, calendar: calendar)), .waived)
        XCTAssertTrue(fold.runs.isEmpty)
        let peeled = try fold.peel(on: today, today: today, calendar: calendar)
        XCTAssertEqual(peeled.fold, .opened)
        XCTAssertEqual(fold.yearCell(on: peeled.daykey), .shut)
        XCTAssertTrue(fold.rhumbs.isEmpty)
        let yesterday = date(2026, 3, 14)
        _ = try fold.openBroadside(on: yesterday, pool: StockShelf.fallback, now: today, calendar: calendar)
        _ = try fold.ink(on: yesterday, deed: "Walked.", now: today, calendar: calendar)
        XCTAssertThrowsError(try fold.peel(on: yesterday, today: today, calendar: calendar)) { error in
            XCTAssertEqual(error as? SpreadRefusal, .peelNotToday)
        }
    }

    func testYearIsTheFoldOverBroadsides() throws {
        var fold = BroadsideFold()
        let today = date(2026, 3, 15)
        let opened = try fold.openBroadside(on: today, pool: StockShelf.fallback, now: today, calendar: calendar)
        XCTAssertEqual(fold.books[opened.daykey]?.fold, .opened)
        XCTAssertEqual(YearCell.filed(from: .opened), .shut)
        _ = try fold.ink(on: today, deed: "Named someone.", now: today, calendar: calendar)
        XCTAssertEqual(fold.books[opened.daykey]?.fold, .kept)
        let page = try fold.peel(on: today, today: today, calendar: calendar)
        XCTAssertEqual(page.fold, .opened)
        XCTAssertNil(fold.runs.first { $0.daykey == opened.daykey })
    }

    func testChartRoundTripAndCorruptBackup() async throws {
        let (store, defaults, name) = try makeStore()
        defer { defaults.removePersistentDomain(forName: name) }
        let today = date(2026, 3, 15)
        _ = try store.openBroadside(on: today, now: today, calendar: calendar)
        await store.flush()
        _ = try store.ink(on: today, deed: "Closed one loop.", now: today, calendar: calendar)
        await store.flush()
        await store.flush()
        let reloaded = BroadsideStore(defaults: defaults, pool: StockShelf.fallback, now: today, calendar: calendar)
        XCTAssertEqual(reloaded.runs.count, 1)
        XCTAssertEqual(reloaded.runs.first?.deed, "Closed one loop.")
        XCTAssertEqual(reloaded.sessions?.fold, .kept)
        XCTAssertNotNil(defaults.data(forKey: BroadsideStore.backupKey))

        let backup = defaults.data(forKey: BroadsideStore.storageKey)
        defaults.set(Data("not-json".utf8), forKey: BroadsideStore.storageKey)
        let restored = BroadsideStore(defaults: defaults, pool: StockShelf.fallback, now: today, calendar: calendar)
        XCTAssertEqual(restored.runs.first?.deed, "Closed one loop.")
        XCTAssertNil(restored.recoveryNote)

        defaults.set(Data("still-bad".utf8), forKey: BroadsideStore.storageKey)
        defaults.set(Data("also-bad".utf8), forKey: BroadsideStore.backupKey)
        let shut = BroadsideStore(defaults: defaults, pool: StockShelf.fallback, now: today, calendar: calendar)
        XCTAssertEqual(shut.sessions?.fold, .shut)
        XCTAssertNotNil(shut.recoveryNote)
        _ = backup
    }

    func testLaterDayReloadDealsTodaysShutLeaf() async throws {
        let (store, defaults, name) = try makeStore()
        defer { defaults.removePersistentDomain(forName: name) }
        let first = date(2026, 3, 15)
        _ = try store.openBroadside(on: first, now: first, calendar: calendar)
        _ = try store.ink(on: first, deed: "Closed one loop.", now: first, calendar: calendar)
        await store.flush()
        let next = date(2026, 3, 16)
        let later = BroadsideStore(defaults: defaults, pool: StockShelf.fallback, now: next, calendar: calendar)
        let key = Daykey.make(from: next, calendar: calendar)
        let dealt = later.fold.broadside(on: key)
        let stock = BroadsideFold.leaf(on: next, pool: StockShelf.fallback, calendar: calendar)
        XCTAssertEqual(dealt?.fold, .shut)
        XCTAssertEqual(dealt?.stockIndex, stock?.index)
        XCTAssertEqual(later.sessions?.daykey, key)
        XCTAssertEqual(later.sessions?.fold, .shut)
        XCTAssertEqual(later.fold.broadside(on: Daykey.make(from: first, calendar: calendar))?.fold, .kept)
        later.ensureToday(now: next, calendar: calendar)
        XCTAssertEqual(later.fold.books.count, 2)
    }

    func testBackupRestoreOnALaterDayDealsTodaysShutLeaf() async throws {
        let (store, defaults, name) = try makeStore()
        defer { defaults.removePersistentDomain(forName: name) }
        let first = date(2026, 3, 15)
        _ = try store.openBroadside(on: first, now: first, calendar: calendar)
        await store.flush()
        let saved = defaults.data(forKey: BroadsideStore.storageKey)
        defaults.set(saved, forKey: BroadsideStore.backupKey)
        defaults.set(Data("not-json".utf8), forKey: BroadsideStore.storageKey)
        let next = date(2026, 3, 16)
        let later = BroadsideStore(defaults: defaults, pool: StockShelf.fallback, now: next, calendar: calendar)
        let key = Daykey.make(from: next, calendar: calendar)
        XCTAssertNil(later.recoveryNote)
        XCTAssertEqual(later.sessions?.daykey, key)
        XCTAssertEqual(later.sessions?.fold, .shut)
        XCTAssertEqual(later.fold.broadside(on: key)?.stockIndex, BroadsideFold.leaf(on: next, pool: StockShelf.fallback, calendar: calendar)?.index)
        XCTAssertEqual(later.fold.broadside(on: Daykey.make(from: first, calendar: calendar))?.fold, .opened)
    }

    func testResetRemovesBothKeys() async throws {
        let (store, defaults, name) = try makeStore()
        defer { defaults.removePersistentDomain(forName: name) }
        let today = date(2026, 3, 15)
        _ = try store.openBroadside(on: today, now: today, calendar: calendar)
        await store.flush()
        XCTAssertNotNil(defaults.data(forKey: BroadsideStore.storageKey))
        store.resetAllData(now: today, calendar: calendar)
        XCTAssertNil(defaults.data(forKey: BroadsideStore.storageKey))
        XCTAssertNil(defaults.data(forKey: BroadsideStore.backupKey))
        XCTAssertEqual(store.sessions?.fold, .shut)
    }

    #if targetEnvironment(simulator)
    func testDemoSeedOpensTodayAndFilesFourMarks() async throws {
        let (store, defaults, name) = try makeStore()
        defer { defaults.removePersistentDomain(forName: name) }
        let today = date(2026, 3, 15)
        await store.applyDemoSeedIfNeeded(now: today, calendar: calendar)
        XCTAssertTrue(store.onboardingComplete)
        XCTAssertEqual(store.runs.count, 4)
        XCTAssertEqual(store.sessions?.fold, .opened)
        XCTAssertFalse(store.rhumbs.isEmpty)
        let shutKey = Daykey.make(from: date(2026, 3, 9), calendar: calendar)
        XCTAssertEqual(store.fold.yearCell(on: shutKey), .shut)
        let keptCells = store.fold.books.values.filter { $0.yearCell == .kept }
        let waivedCells = store.fold.books.values.filter { $0.yearCell == .waived }
        XCTAssertEqual(keptCells.count, 4)
        XCTAssertEqual(waivedCells.count, 1)
        await store.applyDemoSeedIfNeeded(now: today, calendar: calendar)
        XCTAssertEqual(store.runs.count, 4)
    }
    #endif

    func testReviewLaunchParsesScreenArgument() {
        XCTAssertEqual(ReviewLaunch.screen(in: ["Broadside", "-ReviewScreen", "today"]), "today")
        XCTAssertEqual(ReviewLaunch.screen(in: ["Broadside", "-ReviewScreen", "log"]), "log")
        XCTAssertEqual(ReviewLaunch.screen(in: ["Broadside", "-ReviewScreen", "goals"]), "goals")
        XCTAssertNil(ReviewLaunch.screen(in: ["Broadside"]))
        XCTAssertNil(ReviewLaunch.screen(in: ["Broadside", "-ReviewScreen"]))
    }

    func testSchemaRejectsUnknownVersion() throws {
        let payload = #"{"schemaVersion":9,"islands":[],"books":[],"runs":[],"rhumbs":[]}"#
        XCTAssertThrowsError(try JSONDecoder().decode(SpreadChart.self, from: Data(payload.utf8)))
    }
}
