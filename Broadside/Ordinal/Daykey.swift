import Foundation

/// Ordinal role. Day boundaries come from `Calendar.startOfDay`.
/// The leaf index is `dayOrdinalInYear % poolCount` and does not reshuffle.
enum Daykey {
    static func make(from date: Date, calendar: Calendar = .current) -> Int {
        let start = calendar.startOfDay(for: date)
        let parts = calendar.dateComponents([.year, .month, .day], from: start)
        let year = parts.year ?? 0
        let month = parts.month ?? 0
        let day = parts.day ?? 0
        return year * 10_000 + month * 100 + day
    }

    static func dayOrdinalInYear(for date: Date, calendar: Calendar = .current) -> Int {
        let start = calendar.startOfDay(for: date)
        return calendar.ordinality(of: .day, in: .year, for: start) ?? 1
    }

    /// `pool[dayOrdinalInYear % count]`. Wrap happens only when the ordinal passes a full cycle.
    static func leafIndex(dayOrdinalInYear: Int, count: Int) -> Int {
        guard count > 0 else { return 0 }
        let remainder = dayOrdinalInYear % count
        return remainder >= 0 ? remainder : remainder + count
    }

    static func date(from daykey: Int, calendar: Calendar = .current) -> Date? {
        let year = daykey / 10_000
        let month = (daykey / 100) % 100
        let day = daykey % 100
        var parts = DateComponents()
        parts.year = year
        parts.month = month
        parts.day = day
        guard let date = calendar.date(from: parts) else { return nil }
        return calendar.startOfDay(for: date)
    }
}
