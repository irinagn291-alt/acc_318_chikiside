import Foundation

/// Chart root. One Codable record: islands, books, sessions, runs, rhumbs.
/// `schemaVersion` starts at 1. The decoder switches on that field.
struct SpreadChart: Codable, Sendable, Equatable {
    static let currentSchema = 1

    var schemaVersion: Int
    var islands: [Int]
    var books: [Int: Broadside]
    var sessions: Broadside?
    var runs: [InkMark]
    var rhumbs: [Waive]

    init(
        schemaVersion: Int = SpreadChart.currentSchema,
        islands: [Int] = [],
        books: [Int: Broadside] = [:],
        sessions: Broadside? = nil,
        runs: [InkMark] = [],
        rhumbs: [Waive] = []
    ) {
        self.schemaVersion = schemaVersion
        self.islands = islands
        self.books = books
        self.sessions = sessions
        self.runs = runs
        self.rhumbs = rhumbs
    }

    init(fold: BroadsideFold, islands: [Int]) {
        self.init(
            islands: islands,
            books: fold.books,
            sessions: fold.sessions,
            runs: fold.runs,
            rhumbs: fold.rhumbs
        )
    }

    var fold: BroadsideFold {
        BroadsideFold(books: books, runs: runs, rhumbs: rhumbs, sessions: sessions)
    }

    enum CodingKeys: String, CodingKey {
        case schemaVersion
        case islands
        case books
        case sessions
        case runs
        case rhumbs
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let version = try container.decode(Int.self, forKey: .schemaVersion)
        switch version {
        case 1:
            schemaVersion = version
            islands = try container.decodeIfPresent([Int].self, forKey: .islands) ?? []
            let listed = try container.decodeIfPresent([Broadside].self, forKey: .books) ?? []
            var keyed: [Int: Broadside] = [:]
            for page in listed {
                keyed[page.daykey] = page
            }
            books = keyed
            sessions = try container.decodeIfPresent(Broadside.self, forKey: .sessions)
            runs = try container.decodeIfPresent([InkMark].self, forKey: .runs) ?? []
            rhumbs = try container.decodeIfPresent([Waive].self, forKey: .rhumbs) ?? []
        default:
            throw DecodingError.dataCorruptedError(
                forKey: .schemaVersion,
                in: container,
                debugDescription: "Unsupported chart schema \(version)."
            )
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(schemaVersion, forKey: .schemaVersion)
        try container.encode(islands, forKey: .islands)
        let listed = books.values.sorted { $0.daykey < $1.daykey }
        try container.encode(listed, forKey: .books)
        try container.encodeIfPresent(sessions, forKey: .sessions)
        try container.encode(runs, forKey: .runs)
        try container.encode(rhumbs, forKey: .rhumbs)
    }
}
