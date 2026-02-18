//
//  CustomRangeDemo.swift
//  Example
//

import SwiftUI
import LNSCalendarHeatmap

struct CustomRangeDemo: View {
    @State private var startDate = Calendar.current.date(byAdding: .month, value: -2, to: .now)!
    @State private var endDate = Date.now

    private let calendar = Calendar.current

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                header

                GroupBox("Date Range") {
                    VStack(spacing: 12) {
                        DatePicker("Start", selection: $startDate, displayedComponents: .date)
                        DatePicker("End", selection: $endDate, displayedComponents: .date)
                    }
                }
                .padding(.horizontal)

                if startDate <= endDate {
                    GroupBox("Heatmap  (.custom(start...end))") {
                        ScrollView(.horizontal, showsIndicators: false) {
                            LNSCalendarHeatmap(
                                dateRange: .custom(startDate...endDate),
                                data: rangeData,
                                gradient: DemoData.blueGradient
                            )
                            .heatmapTitle(rangeTitle)
                            .heatmapLegend(colors: DemoData.blueGradient)
                        }
                    }
                    .padding(.horizontal)

                    Text("\(dayCount) days in range")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .padding(.horizontal)
                } else {
                    ContentUnavailableView("Invalid Range",
                                           systemImage: "exclamationmark.triangle",
                                           description: Text("Start date must be before end date."))
                }
            }
            .padding(.vertical)
        }
        .navigationTitle("Custom Range")
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Custom Date Range")
                .font(.title2.bold())
            Text("Uses `.custom(ClosedRange<Date>)` for arbitrary date ranges selected with date pickers.")
                .font(.callout)
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal)
    }

    private var rangeData: [Date: Double] {
        guard startDate <= endDate else { return [:] }
        let range = HeatmapDateRange.custom(startDate...endDate).resolve(calendar: calendar)
        return DemoData.randomData(for: range)
    }

    private var dayCount: Int {
        let comps = calendar.dateComponents([.day], from: startDate, to: endDate)
        return (comps.day ?? 0) + 1
    }

    private var rangeTitle: String {
        let fmt = Date.FormatStyle().month(.abbreviated).day().year()
        return "\(startDate.formatted(fmt)) - \(endDate.formatted(fmt))"
    }
}

#Preview {
    NavigationStack {
        CustomRangeDemo()
    }
}
