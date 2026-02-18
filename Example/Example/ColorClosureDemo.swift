//
//  ColorClosureDemo.swift
//  Example
//

import SwiftUI
import LNSCalendarHeatmap

struct ColorClosureDemo: View {
    private let calendar = Calendar.current

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                header

                // Weekday pattern
                GroupBox("Weekday / Weekend Pattern") {
                    ScrollView(.horizontal, showsIndicators: false) {
                        LNSCalendarHeatmap(dateRange: .lastYear) { date in
                            let weekday = calendar.component(.weekday, from: date)
                            if weekday == 1 || weekday == 7 {
                                return .orange.opacity(Double.random(in: 0.2...0.6))
                            }
                            return .blue.opacity(Double.random(in: 0.2...0.8))
                        }
                        .heatmapTitle("Blue = Weekday, Orange = Weekend")
                    }
                }
                .padding(.horizontal)

                // Day-of-month gradient
                GroupBox("Day-of-Month Gradient") {
                    LNSCalendarHeatmap(dateRange: .currentMonth) { date in
                        let day = calendar.component(.day, from: date)
                        let t = Double(day) / 31.0
                        return Color.interpolate(colors: [.mint, .indigo], t: t)
                    }
                    .heatmapTitle("Gradient across the month")
                }
                .padding(.horizontal)

                // Seasonal coloring
                GroupBox("Seasonal Colors") {
                    ScrollView(.horizontal, showsIndicators: false) {
                        LNSCalendarHeatmap(dateRange: .year(calendar.component(.year, from: .now))) { date in
                            let month = calendar.component(.month, from: date)
                            let base: Color = switch month {
                            case 3...5: .green   // Spring
                            case 6...8: .yellow  // Summer
                            case 9...11: .orange // Autumn
                            default: .cyan       // Winter
                            }
                            return base.opacity(Double.random(in: 0.3...0.9))
                        }
                        .heatmapTitle("Spring / Summer / Autumn / Winter")
                    }
                }
                .padding(.horizontal)

                // Binary (on/off)
                GroupBox("Binary Pattern (Alternating Weeks)") {
                    ScrollView(.horizontal, showsIndicators: false) {
                        LNSCalendarHeatmap(dateRange: .lastMonths(3)) { date in
                            let weekOfYear = calendar.component(.weekOfYear, from: date)
                            return weekOfYear.isMultiple(of: 2) ? .green : Color.gray.opacity(0.15)
                        }
                        .heatmapTitle("Even weeks highlighted")
                    }
                }
                .padding(.horizontal)
            }
            .padding(.vertical)
        }
        .navigationTitle("Color Closure")
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Custom Color Closures")
                .font(.title2.bold())
            Text("Uses the `colorForDate: (Date) -> Color` initializer for full control over cell coloring.")
                .font(.callout)
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal)
    }
}


#Preview {
    NavigationStack {
        ColorClosureDemo()
    }
}
