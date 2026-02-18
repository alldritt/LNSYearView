//
//  StyleShowcaseDemo.swift
//  Example
//

import SwiftUI
import LNSCalendarHeatmap

struct StyleShowcaseDemo: View {
    private let calendar = Calendar.current
    private let demoRange: HeatmapDateRange = .lastMonths(3)

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                header

                // Default style
                GroupBox("Default Style") {
                    ScrollView(.horizontal, showsIndicators: false) {
                        heatmap
                    }
                }
                .padding(.horizontal)

                // Large cells, rounded
                GroupBox("Large Rounded Cells") {
                    ScrollView(.horizontal, showsIndicators: false) {
                        heatmap
                            .heatmapStyle(HeatmapStyle(
                                cellSize: 20,
                                cellSpacing: 3,
                                cellCornerRadius: 5
                            ))
                    }
                }
                .padding(.horizontal)

                // Small dense cells
                GroupBox("Small Dense Grid") {
                    ScrollView(.horizontal, showsIndicators: false) {
                        heatmap
                            .heatmapStyle(HeatmapStyle(
                                cellSize: 8,
                                cellSpacing: 1,
                                cellCornerRadius: 1
                            ))
                    }
                }
                .padding(.horizontal)

                // Square cells with borders
                GroupBox("Bordered Square Cells") {
                    ScrollView(.horizontal, showsIndicators: false) {
                        heatmap
                            .heatmapStyle(HeatmapStyle(
                                cellSize: 14,
                                cellSpacing: 1,
                                cellCornerRadius: 0,
                                cellBorderWidth: 0.5,
                                cellBorderColor: .gray.opacity(0.3)
                            ))
                    }
                }
                .padding(.horizontal)

                // Circular cells
                GroupBox("Circular Cells") {
                    ScrollView(.horizontal, showsIndicators: false) {
                        heatmap
                            .heatmapStyle(HeatmapStyle(
                                cellSize: 14,
                                cellSpacing: 3,
                                cellCornerRadius: 7
                            ))
                    }
                }
                .padding(.horizontal)

                // No labels
                GroupBox("No Labels") {
                    ScrollView(.horizontal, showsIndicators: false) {
                        heatmap
                            .heatmapStyle(HeatmapStyle(
                                showWeekdayLabels: false,
                                showMonthLabels: false
                            ))
                    }
                }
                .padding(.horizontal)

                // Custom colors - dark appearance
                GroupBox("Dark Tint") {
                    ScrollView(.horizontal, showsIndicators: false) {
                        LNSCalendarHeatmap(
                            dateRange: demoRange,
                            data: data,
                            gradient: DemoData.heatGradient
                        )
                        .heatmapStyle(HeatmapStyle(
                            cellSize: 13,
                            cellSpacing: 2,
                            cellCornerRadius: 2,
                            monthLabelColor: .orange,
                            weekdayLabelColor: .orange.opacity(0.6),
                            defaultCellColor: Color.gray.opacity(0.1)
                        ))
                        .heatmapLegend(colors: DemoData.heatGradient, low: "Cool", high: "Hot")
                    }
                }
                .padding(.horizontal)
            }
            .padding(.vertical)
        }
        .navigationTitle("Style Showcase")
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Style Variations")
                .font(.title2.bold())
            Text("Uses `.heatmapStyle(HeatmapStyle(...))` to customize cell size, spacing, corner radius, borders, and label visibility.")
                .font(.callout)
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal)
    }

    private var data: [Date: Double] {
        let range = demoRange.resolve(calendar: calendar)
        return DemoData.randomData(for: range)
    }

    private var heatmap: some View {
        LNSCalendarHeatmap(
            dateRange: demoRange,
            data: data,
            gradient: DemoData.greenGradient
        )
    }
}

#Preview {
    NavigationStack {
        StyleShowcaseDemo()
    }
}
