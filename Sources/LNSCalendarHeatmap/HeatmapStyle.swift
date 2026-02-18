import SwiftUI

/// Visual configuration for the heatmap grid.
public struct HeatmapStyle: Sendable {
    public var cellSize: CGFloat
    public var cellSpacing: CGFloat
    public var cellCornerRadius: CGFloat
    public var cellBorderWidth: CGFloat
    public var cellBorderColor: Color
    public var monthLabelColor: Color
    public var weekdayLabelColor: Color
    public var defaultCellColor: Color
    public var showWeekdayLabels: Bool
    public var showMonthLabels: Bool

    public init(
        cellSize: CGFloat = 15,
        cellSpacing: CGFloat = 2,
        cellCornerRadius: CGFloat = 2,
        cellBorderWidth: CGFloat = 0,
        cellBorderColor: Color = .secondary,
        monthLabelColor: Color = .secondary,
        weekdayLabelColor: Color = Color.secondary.opacity(0.7),
        defaultCellColor: Color = Color.gray.opacity(0.15),
        showWeekdayLabels: Bool = true,
        showMonthLabels: Bool = true
    ) {
        self.cellSize = cellSize
        self.cellSpacing = cellSpacing
        self.cellCornerRadius = cellCornerRadius
        self.cellBorderWidth = cellBorderWidth
        self.cellBorderColor = cellBorderColor
        self.monthLabelColor = monthLabelColor
        self.weekdayLabelColor = weekdayLabelColor
        self.defaultCellColor = defaultCellColor
        self.showWeekdayLabels = showWeekdayLabels
        self.showMonthLabels = showMonthLabels
    }
}

// MARK: - Environment Key

struct HeatmapStyleKey: EnvironmentKey {
    static let defaultValue = HeatmapStyle()
}

extension EnvironmentValues {
    var heatmapStyle: HeatmapStyle {
        get { self[HeatmapStyleKey.self] }
        set { self[HeatmapStyleKey.self] = newValue }
    }
}

extension View {
    /// Configures the visual style of the heatmap.
    public func heatmapStyle(_ style: HeatmapStyle) -> some View {
        environment(\.heatmapStyle, style)
    }
}
