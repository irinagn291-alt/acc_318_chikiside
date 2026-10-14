import Foundation

/// InkMark role. The kept deed for one daykey. Collection counts these records.
struct InkMark: Codable, Sendable, Equatable, Identifiable {
    var id: UUID
    var daykey: Int
    var stockIndex: Int
    var word: String
    var quote: String
    var deed: String
}
