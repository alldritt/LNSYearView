//
//  MonthViewDemo.swift
//  Example
//

import SwiftUI
import LNSCalendarHeatmap

struct MonthViewDemo: View {
    @State private var selectedYear = Calendar.current.component(.year, from: .now)
    @State private var selectedMonth = Calendar.current.component(.month, from: .now)
    @State private var data: [Date: Double] = [:]

    private let calendar = Calendar.current
    private let monthNames = Calendar.current.monthSymbols

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                header

                // Current month
                GroupBox("Current Month  (.currentMonth)") {
                    LNSCalendarHeatmap(
                        dateRange: .currentMonth,
                        data: currentMonthData,
                        gradient: DemoData.greenGradient
                    )
                    .heatmapLegend(colors: DemoData.greenGradient)
                }
                .padding(.horizontal)

                Divider()

                // Specific month picker
                GroupBox("Specific Month  (.month(year:month:))") {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Picker("Month", selection: $selectedMonth) {
                                ForEach(1...12, id: \.self) { m in
                                    Text(monthNames[m - 1]).tag(m)
                                }
                            }

                            Stepper("Year: \(selectedYear)", value: $selectedYear, in: 2000...2030)
                        }

                        LNSCalendarHeatmap(
                            dateRange: .month(year: selectedYear, month: selectedMonth),
                            data: data,
                            gradient: DemoData.purpleGradient
                        )
                        .heatmapLegend(colors: DemoData.purpleGradient)
                    }
                }
                .padding(.horizontal)
            }
            .padding(.vertical)
        }
        .navigationTitle("Month View")
        .onAppear { regenerateData() }
        .onChange(of: selectedYear) { regenerateData() }
        .onChange(of: selectedMonth) { regenerateData() }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Month Heatmaps")
                .font(.title2.bold())
            Text("Displays `.currentMonth` and `.month(year:month:)` date ranges. Compact enough to display without horizontal scrolling.")
                .font(.callout)
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal)
    }

    private var currentMonthData: [Date: Double] {
        let range = HeatmapDateRange.currentMonth.resolve(calendar: calendar)
        return DemoData.randomData(for: range)
    }

    private func regenerateData() {
        let range = HeatmapDateRange.month(year: selectedYear, month: selectedMonth)
            .resolve(calendar: calendar)
        data = DemoData.randomData(for: range)
    }
}

#Preview {
    NavigationStack {
        MonthViewDemo()
    }
}
