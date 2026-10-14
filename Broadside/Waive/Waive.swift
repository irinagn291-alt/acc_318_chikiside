import Foundation

/// Waive role. Skips the day without a deed and without a streak penalty.
struct Waive: Codable, Sendable, Equatable, Identifiable {
    var id: UUID
    var daykey: Int

    init(id: UUID = UUID(), daykey: Int) {
        self.id = id
        self.daykey = daykey
    }
}
