import SwiftUI

// MARK: - Environment Keys for Title and Selection

struct HeatmapTitleKey: EnvironmentKey {
    static let defaultValue: String? = nil
}

struct HeatmapSelectionKey: EnvironmentKey {
    static let defaultValue: Binding<Date?>? = nil
}

extension EnvironmentValues {
    var heatmapTitle: String? {
        get { self[HeatmapTitleKey.self] }
        set { self[HeatmapTitleKey.self] = newValue }
    }

    var heatmapSelection: Binding<Date?>? {
        get { self[HeatmapSelectionKey.self] }
        set { self[HeatmapSelectionKey.self] = newValue }
    }
}

extension View {
    /// Adds a title above the heatmap grid.
    public func heatmapTitle(_ title: String) -> some View {
        environment(\.heatmapTitle, title)
    }

    /// Binds a date selection to the heatmap, enabling tap-to-select.
    public func heatmapSelection(_ selection: Binding<Date?>) -> some View {
        environment(\.heatmapSelection, selection)
    }
}

// MARK: - Main View

/// A cross-platform SwiftUI calendar heatmap view.
///
/// Supports two data modes:
/// 1. **Dictionary + gradient**: Pass `[Date: Double]` values and a gradient color array.
/// 2. **Custom color closure**: Pass a `(Date) -> Color` closure for full control.
///
/// ```swift
/// // Dictionary mode
/// LNSCalendarHeatmap(dateRange: .lastYear, data: values)
///
/// // Custom color mode
/// LNSCalendarHeatmap(dateRange: .lastYear) { date in
///     myColorForDate(date)
/// }
/// ```
public struct LNSCalendarHeatmap: View {
    private let dateRange: HeatmapDateRange
    private let colorProvider: (Date) -> Color
    private let gradientColors: [Color]?

    @Environment(\.heatmapStyle) private var style
    @Environment(\.heatmapTitle) private var title
    @Environment(\.heatmapSelection) private var selectionBinding
    @Environment(\.heatmapLegendConfig) private var legendConfig
    @Environment(\.calendar) private var calendar

    @State private var internalSelection: Date?

    /// Creates a heatmap using dictionary data and a gradient.
    ///
    /// - Parameters:
    ///   - dateRange: The date range to display.
    ///   - data: A dictionary mapping dates to numeric values.
    ///   - gradient: The gradient colors to interpolate (default: gray to green).
    public init(
        dateRange: HeatmapDateRange,
        data: [Date: Double],
        gradient: [Color] = [Color.gray.opacity(0.15), .green]
    ) {
        self.dateRange = dateRange
        self.gradientColors = gradient

        // Pre-compute normalized values
        let values = data.values
        let maxVal = values.max() ?? 1
        let normalizedData: [Date: Double]
        if maxVal > 0 {
            normalizedData = data.mapValues { $0 / maxVal }
        } else {
            normalizedData = data
        }

        let capturedGradient = gradient
        self.colorProvider = { date in
            let cal = Calendar.current
            let startOfDay = cal.startOfDay(for: date)
            if let value = normalizedData[startOfDay] {
                return Color.interpolate(colors: capturedGradient, t: value)
            }
            // Try matching by date components for dates created differently
            for (key, value) in normalizedData {
                if cal.isDate(key, inSameDayAs: date) {
                    return Color.interpolate(colors: capturedGradient, t: value)
                }
            }
            return Color.gray.opacity(0.15)
        }
    }

    /// Creates a heatmap using a custom color closure.
    ///
    /// - Parameters:
    ///   - dateRange: The date range to display.
    ///   - colorForDate: A closure that returns a color for each date.
    public init(
        dateRange: HeatmapDateRange,
        colorForDate: @escaping (Date) -> Color
    ) {
        self.dateRange = dateRange
        self.colorProvider = colorForDate
        self.gradientColors = nil
    }

    private var selectedDate: Date? {
        selectionBinding?.wrappedValue ?? internalSelection
    }

    public var body: some View {
        let gridData = HeatmapGridData(dateRange: dateRange, calendar: calendar)

        VStack(alignment: .leading, spacing: 4) {
            if let title {
                Text(title)
                    .font(.headline)
                    .foregroundStyle(.primary)
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HeatmapGrid(
                    gridData: gridData,
                    colorForDate: colorProvider,
                    selectedDate: selectedDate,
                    onDateTapped: { date in
                        if let binding = selectionBinding {
                            binding.wrappedValue = date
                        } else {
                            internalSelection = date
                        }
                    }
                )
            }

            if let legendConfig {
                HeatmapLegendView(config: legendConfig)
            }
        }
    }
}

// MARK: - Previews

#Preview("Year 2025") {
    let calendar = Calendar.current
    let data: [Date: Double] = {
        var d: [Date: Double] = [:]
        let start = calendar.date(from: DateComponents(year: 2025, month: 1, day: 1))!
        for i in 0..<365 {
            let date = calendar.date(byAdding: .day, value: i, to: start)!
            d[date] = Double.random(in: 0...1)
        }
        return d
    }()

    ScrollView {
        LNSCalendarHeatmap(dateRange: .year(2025), data: data)
            .heatmapTitle("Contributions in 2025")
            .heatmapLegend(
                colors: [
                    Color.gray.opacity(0.15),
                    Color.green.opacity(0.3),
                    Color.green.opacity(0.5),
                    Color.green.opacity(0.7),
                    Color.green
                ],
                low: "Less",
                high: "More"
            )
            .padding()
    }
}

#Preview("Current Month") {
    LNSCalendarHeatmap(dateRange: .currentMonth) { date in
        let day = Calendar.current.component(.day, from: date)
        return Color.interpolate(colors: [.blue.opacity(0.2), .blue], t: Double(day) / 31.0)
    }
    .heatmapTitle("This Month")
    .padding()
}

#Preview("Last 3 Months") {
    let calendar = Calendar.current
    let data: [Date: Double] = {
        var d: [Date: Double] = [:]
        let end = Date.now
        let start = calendar.date(byAdding: .month, value: -3, to: end)!
        var current = start
        while current <= end {
            d[current] = Double.random(in: 0...1)
            current = calendar.date(byAdding: .day, value: 1, to: current)!
        }
        return d
    }()

    LNSCalendarHeatmap(
        dateRange: .lastMonths(3),
        data: data,
        gradient: [.gray.opacity(0.15), .orange, .red]
    )
    .heatmapTitle("Last 3 Months")
    .heatmapLegend(
        colors: [.gray.opacity(0.15), .orange.opacity(0.5), .orange, .red.opacity(0.7), .red]
    )
    .padding()
}

#Preview("Custom Color Closure") {
    LNSCalendarHeatmap(dateRange: .lastYear) { date in
        let weekday = Calendar.current.component(.weekday, from: date)
        if weekday == 1 || weekday == 7 {
            return .purple.opacity(0.3)
        }
        return .blue.opacity(Double.random(in: 0.1...0.8))
    }
    .heatmapStyle(HeatmapStyle(
        cellSize: 12,
        cellSpacing: 2,
        cellCornerRadius: 3,
        cellBorderWidth: 0
    ))
    .heatmapTitle("Weekday Pattern")
    .padding()
}

private struct SelectionDemo: View {
    @State private var selectedDate: Date?

    var body: some View {
        VStack {
            if let date = selectedDate {
                Text("Selected: \(date, format: .dateTime.month().day().year())")
                    .font(.subheadline)
            } else {
                Text("Tap a date")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            LNSCalendarHeatmap(dateRange: .currentMonth) { _ in
                .green.opacity(Double.random(in: 0.1...1.0))
            }
            .heatmapSelection($selectedDate)
            .heatmapTitle("Tap to Select")
        }
        .padding()
    }
}

#Preview("With Selection") {
    SelectionDemo()
}
