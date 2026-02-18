import Foundation

/// Defines the date range displayed by the heatmap.
public enum HeatmapDateRange: Equatable, Sendable {
    /// A full calendar year, e.g. `.year(2025)` shows Jan 1 - Dec 31, 2025.
    case year(Int)

    /// The last 12 months ending today.
    case lastYear

    /// The last N months ending today.
    case lastMonths(Int)

    /// A single calendar month, e.g. `.month(year: 2025, month: 6)`.
    case month(year: Int, month: Int)

    /// The current calendar month.
    case currentMonth

    /// An arbitrary closed date range.
    case custom(ClosedRange<Date>)

    public static func == (lhs: HeatmapDateRange, rhs: HeatmapDateRange) -> Bool {
        switch (lhs, rhs) {
        case let (.year(a), .year(b)): return a == b
        case (.lastYear, .lastYear): return true
        case let (.lastMonths(a), .lastMonths(b)): return a == b
        case let (.month(y1, m1), .month(y2, m2)): return y1 == y2 && m1 == m2
        case (.currentMonth, .currentMonth): return true
        case let (.custom(a), .custom(b)): return a == b
        default: return false
        }
    }

    /// Resolves the range to concrete start and end dates using the given calendar and reference date.
    public func resolve(calendar: Calendar = .current, referenceDate: Date = .now) -> ClosedRange<Date> {
        switch self {
        case .year(let year):
            var start = DateComponents()
            start.year = year
            start.month = 1
            start.day = 1
            let startDate = calendar.date(from: start)!

            var end = DateComponents()
            end.year = year
            end.month = 12
            end.day = 31
            let endDate = calendar.date(from: end)!

            return startDate...endDate

        case .lastYear:
            let end = calendar.startOfDay(for: referenceDate)
            let start = calendar.date(byAdding: .month, value: -12, to: end)!
            return start...end

        case .lastMonths(let n):
            let end = calendar.startOfDay(for: referenceDate)
            let start = calendar.date(byAdding: .month, value: -n, to: end)!
            return start...end

        case .month(let year, let month):
            var start = DateComponents()
            start.year = year
            start.month = month
            start.day = 1
            let startDate = calendar.date(from: start)!

            var end = DateComponents()
            end.year = year
            end.month = month + 1
            end.day = 0 // last day of `month`
            let endDate = calendar.date(from: end)!

            return startDate...endDate

        case .currentMonth:
            let comps = calendar.dateComponents([.year, .month], from: referenceDate)
            return HeatmapDateRange.month(year: comps.year!, month: comps.month!)
                .resolve(calendar: calendar, referenceDate: referenceDate)

        case .custom(let range):
            return calendar.startOfDay(for: range.lowerBound)...calendar.startOfDay(for: range.upperBound)
        }
    }
}
