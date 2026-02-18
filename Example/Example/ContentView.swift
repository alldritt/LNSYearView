//
//  ContentView.swift
//  Example
//
//  Created by Mark Alldritt on 2026-02-18.
//

import SwiftUI

enum DemoItem: String, CaseIterable, Identifiable {
    case fullYear = "Full Year"
    case monthView = "Month View"
    case rollingRange = "Rolling Range"
    case customRange = "Custom Range"
    case colorClosure = "Color Closure"
    case selection = "Selection"
    case styleShowcase = "Style Showcase"

    var id: String { rawValue }

    var subtitle: String {
        switch self {
        case .fullYear: "Dictionary + gradient for a calendar year"
        case .monthView: "Single month and current month"
        case .rollingRange: "Last year and last N months"
        case .customRange: "User-defined date range with pickers"
        case .colorClosure: "Custom (Date) -> Color function"
        case .selection: "Tap-to-select with detail display"
        case .styleShowcase: "Visual style variations"
        }
    }

    var systemImage: String {
        switch self {
        case .fullYear: "calendar"
        case .monthView: "calendar.day.timeline.left"
        case .rollingRange: "clock.arrow.circlepath"
        case .customRange: "calendar.badge.clock"
        case .colorClosure: "paintpalette"
        case .selection: "hand.tap"
        case .styleShowcase: "paintbrush"
        }
    }
}

struct ContentView: View {
    @State private var selectedDemo: DemoItem? = .fullYear

    var body: some View {
        NavigationSplitView {
            List(DemoItem.allCases, selection: $selectedDemo) { item in
                NavigationLink(value: item) {
                    Label {
                        VStack(alignment: .leading) {
                            Text(item.rawValue)
                            Text(item.subtitle)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    } icon: {
                        Image(systemName: item.systemImage)
                    }
                }
            }
            .navigationTitle("Heatmap Demos")
        } detail: {
            if let selectedDemo {
                detailView(for: selectedDemo)
            } else {
                ContentUnavailableView("Select a Demo",
                                       systemImage: "square.grid.3x3",
                                       description: Text("Choose a heatmap demo from the sidebar."))
            }
        }
    }

    @ViewBuilder
    private func detailView(for demo: DemoItem) -> some View {
        switch demo {
        case .fullYear: FullYearDemo()
        case .monthView: MonthViewDemo()
        case .rollingRange: RollingRangeDemo()
        case .customRange: CustomRangeDemo()
        case .colorClosure: ColorClosureDemo()
        case .selection: SelectionDemo()
        case .styleShowcase: StyleShowcaseDemo()
        }
    }
}

#Preview {
    ContentView()
}
