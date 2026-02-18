import Testing
import Foundation
@testable import LNSCalendarHeatmap

struct HeatmapGridDataTests {
    // Use a fixed calendar for deterministic tests
    private var calendar: Calendar {
        var cal = Calendar(identifier: .gregorian)
        cal.firstWeekday = 1 // Sunday
        cal.timeZone = TimeZone(identifier: "UTC")!
        return cal
    }

    @Test func yearGridHasCorrectWeekCount() {
        let grid = HeatmapGridData(
            dateRange: .year(2025),
            calendar: calendar,
            referenceDate: Date.now
        )

        // 2025: Jan 1 is Wednesday. Grid should span ~53 week columns
        // (depends on exact alignment, but should be 52-54)
        #expect(grid.weeks.count >= 52)
        #expect(grid.weeks.count <= 54)
    }

    @Test func singleMonthGridIsCompact() {
        let grid = HeatmapGridData(
            dateRange: .month(year: 2025, month: 6),
            calendar: calendar,
            referenceDate: Date.now
        )

        // June 2025 has 30 days. Should be 5-6 week columns.
        #expect(grid.weeks.count >= 4)
        #expect(grid.weeks.count <= 6)
    }

    @Test func allDaysInRangeArePresent() {
        let grid = HeatmapGridData(
            dateRange: .month(year: 2025, month: 2),
            calendar: calendar,
            referenceDate: Date.now
        )

        // February 2025 has 28 days (not a leap year)
        let inRangeDays = grid.weeks.flatMap(\.days).filter(\.isInRange)
        #expect(inRangeDays.count == 28)
    }

    @Test func leapYearFebruary() {
        let grid = HeatmapGridData(
            dateRange: .month(year: 2024, month: 2),
            calendar: calendar,
            referenceDate: Date.now
        )

        // February 2024 has 29 days (leap year)
        let inRangeDays = grid.weeks.flatMap(\.days).filter(\.isInRange)
        #expect(inRangeDays.count == 29)
    }

    @Test func monthLabelsArePresent() {
        let grid = HeatmapGridData(
            dateRange: .year(2025),
            calendar: calendar,
            referenceDate: Date.now
        )

        // Should have 12 month labels for a full year
        #expect(grid.monthLabels.count == 12)
    }

    @Test func monthLabelsAreOrdered() {
        let grid = HeatmapGridData(
            dateRange: .year(2025),
            calendar: calendar,
            referenceDate: Date.now
        )

        for i in 1..<grid.monthLabels.count {
            #expect(grid.monthLabels[i].weekIndex >= grid.monthLabels[i - 1].weekIndex)
        }
    }

    @Test func dateAtValidPosition() {
        let grid = HeatmapGridData(
            dateRange: .month(year: 2025, month: 1),
            calendar: calendar,
            referenceDate: Date.now
        )

        // Jan 1, 2025 is Wednesday (weekday 4 in Gregorian, row 3 when Sunday is first)
        // It should be findable somewhere in the grid
        var found = false
        for (weekIdx, week) in grid.weeks.enumerated() {
            for (dayIdx, day) in week.days.enumerated() {
                if day.isInRange && calendar.component(.day, from: day.date) == 1 &&
                   calendar.component(.month, from: day.date) == 1 {
                    let result = grid.date(atWeek: weekIdx, day: dayIdx)
                    #expect(result != nil)
                    found = true
                }
            }
        }
        #expect(found)
    }

    @Test func outOfBoundsReturnsNil() {
        let grid = HeatmapGridData(
            dateRange: .month(year: 2025, month: 1),
            calendar: calendar,
            referenceDate: Date.now
        )

        #expect(grid.date(atWeek: -1, day: 0) == nil)
        #expect(grid.date(atWeek: 999, day: 0) == nil)
        #expect(grid.date(atWeek: 0, day: -1) == nil)
        #expect(grid.date(atWeek: 0, day: 999) == nil)
    }

    @Test func customRangeWorks() {
        var comps1 = DateComponents()
        comps1.year = 2025
        comps1.month = 3
        comps1.day = 15
        let start = calendar.date(from: comps1)!

        var comps2 = DateComponents()
        comps2.year = 2025
        comps2.month = 4
        comps2.day = 15
        let end = calendar.date(from: comps2)!

        let grid = HeatmapGridData(
            dateRange: .custom(start...end),
            calendar: calendar,
            referenceDate: Date.now
        )

        let inRangeDays = grid.weeks.flatMap(\.days).filter(\.isInRange)
        // March 15 to April 15 inclusive = 32 days
        #expect(inRangeDays.count == 32)
    }

    @Test func eachWeekHasUpTo7Days() {
        let grid = HeatmapGridData(
            dateRange: .year(2025),
            calendar: calendar,
            referenceDate: Date.now
        )

        for week in grid.weeks {
            #expect(week.days.count <= 7)
            #expect(week.days.count >= 1)
        }
    }

    @Test func weekdaySymbolsMatch() {
        let grid = HeatmapGridData(
            dateRange: .year(2025),
            calendar: calendar,
            referenceDate: Date.now
        )

        #expect(grid.weekdaySymbols.count == 7)
        // Gregorian very short symbols should include S, M, T, W, T, F, S
        #expect(grid.weekdaySymbols.first == "S") // Sunday
    }

    @Test func dateRangeResolution() {
        let range = HeatmapDateRange.year(2025).resolve(calendar: calendar)
        let startComps = calendar.dateComponents([.year, .month, .day], from: range.lowerBound)
        let endComps = calendar.dateComponents([.year, .month, .day], from: range.upperBound)

        #expect(startComps.year == 2025)
        #expect(startComps.month == 1)
        #expect(startComps.day == 1)
        #expect(endComps.year == 2025)
        #expect(endComps.month == 12)
        #expect(endComps.day == 31)
    }

    @Test func monthRangeResolution() {
        let range = HeatmapDateRange.month(year: 2025, month: 6).resolve(calendar: calendar)
        let startComps = calendar.dateComponents([.year, .month, .day], from: range.lowerBound)
        let endComps = calendar.dateComponents([.year, .month, .day], from: range.upperBound)

        #expect(startComps.year == 2025)
        #expect(startComps.month == 6)
        #expect(startComps.day == 1)
        #expect(endComps.year == 2025)
        #expect(endComps.month == 6)
        #expect(endComps.day == 30)
    }
}
