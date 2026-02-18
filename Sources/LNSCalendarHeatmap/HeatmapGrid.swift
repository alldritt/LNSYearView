import SwiftUI

/// The Canvas-based grid rendering view for the heatmap.
struct HeatmapGrid: View {
    let gridData: HeatmapGridData
    let colorForDate: (Date) -> Color
    let selectedDate: Date?
    let onDateTapped: ((Date) -> Void)?

    @Environment(\.heatmapStyle) private var style
    @Environment(\.calendar) private var calendar

    private var cellStep: CGFloat {
        style.cellSize + style.cellSpacing
    }

    private var weekdayLabelWidth: CGFloat {
        style.showWeekdayLabels ? 24 : 0
    }

    private var monthLabelHeight: CGFloat {
        style.showMonthLabels ? 16 : 0
    }

    private var gridWidth: CGFloat {
        weekdayLabelWidth + CGFloat(gridData.weeks.count) * cellStep
    }

    private var gridHeight: CGFloat {
        monthLabelHeight + 7 * cellStep
    }

    var body: some View {
        Canvas { context, size in
            drawMonthLabels(context: &context)
            drawWeekdayLabels(context: &context)
            drawCells(context: &context)
            drawSelection(context: &context)
        }
        .frame(width: gridWidth, height: gridHeight)
        .contentShape(Rectangle())
        .gesture(
            SpatialTapGesture()
                .onEnded { value in
                    if let date = dateAtPoint(value.location) {
                        onDateTapped?(date)
                    }
                }
        )
    }

    // MARK: - Drawing

    private func drawMonthLabels(context: inout GraphicsContext) {
        guard style.showMonthLabels else { return }

        for label in gridData.monthLabels {
            let x = weekdayLabelWidth + CGFloat(label.weekIndex) * cellStep
            let text = Text(label.name)
                .font(.system(size: 10))
                .foregroundStyle(style.monthLabelColor)
            context.draw(text, at: CGPoint(x: x, y: monthLabelHeight / 2), anchor: .leading)
        }
    }

    private func drawWeekdayLabels(context: inout GraphicsContext) {
        guard style.showWeekdayLabels else { return }

        let symbols = gridData.weekdaySymbols
        // Reorder symbols based on calendar's firstWeekday
        let firstWeekday = calendar.firstWeekday
        for row in 0..<7 {
            let symbolIndex = (firstWeekday - 1 + row) % 7
            // Only show Mon/Wed/Fri (rows 1, 3, 5 when starting Sunday)
            guard row % 2 == 1 else { continue }
            let y = monthLabelHeight + CGFloat(row) * cellStep + style.cellSize / 2
            let text = Text(symbols[symbolIndex])
                .font(.system(size: 9))
                .foregroundStyle(style.weekdayLabelColor)
            context.draw(text, at: CGPoint(x: weekdayLabelWidth - 4, y: y), anchor: .trailing)
        }
    }

    private func drawCells(context: inout GraphicsContext) {
        let firstWeekday = calendar.firstWeekday

        for (weekIndex, week) in gridData.weeks.enumerated() {
            for day in week.days {
                let row = (day.weekday - firstWeekday + 7) % 7
                let x = weekdayLabelWidth + CGFloat(weekIndex) * cellStep
                let y = monthLabelHeight + CGFloat(row) * cellStep
                let rect = CGRect(x: x, y: y, width: style.cellSize, height: style.cellSize)
                let roundedRect = RoundedRectangle(cornerRadius: style.cellCornerRadius)
                let path = roundedRect.path(in: rect)

                let color = day.isInRange ? colorForDate(day.date) : style.defaultCellColor.opacity(0.3)
                context.fill(path, with: .color(color))

                if style.cellBorderWidth > 0 {
                    context.stroke(path, with: .color(style.cellBorderColor), lineWidth: style.cellBorderWidth)
                }
            }
        }
    }

    private func drawSelection(context: inout GraphicsContext) {
        guard let selectedDate else { return }
        let firstWeekday = calendar.firstWeekday

        for (weekIndex, week) in gridData.weeks.enumerated() {
            for day in week.days {
                guard day.isInRange, calendar.isDate(day.date, inSameDayAs: selectedDate) else { continue }
                let row = (day.weekday - firstWeekday + 7) % 7
                let x = weekdayLabelWidth + CGFloat(weekIndex) * cellStep
                let y = monthLabelHeight + CGFloat(row) * cellStep
                let inset: CGFloat = -1.5
                let rect = CGRect(x: x + inset, y: y + inset,
                                  width: style.cellSize - 2 * inset,
                                  height: style.cellSize - 2 * inset)
                let roundedRect = RoundedRectangle(cornerRadius: style.cellCornerRadius + 1)
                let path = roundedRect.path(in: rect)
                context.stroke(path, with: .color(.primary), lineWidth: 2)
                return
            }
        }
    }

    // MARK: - Hit Testing

    private func dateAtPoint(_ point: CGPoint) -> Date? {
        let col = Int((point.x - weekdayLabelWidth) / cellStep)
        let row = Int((point.y - monthLabelHeight) / cellStep)
        guard col >= 0, col < gridData.weeks.count, row >= 0, row < 7 else { return nil }

        let firstWeekday = calendar.firstWeekday
        let targetWeekday = (firstWeekday + row - 1) % 7 + 1

        let week = gridData.weeks[col]
        for day in week.days {
            if day.weekday == targetWeekday && day.isInRange {
                return day.date
            }
        }
        return nil
    }
}
