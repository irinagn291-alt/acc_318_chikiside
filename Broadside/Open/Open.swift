import Foundation

/// Open role. Records that a daykey was dealt face-up. A second open on that daykey is refused.
struct Open: Codable, Sendable, Equatable, Identifiable {
    var daykey: Int
    var stockIndex: Int

    var id: Int { daykey }
}
