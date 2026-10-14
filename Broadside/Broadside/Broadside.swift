import Foundation

/// Broadside role. Closed fold of Shut, Opened, Kept, and Waived for one daykey.
enum Fold: String, Codable, Sendable, Equatable {
    case shut
    case opened
    case kept
    case waived
}

/// Year grid signal. Opened still reads as Shut until Ink or Waive files the cell.
enum YearCell: String, Codable, Sendable, Equatable {
    case shut
    case kept
    case waived

    static func filed(from fold: Fold) -> YearCell {
        switch fold {
        case .shut, .opened:
            return .shut
        case .kept:
            return .kept
        case .waived:
            return .waived
        }
    }
}

struct Broadside: Codable, Sendable, Equatable, Identifiable {
    var daykey: Int
    var stockIndex: Int
    var word: String
    var quote: String
    var microAction: String
    var fold: Fold

    var id: Int { daykey }

    var yearCell: YearCell { YearCell.filed(from: fold) }

    static func shutLeaf(daykey: Int, stock: Stock) -> Broadside {
        Broadside(
            daykey: daykey,
            stockIndex: stock.index,
            word: stock.word,
            quote: stock.quote,
            microAction: stock.microAction,
            fold: .shut
        )
    }
}

enum SpreadRefusal: Error, Equatable, Sendable {
    case poolEmpty
    case alreadyOpen
    case redrawRefused
    case inkOnShut
    case blankDeed
    case peelNotToday
    case nothingToPeel
}
