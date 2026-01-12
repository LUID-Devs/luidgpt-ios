//
//  LGSpacing.swift
//  LuidGPT
//
//  Design System - Spacing & Layout
//

import SwiftUI

/// LuidGPT Spacing System
/// Consistent spacing values matching the web app's design
struct LGSpacing {

    // MARK: - Base Spacing Scale (4pt base unit)

    /// 4pt
    static let xxs: CGFloat = 4

    /// 8pt
    static let xs: CGFloat = 8

    /// 12pt
    static let sm: CGFloat = 12

    /// 16pt
    static let md: CGFloat = 16

    /// 20pt
    static let lg: CGFloat = 20

    /// 24pt
    static let xl: CGFloat = 24

    /// 32pt
    static let xxl: CGFloat = 32

    /// 40pt
    static let xxxl: CGFloat = 40

    /// 48pt
    static let huge: CGFloat = 48

    // MARK: - Layout Constants

    /// Card padding (16pt)
    static let cardPadding: CGFloat = 16

    /// Card corner radius (12pt)
    static let cardRadius: CGFloat = 12

    /// Button corner radius (8pt)
    static let buttonRadius: CGFloat = 8

    /// Badge corner radius (full pill)
    static let badgeRadius: CGFloat = 100

    /// Icon sizes
    struct IconSize {
        static let tiny: CGFloat = 12
        static let small: CGFloat = 16
        static let medium: CGFloat = 20
        static let large: CGFloat = 24
        static let xlarge: CGFloat = 32
    }

    /// Standard horizontal screen padding
    static let screenHPadding: CGFloat = 16

    /// Standard vertical screen padding
    static let screenVPadding: CGFloat = 20

    /// Grid spacing for model cards
    static let gridSpacing: CGFloat = 16

    /// List item spacing
    static let listSpacing: CGFloat = 12
}

// MARK: - Edge Insets Helper

extension LGSpacing {
    /// Uniform padding
    static func padding(_ value: CGFloat) -> EdgeInsets {
        EdgeInsets(top: value, leading: value, bottom: value, trailing: value)
    }

    /// Horizontal padding only
    static func horizontalPadding(_ value: CGFloat) -> EdgeInsets {
        EdgeInsets(top: 0, leading: value, bottom: 0, trailing: value)
    }

    /// Vertical padding only
    static func verticalPadding(_ value: CGFloat) -> EdgeInsets {
        EdgeInsets(top: value, leading: 0, bottom: value, trailing: 0)
    }

    /// Screen safe area padding
    static var screenPadding: EdgeInsets {
        EdgeInsets(
            top: screenVPadding,
            leading: screenHPadding,
            bottom: screenVPadding,
            trailing: screenHPadding
        )
    }
}
