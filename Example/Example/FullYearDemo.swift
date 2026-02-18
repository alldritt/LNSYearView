//
//  FullYearDemo.swift
//  Example
//

import SwiftUI
import LNSCalendarHeatmap

struct FullYearDemo: View {
    @State private var year = Calendar.current.component(.year, from: .now)
    @State private var data: [Date: Double] = [:]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                header

                Stepper("Year: \(year)", value: $year, in: 2000...2030)
                    .padding(.horizontal)

                ScrollView(.horizontal, showsIndicators: false) {
                    LNSCalendarHeatmap(
                        dateRange: .year(year),
                        data: data,
                        gradient: DemoData.greenGradient
                    )
                    .heatmapTitle("Contributions in \(String(year))")
                    .heatmapLegend(colors: DemoData.greenGradient)
                    .padding(.horizontal)
                }

                Divider()

                Text("Blue Variant")
                    .font(.subheadline.bold())
                    .padding(.horizontal)

                ScrollView(.horizontal, showsIndicators: false) {
                    LNSCalendarHeatmap(
                        dateRange: .year(year),
                        data: data,
                        gradient: DemoData.blueGradient
                    )
                    .heatmapLegend(colors: DemoData.blueGradient, low: "Fewer", high: "More")
                    .padding(.horizontal)
                }
            }
            .padding(.vertical)
        }
        .navigationTitle("Full Year")
        .onAppear { regenerateData() }
        .onChange(of: year) { regenerateData() }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Full Calendar Year")
                .font(.title2.bold())
            Text("Uses `.year(Int)` date range with `[Date: Double]` dictionary data and gradient interpolation.")
                .font(.callout)
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal)
    }

    private func regenerateData() {
        data = DemoData.contributionData(year: year)
    }
}

#Preview {
    NavigationStack {
        FullYearDemo()
    }
}
