import UIKit

/// Layout role. One 8pt unit, two radii, hairline elevation. Screens only use these.
enum Measure {
    static let unit: CGFloat = 8

    static var tight: CGFloat { unit }
    static var row: CGFloat { unit * 2 }
    static var band: CGFloat { unit * 3 }
    static var pad: CGFloat { unit * 4 }
    static var air: CGFloat { unit * 6 }

    /// Hero surfaces. Cards, sheets, the material page.
    static var heroRadius: CGFloat { 18 }
    /// Chips, rows, small controls.
    static var chipRadius: CGFloat { 8 }

    static let hairline: CGFloat = 1
    static let hit: CGFloat = 44
    static let pressScale: CGFloat = 0.97
    static let pressDuration: TimeInterval = 0.16
    static let flipDuration: TimeInterval = 0.16
    static let sheetScale: CGFloat = 0.96
    static let sheetDuration: TimeInterval = 0.16
}

enum Tone {
    static var bg: UIColor { ui(DesignTokens.bgHex) }
    static var surface: UIColor { ui(DesignTokens.surfaceHex) }
    static var ink: UIColor { ui(DesignTokens.inkHex) }
    static var accent: UIColor { ui(DesignTokens.accentHex) }
    static var muted: UIColor { ui(DesignTokens.mutedHex) }
    /// Ochre for a waived cell. It is not an error.
    static var waived: UIColor { UIColor(red: 0.78, green: 0.67, blue: 0.45, alpha: 1) }
    static var paper: UIColor { UIColor(red: 0.93, green: 0.91, blue: 0.86, alpha: 1) }

    private static func ui(_ hex: String) -> UIColor {
        var value: UInt64 = 0
        Scanner(string: String(hex.dropFirst())).scanHexInt64(&value)
        return UIColor(
            red: CGFloat((value >> 16) & 0xFF) / 255,
            green: CGFloat((value >> 8) & 0xFF) / 255,
            blue: CGFloat(value & 0xFF) / 255,
            alpha: 1
        )
    }
}

/// Type role. Six Hoefler steps. Display steps down when Dynamic Type would clip the word.
enum TypeScale {
    static func display(_ traits: UITraitCollection) -> UIFont {
        if traits.preferredContentSizeCategory.isAccessibilityCategory {
            return face("HoeflerText-Black", 22, textStyle: .title2, traits: traits)
        }
        return face("HoeflerText-Black", 34, textStyle: .largeTitle, traits: traits)
    }

    static func title(_ traits: UITraitCollection) -> UIFont {
        face("HoeflerText-Black", 28, textStyle: .title1, traits: traits)
    }

    static func headline(_ traits: UITraitCollection) -> UIFont {
        face("HoeflerText-Black", 22, textStyle: .title2, traits: traits)
    }

    static func body(_ traits: UITraitCollection) -> UIFont {
        face("HoeflerText-Regular", 17, textStyle: .body, traits: traits)
    }

    static func caption(_ traits: UITraitCollection) -> UIFont {
        face("HoeflerText-Italic", 15, textStyle: .subheadline, traits: traits)
    }

    static func micro(_ traits: UITraitCollection) -> UIFont {
        face("HoeflerText-Regular", 13, textStyle: .footnote, traits: traits)
    }

    private static func face(
        _ name: String,
        _ size: CGFloat,
        textStyle: UIFont.TextStyle,
        traits: UITraitCollection
    ) -> UIFont {
        let base = UIFont(name: name, size: size) ?? UIFont.systemFont(ofSize: size)
        let metrics = UIFontMetrics(forTextStyle: textStyle)
        return metrics.scaledFont(for: base, compatibleWith: traits)
    }
}

enum Figures {
    static let count: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter
    }()

    static func tally(_ value: Int) -> String {
        count.string(from: NSNumber(value: value)) ?? "0"
    }

    /// Shown dates. The stored daykey stays an Int. Grouping belongs to counts, not to a calendar day.
    static func day(_ daykey: Int) -> String {
        let year = daykey / 10_000
        let month = (daykey / 100) % 100
        let day = daykey % 100
        var parts = DateComponents()
        parts.year = year
        parts.month = month
        parts.day = day
        let calendar = Calendar.current
        guard let date = calendar.date(from: parts) else { return tally(daykey) }
        let formatter = DateFormatter()
        formatter.calendar = calendar
        formatter.locale = .current
        formatter.timeZone = calendar.timeZone
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
}
