import Foundation

/// A single day cell in the heatmap grid.
public struct DayCell: Equatable, Sendable {
    /// The date this cell represents (start of day).
    public let date: Date
    /// The weekday index (1 = Sunday, 7 = Saturday in the Gregorian calendar).
    public let weekday: Int
    /// Whether this date falls within the requested range.
    public let isInRange: Bool
}

/// A column in the heatmap grid representing one week.
public struct WeekColumn: Equatable, Sendable {
    /// The day cells for this week (up to 7).
    public let days: [DayCell]
}

/// Describes where a month label should be placed.
public struct MonthLabel: Equatable, Sendable {
    /// The abbreviated month name.
    public let name: String
    /// The week column index where this label starts.
    public let weekIndex: Int
}

/// The computed grid model for a heatmap, derived from a date range and calendar.
public struct HeatmapGridData: Equatable, Sendable {
    /// The week columns that make up the grid.
    public let weeks: [WeekColumn]
    /// Month labels and their positions.
    public let monthLabels: [MonthLabel]
    /// The resolved start date of the range.
    public let startDate: Date
    /// The resolved end date of the range.
    public let endDate: Date
    /// The weekday symbols used (short).
    public let weekdaySymbols: [String]

    /// Creates grid data from a date range.
    ///
    /// - Parameters:
    ///   - dateRange: The range to display.
    ///   - calendar: The calendar to use for computation.
    ///   - referenceDate: The reference date for resolving relative ranges.
    public init(dateRange: HeatmapDateRange, calendar: Calendar = .current, referenceDate: Date = .now) {
        let resolvedRange = dateRange.resolve(calendar: calendar, referenceDate: referenceDate)
        let rangeStart = resolvedRange.lowerBound
        let rangeEnd = resolvedRange.upperBound

        self.startDate = rangeStart
        self.endDate = rangeEnd
        self.weekdaySymbols = calendar.veryShortWeekdaySymbols

        // Find the Sunday (or first day of week) of the week containing rangeStart
        let firstWeekday = calendar.firstWeekday
        var gridStart = rangeStart
        while calendar.component(.weekday, from: gridStart) != firstWeekday {
            gridStart = calendar.date(byAdding: .day, value: -1, to: gridStart)!
        }

        // Find the Saturday (or last day of week) of the week containing rangeEnd
        let lastWeekday = ((firstWeekday - 1) + 6) % 7 + 1
        var gridEnd = rangeEnd
        while calendar.component(.weekday, from: gridEnd) != lastWeekday {
            gridEnd = calendar.date(byAdding: .day, value: 1, to: gridEnd)!
        }

        // Build week columns
        var weeks: [WeekColumn] = []
        var monthLabels: [MonthLabel] = []
        var currentDate = gridStart
        var lastMonthSeen = -1

        while currentDate <= gridEnd {
            var days: [DayCell] = []
            for _ in 0..<7 {
                if currentDate > gridEnd { break }
                let weekday = calendar.component(.weekday, from: currentDate)
                let isInRange = currentDate >= rangeStart && currentDate <= rangeEnd
                days.append(DayCell(date: currentDate, weekday: weekday, isInRange: isInRange))
                currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate)!
            }

            // Check for month label placement
            // Place a label when we encounter a new month in a week that starts on or after the 1st
            for day in days where day.isInRange {
                let month = calendar.component(.month, from: day.date)
                if month != lastMonthSeen {
                    let formatter = DateFormatter()
                    formatter.calendar = calendar
                    formatter.dateFormat = "MMM"
                    let name = formatter.string(from: day.date)
                    monthLabels.append(MonthLabel(name: name, weekIndex: weeks.count))
                    lastMonthSeen = month
                    break
                }
            }

            weeks.append(WeekColumn(days: days))
        }

        self.weeks = weeks
        self.monthLabels = monthLabels
    }

    /// Returns the date at a given grid position, or nil if out of bounds.
    ///
    /// - Parameters:
    ///   - weekIndex: The week column index.
    ///   - dayIndex: The day row index (0-based from top).
    /// - Returns: The date if valid and in range, nil otherwise.
    public func date(atWeek weekIndex: Int, day dayIndex: Int) -> Date? {
        guard weekIndex >= 0, weekIndex < weeks.count else { return nil }
        let week = weeks[weekIndex]
        guard dayIndex >= 0, dayIndex < week.days.count else { return nil }
        let cell = week.days[dayIndex]
        return cell.isInRange ? cell.date : nil
    }
}
