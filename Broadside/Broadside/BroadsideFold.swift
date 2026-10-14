import Foundation
import NaturalLanguage

/// Fold role. The year is this same fold keyed by YYYYMMDD.
/// Open writes Opened from `pool[dayOrdinalInYear % count]`.
/// Ink writes an InkMark and files Kept. Waive files Waived.
/// Peel returns today's mark to Opened. A second Open on the same daykey is refused.
struct BroadsideFold: Sendable, Equatable {
    var books: [Int: Broadside]
    var runs: [InkMark]
    var rhumbs: [Waive]
    var sessions: Broadside?

    init(
        books: [Int: Broadside] = [:],
        runs: [InkMark] = [],
        rhumbs: [Waive] = [],
        sessions: Broadside? = nil
    ) {
        self.books = books
        self.runs = runs
        self.rhumbs = rhumbs
        self.sessions = sessions
    }

    static func leaf(on date: Date, pool: [Stock], calendar: Calendar = .current) -> Stock? {
        guard !pool.isEmpty else { return nil }
        let ordinal = Daykey.dayOrdinalInYear(for: date, calendar: calendar)
        let index = Daykey.leafIndex(dayOrdinalInYear: ordinal, count: pool.count)
        if let match = pool.first(where: { $0.index == index }) {
            return match
        }
        return pool[index % pool.count]
    }

    func broadside(on daykey: Int) -> Broadside? {
        books[daykey]
    }

    func yearCell(on daykey: Int) -> YearCell {
        guard let page = books[daykey] else { return .shut }
        return page.yearCell
    }

    mutating func openBroadside(
        on date: Date,
        pool: [Stock],
        now: Date = Date(),
        calendar: Calendar = .current
    ) throws -> Broadside {
        guard let stock = Self.leaf(on: date, pool: pool, calendar: calendar) else {
            throw SpreadRefusal.poolEmpty
        }
        let key = Daykey.make(from: date, calendar: calendar)
        let page: Broadside
        if let existing = books[key] {
            if existing.stockIndex != stock.index {
                throw SpreadRefusal.redrawRefused
            }
            if existing.fold != .shut {
                throw SpreadRefusal.alreadyOpen
            }
            var opened = existing
            opened.fold = .opened
            page = opened
        } else {
            var opened = Broadside.shutLeaf(daykey: key, stock: stock)
            opened.fold = .opened
            page = opened
        }
        books[key] = page
        if key == Daykey.make(from: now, calendar: calendar) {
            sessions = page
        }
        return page
    }

    mutating func ink(
        on date: Date,
        deed: String,
        now: Date = Date(),
        calendar: Calendar = .current
    ) throws -> InkMark {
        let trimmed = deed.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { throw SpreadRefusal.blankDeed }
        let key = Daykey.make(from: date, calendar: calendar)
        guard var page = books[key], page.fold != .shut else {
            throw SpreadRefusal.inkOnShut
        }
        guard page.fold == .opened else { throw SpreadRefusal.alreadyOpen }
        page.fold = .kept
        books[key] = page
        let mark = InkMark(
            id: UUID(),
            daykey: key,
            stockIndex: page.stockIndex,
            word: page.word,
            quote: page.quote,
            deed: trimmed
        )
        runs.append(mark)
        if key == Daykey.make(from: now, calendar: calendar) {
            sessions = page
        }
        return mark
    }

    mutating func waive(on date: Date, now: Date = Date(), calendar: Calendar = .current) throws -> Waive {
        let key = Daykey.make(from: date, calendar: calendar)
        guard var page = books[key], page.fold == .opened else {
            throw SpreadRefusal.inkOnShut
        }
        page.fold = .waived
        books[key] = page
        let record = Waive(daykey: key)
        rhumbs.append(record)
        if key == Daykey.make(from: now, calendar: calendar) {
            sessions = page
        }
        return record
    }

    mutating func peel(on date: Date, today: Date, calendar: Calendar = .current) throws -> Broadside {
        let key = Daykey.make(from: date, calendar: calendar)
        let todayKey = Daykey.make(from: today, calendar: calendar)
        guard key == todayKey else { throw SpreadRefusal.peelNotToday }
        guard var page = books[key] else { throw SpreadRefusal.nothingToPeel }
        switch page.fold {
        case .kept:
            runs.removeAll { $0.daykey == key }
        case .waived:
            rhumbs.removeAll { $0.daykey == key }
        case .opened, .shut:
            throw SpreadRefusal.nothingToPeel
        }
        page.fold = .opened
        books[key] = page
        sessions = page
        return page
    }

    /// A day that was dealt and left face-down. Does not open it.
    mutating func fileShut(on date: Date, pool: [Stock], calendar: Calendar = .current) {
        let key = Daykey.make(from: date, calendar: calendar)
        guard books[key] == nil, let stock = Self.leaf(on: date, pool: pool, calendar: calendar) else { return }
        books[key] = Broadside.shutLeaf(daykey: key, stock: stock)
    }

    /// Midnight deal. Today's leaf stays Shut until Open.
    mutating func ensureShutToday(pool: [Stock], now: Date = Date(), calendar: Calendar = .current) -> Broadside? {
        guard let stock = Self.leaf(on: now, pool: pool, calendar: calendar) else { return nil }
        let key = Daykey.make(from: now, calendar: calendar)
        if books[key] == nil {
            books[key] = Broadside.shutLeaf(daykey: key, stock: stock)
        }
        sessions = books[key]
        return sessions
    }

    /// Kept days in a run that reaches `date`. Waive bridges the run. A past Shut day ends it.
    /// Today still Shut or Opened does not cut yesterday's run.
    func cadence(ending date: Date, calendar: Calendar = .current) -> Int {
        var streak = 0
        var cursor = calendar.startOfDay(for: date)
        var today = true
        for _ in 0..<400 {
            let key = Daykey.make(from: cursor, calendar: calendar)
            let fold = books[key]?.fold
            switch fold {
            case .kept:
                streak += 1
            case .waived:
                break
            case .opened, .shut, .none:
                if today == false { return streak }
            }
            today = false
            guard let prior = calendar.date(byAdding: .day, value: -1, to: cursor) else { return streak }
            cursor = prior
        }
        return streak
    }
}

enum ImprintKind: String, Sendable, Equatable {
    case direct
    case measured
    case reflective
}

struct ImprintReading: Sendable, Equatable {
    var kind: ImprintKind
    var words: Int
    var kinship: Bool

    var line: String {
        let kin = kinship ? "Kin to the word." : "Apart from the word."
        let name: String
        switch kind {
        case .direct: name = "Direct"
        case .measured: name = "Measured"
        case .reflective: name = "Reflective"
        }
        return "\(name). \(words) words. \(kin)"
    }
}

/// On-device reading of the inked line. Sentiment plus a small deed lexicon.
enum ImprintPulse {
    private static let practical = ["walk", "call", "write", "wash", "water", "shelf", "name", "light", "close", "send", "open", "ink"]
    private static let reflective = ["feel", "remember", "wonder", "quiet", "dream", "wish", "miss", "thought"]

    static func read(deed: String, dayWord: String) -> ImprintReading {
        let trimmed = deed.trimmingCharacters(in: .whitespacesAndNewlines)
        let words = trimmed.split { $0.isWhitespace || $0.isNewline }
        guard words.isEmpty == false else {
            return ImprintReading(kind: .measured, words: 0, kinship: false)
        }
        let tagger = NLTagger(tagSchemes: [.sentimentScore])
        tagger.string = trimmed
        var score = 0.0
        tagger.enumerateTags(
            in: trimmed.startIndex..<trimmed.endIndex,
            unit: .paragraph,
            scheme: .sentimentScore
        ) { tag, _ in
            if let tag, let value = Double(tag.rawValue) {
                score = value
            }
            return false
        }
        let lower = trimmed.lowercased()
        let practicalHits = practical.filter { lower.contains($0) }.count
        let reflectiveHits = reflective.filter { lower.contains($0) }.count
        let kind: ImprintKind
        if practicalHits > reflectiveHits {
            kind = .direct
        } else if reflectiveHits > practicalHits || score < -0.15 {
            kind = .reflective
        } else {
            kind = .measured
        }
        let kinship = dayWord.isEmpty == false && lower.contains(dayWord.lowercased())
        return ImprintReading(kind: kind, words: words.count, kinship: kinship)
    }
}
