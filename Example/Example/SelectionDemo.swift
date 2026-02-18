//
//  SelectionDemo.swift
//  Example
//

import SwiftUI
import LNSCalendarHeatmap

struct SelectionDemo: View {
    @State private var selectedDate: Date?
    @State private var data: [Date: Double] = [:]

    private let calendar = Calendar.current

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                header

                // Selection info card
                GroupBox {
                    if let date = selectedDate {
                        HStack {
                            Image(systemName: "calendar.circle.fill")
                                .font(.title)
                                .foregroundStyle(.blue)
                            VStack(alignment: .leading) {
                                Text(date, format: .dateTime.weekday(.wide).month(.wide).day().year())
                                    .font(.headline)
                                if let value = lookupValue(for: date) {
                                    Text("Value: \(value, specifier: "%.2f")")
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                    ProgressView(value: value)
                                        .tint(.green)
                                }
                            }
                            Spacer()
                            Button("Clear") {
                                selectedDate = nil
                            }
                            .buttonStyle(.bordered)
                        }
                    } else {
                        Label("Tap any cell to select a date", systemImage: "hand.tap")
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(.horizontal)

                // Current month with selection
                GroupBox("Current Month") {
                    LNSCalendarHeatmap(
                        dateRange: .currentMonth,
                        data: data,
                        gradient: DemoData.greenGradient
                    )
                    .heatmapSelection($selectedDate)
                    .heatmapLegend(colors: DemoData.greenGradient)
                }
                .padding(.horizontal)

                Divider()

                // Last 3 months with same selection binding
                GroupBox("Last 3 Months (shared selection)") {
                    ScrollView(.horizontal, showsIndicators: false) {
                        LNSCalendarHeatmap(
                            dateRange: .lastMonths(3),
                            data: data,
                            gradient: DemoData.blueGradient
                        )
                        .heatmapSelection($selectedDate)
                        .heatmapLegend(colors: DemoData.blueGradient)
                    }
                }
                .padding(.horizontal)

                Text("Both heatmaps share the same selection binding. Tapping either one updates both.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal)
            }
            .padding(.vertical)
        }
        .navigationTitle("Selection")
        .onAppear { regenerateData() }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Interactive Selection")
                .font(.title2.bold())
            Text("Uses `.heatmapSelection($date)` binding. Multiple heatmaps can share the same selection state.")
                .font(.callout)
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal)
    }

    private func lookupValue(for date: Date) -> Double? {
        for (key, value) in data {
            if calendar.isDate(key, inSameDayAs: date) {
                return value
            }
        }
        return nil
    }

    private func regenerateData() {
        let range = HeatmapDateRange.lastMonths(3).resolve(calendar: calendar)
        data = DemoData.randomData(for: range)
    }
}

#Preview {
    NavigationStack {
        SelectionDemo()
    }
}
