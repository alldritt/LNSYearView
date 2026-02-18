LNSCalendarHeatmap
==================

A SwiftUI calendar heatmap view, distributed as a Swift Package. It renders a GitHub-style contribution grid for iOS 17+ and macOS 14+.

The original version of this project was an Objective-C `NSView` subclass (`LNSYearView`) that drew everything in `drawRect:`. This rewrite replaces it with a cross-platform SwiftUI package built on `Canvas`.


## Adding the Package

In Xcode, go to File > Add Package Dependencies and point it at this repository. Or add it to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/alldritt/LNSCalendarHeatmap.git", from: "2.0.0")
]
```


## Usage

There are two ways to provide data. The first takes a `[Date: Double]` dictionary and interpolates colors across a gradient:

```swift
import LNSCalendarHeatmap

LNSCalendarHeatmap(
    dateRange: .year(2025),
    data: myData,
    gradient: [.gray.opacity(0.15), .green]
)
```

The second takes a closure that returns a color for each date, giving you full control:

```swift
LNSCalendarHeatmap(dateRange: .lastYear) { date in
    myColorForDate(date)
}
```


## Date Ranges

The view supports several date range modes:

```swift
.year(2025)                    // Full calendar year
.lastYear                      // Trailing 12 months
.lastMonths(6)                 // Trailing N months
.month(year: 2025, month: 6)   // Single month
.currentMonth                  // This month
.custom(startDate...endDate)   // Arbitrary range
```


## Configuration

Visual appearance is controlled through a `HeatmapStyle` struct applied as a view modifier:

```swift
LNSCalendarHeatmap(dateRange: .lastYear, data: myData)
    .heatmapStyle(HeatmapStyle(
        cellSize: 12,
        cellSpacing: 2,
        cellCornerRadius: 3,
        cellBorderWidth: 0.5,
        cellBorderColor: .gray.opacity(0.3),
        showWeekdayLabels: true,
        showMonthLabels: true
    ))
```

There are optional modifiers for a title, a color legend, and date selection:

```swift
LNSCalendarHeatmap(dateRange: .year(2025), data: myData)
    .heatmapTitle("Contributions in 2025")
    .heatmapLegend(colors: legendColors, low: "Less", high: "More")
    .heatmapSelection($selectedDate)
```


## Example App

The `Example` directory contains a multi-platform app with demos for each date range mode, both data modes, interactive selection, and various style configurations.


## Requirements

- iOS 17+ / macOS 14+
- Swift 5.9+
- Xcode 15+


## License

MIT. See [LICENSE](LICENSE) for details.
