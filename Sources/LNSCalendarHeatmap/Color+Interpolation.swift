import SwiftUI

extension Color {
    /// Interpolates between an array of colors based on a 0...1 parameter.
    ///
    /// - Parameters:
    ///   - colors: Gradient stop colors (must have at least 2 elements).
    ///   - t: Normalized value in 0...1.
    /// - Returns: The interpolated color.
    public static func interpolate(colors: [Color], t: Double) -> Color {
        guard colors.count >= 2 else { return colors.first ?? .clear }

        let clamped = min(max(t, 0), 1)
        let segments = colors.count - 1
        let scaledT = clamped * Double(segments)
        let index = min(Int(scaledT), segments - 1)
        let localT = scaledT - Double(index)

        return blend(colors[index], colors[index + 1], fraction: localT)
    }

    /// Linearly blends two colors in the sRGB color space.
    private static func blend(_ c1: Color, _ c2: Color, fraction: Double) -> Color {
        let r1 = c1.resolvedComponents
        let r2 = c2.resolvedComponents

        return Color(
            red: r1.red + (r2.red - r1.red) * fraction,
            green: r1.green + (r2.green - r1.green) * fraction,
            blue: r1.blue + (r2.blue - r1.blue) * fraction,
            opacity: r1.opacity + (r2.opacity - r1.opacity) * fraction
        )
    }
}

// MARK: - Color component extraction

private struct ResolvedColorComponents {
    var red: Double = 0
    var green: Double = 0
    var blue: Double = 0
    var opacity: Double = 1
}

extension Color {
    fileprivate var resolvedComponents: ResolvedColorComponents {
        var components = ResolvedColorComponents()
        #if canImport(UIKit)
        let uiColor = UIColor(self)
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        uiColor.getRed(&r, green: &g, blue: &b, alpha: &a)
        components.red = Double(r)
        components.green = Double(g)
        components.blue = Double(b)
        components.opacity = Double(a)
        #elseif canImport(AppKit)
        let nsColor = NSColor(self).usingColorSpace(.sRGB) ?? NSColor(self)
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        nsColor.getRed(&r, green: &g, blue: &b, alpha: &a)
        components.red = Double(r)
        components.green = Double(g)
        components.blue = Double(b)
        components.opacity = Double(a)
        #endif
        return components
    }
}
