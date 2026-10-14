import Foundation

/// Stock role. One bundled leaf in the cycle. The islands slot stores these indexes in order.
struct Stock: Codable, Sendable, Equatable, Identifiable {
    var index: Int
    var word: String
    var quote: String
    var microAction: String

    var id: Int { index }
}

enum StockShelf {
    static let resourceName = "stock"

    static func load(from bundle: Bundle = .main) -> [Stock] {
        if let url = bundle.url(forResource: resourceName, withExtension: "json"),
           let data = try? Data(contentsOf: url),
           let decoded = try? JSONDecoder().decode([Stock].self, from: data),
           !decoded.isEmpty {
            return decoded.sorted { $0.index < $1.index }
        }
        return fallback
    }

    /// Used when the bundle resource is missing. Same cycle the JSON ships.
    static let fallback: [Stock] = [
        Stock(index: 0, word: "Quiet", quote: "One page is enough.", microAction: "Write one sentence about today."),
        Stock(index: 1, word: "Walk", quote: "The block counts.", microAction: "Walk around the block once."),
        Stock(index: 2, word: "Water", quote: "Fill the glass first.", microAction: "Drink one glass of water."),
        Stock(index: 3, word: "Call", quote: "A short call still counts.", microAction: "Send one message you have been holding."),
        Stock(index: 4, word: "Shelf", quote: "Put one thing back.", microAction: "Return one object to its place."),
        Stock(index: 5, word: "Name", quote: "Say who you noticed.", microAction: "Write the name of one person you appreciated."),
        Stock(index: 6, word: "Light", quote: "Open the curtain.", microAction: "Let daylight into one room."),
        Stock(index: 7, word: "Close", quote: "End one open loop.", microAction: "Finish one small task you already started.")
    ]
}
