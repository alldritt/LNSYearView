//
//  RollingRangeDemo.swift
//  Example
//

import SwiftUI
import LNSCalendarHeatmap

struct RollingRangeDemo: View {
    @State private var monthCount = 6

    private let calendar = Calendar.current

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                header

                // Last year
                GroupBox("Last 12 Months  (.lastYear)") {
                    ScrollView(.horizontal, showsIndicators: false) {
                        LNSCalendarHeatmap(
                            dateRange: .lastYear,
                            data: lastYearData,
                            gradient: DemoData.greenGradient
                        )
                        .heatmapTitle("Past Year Activity")
                        .heatmapLegend(colors: DemoData.greenGradient)
                    }
                }
                .padding(.horizontal)

                Divider()

                // Last N months with slider
                GroupBox("Last N Months  (.lastMonths(Int))") {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Months: \(monthCount)")
                            Slider(value: Binding(
                                get: { Double(monthCount) },
                                set: { monthCount = Int($0) }
                            ), in: 1...12, step: 1)
                        }

                        ScrollView(.horizontal, showsIndicators: false) {
                            LNSCalendarHeatmap(
                                dateRange: .lastMonths(monthCount),
                                data: lastNMonthsData,
                                gradient: DemoData.heatGradient
                            )
                            .heatmapTitle("Last \(monthCount) Month\(monthCount == 1 ? "" : "s")")
                            .heatmapLegend(colors: DemoData.heatGradient, low: "Cool", high: "Hot")
                        }
                    }
                }
                .padding(.horizontal)
            }
            .padding(.vertical)
        }
        .navigationTitle("Rolling Range")
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Rolling Date Ranges")
                .font(.title2.bold())
            Text("Uses `.lastYear` and `.lastMonths(N)` for trailing date ranges that end today.")
                .font(.callout)
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal)
    }

    private var lastYearData: [Date: Double] {
        let range = HeatmapDateRange.lastYear.resolve(calendar: calendar)
        return DemoData.randomData(for: range)
    }

    private var lastNMonthsData: [Date: Double] {
        let range = HeatmapDateRange.lastMonths(monthCount).resolve(calendar: calendar)
        return DemoData.randomData(for: range)
    }
}

#Preview {
    NavigationStack {
        RollingRangeDemo()
    }
}
