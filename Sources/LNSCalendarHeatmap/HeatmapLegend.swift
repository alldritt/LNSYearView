import SwiftUI

/// Configuration for the heatmap legend, passed via environment.
struct HeatmapLegendConfig: Equatable, Sendable {
    var colors: [Color]
    var lowLabel: String
    var highLabel: String
}

struct HeatmapLegendConfigKey: EnvironmentKey {
    static let defaultValue: HeatmapLegendConfig? = nil
}

extension EnvironmentValues {
    var heatmapLegendConfig: HeatmapLegendConfig? {
        get { self[HeatmapLegendConfigKey.self] }
        set { self[HeatmapLegendConfigKey.self] = newValue }
    }
}

extension View {
    /// Adds a color legend below the heatmap grid.
    ///
    /// - Parameters:
    ///   - colors: The gradient colors to display in the legend (typically 5-7 swatches).
    ///   - low: Label for the low end (default "Less").
    ///   - high: Label for the high end (default "More").
    public func heatmapLegend(colors: [Color], low: String = "Less", high: String = "More") -> some View {
        environment(\.heatmapLegendConfig, HeatmapLegendConfig(colors: colors, lowLabel: low, highLabel: high))
    }
}

/// The legend subview displayed below the heatmap.
struct HeatmapLegendView: View {
    let config: HeatmapLegendConfig
    @Environment(\.heatmapStyle) private var style

    var body: some View {
        HStack(spacing: 4) {
            Spacer()
            Text(config.lowLabel)
                .font(.system(size: 10))
                .foregroundStyle(style.monthLabelColor)

            HStack(spacing: style.cellSpacing) {
                ForEach(Array(config.colors.enumerated()), id: \.offset) { _, color in
                    RoundedRectangle(cornerRadius: style.cellCornerRadius)
                        .fill(color)
                        .frame(width: style.cellSize, height: style.cellSize)
                        .overlay(
                            RoundedRectangle(cornerRadius: style.cellCornerRadius)
                                .stroke(style.cellBorderColor, lineWidth: style.cellBorderWidth)
                        )
                }
            }

            Text(config.highLabel)
                .font(.system(size: 10))
                .foregroundStyle(style.monthLabelColor)
        }
    }
}
