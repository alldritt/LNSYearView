//
//  DemoData.swift
//  Example
//
//  Shared data generation utilities for heatmap demos.
//

import Foundation
import SwiftUI

enum DemoData {
    /// Generates random heatmap data for a date range.
    static func randomData(for range: ClosedRange<Date>, calendar: Calendar = .current) -> [Date: Double] {
        var data: [Date: Double] = [:]
        var current = range.lowerBound
        while current <= range.upperBound {
            // Weighted random: many zeros, some medium, few high
            let roll = Double.random(in: 0...1)
            if roll < 0.3 {
                data[current] = 0
            } else if roll < 0.7 {
                data[current] = Double.random(in: 0.1...0.4)
            } else if roll < 0.9 {
                data[current] = Double.random(in: 0.4...0.7)
            } else {
                data[current] = Double.random(in: 0.7...1.0)
            }
            current = calendar.date(byAdding: .day, value: 1, to: current)!
        }
        return data
    }

    /// Generates data that simulates a commit/contribution pattern.
    static func contributionData(year: Int, calendar: Calendar = .current) -> [Date: Double] {
        var data: [Date: Double] = [:]
        let start = calendar.date(from: DateComponents(year: year, month: 1, day: 1))!
        let end = calendar.date(from: DateComponents(year: year, month: 12, day: 31))!
        var current = start
        while current <= end {
            let weekday = calendar.component(.weekday, from: current)
            let isWeekend = weekday == 1 || weekday == 7

            // Weekends have less activity
            let baseChance = isWeekend ? 0.2 : 0.6
            if Double.random(in: 0...1) < baseChance {
                data[current] = Double.random(in: 0.1...1.0)
            } else {
                data[current] = 0
            }
            current = calendar.date(byAdding: .day, value: 1, to: current)!
        }
        return data
    }

    /// GitHub-style green gradient.
    static let greenGradient: [Color] = [
        Color.gray.opacity(0.15),
        Color.green.opacity(0.3),
        Color.green.opacity(0.5),
        Color.green.opacity(0.7),
        Color.green
    ]

    /// Blue gradient.
    static let blueGradient: [Color] = [
        Color.gray.opacity(0.15),
        Color.blue.opacity(0.3),
        Color.blue.opacity(0.5),
        Color.blue.opacity(0.7),
        Color.blue
    ]

    /// Orange-red heat gradient.
    static let heatGradient: [Color] = [
        Color.gray.opacity(0.15),
        Color.yellow.opacity(0.4),
        Color.orange.opacity(0.6),
        Color.red.opacity(0.8),
        Color.red
    ]

    /// Purple gradient.
    static let purpleGradient: [Color] = [
        Color.gray.opacity(0.15),
        Color.purple.opacity(0.3),
        Color.purple.opacity(0.5),
        Color.purple.opacity(0.7),
        Color.purple
    ]
}
