//
//  LGTypography.swift
//  LuidGPT
//
//  Design System - Typography
//  SF Pro font system matching Geist Sans from web
//

import SwiftUI

/// LuidGPT Typography System
/// Uses SF Pro (iOS default) which closely matches Geist Sans from the web app
struct LGFonts {

    // MARK: - Font Weights

    /// Regular weight (400)
    static let regular: Font.Weight = .regular

    /// Medium weight (500)
    static let medium: Font.Weight = .medium

    /// Semibold (600)
    static let semibold: Font.Weight = .semibold

    /// Bold (700)
    static let bold: Font.Weight = .bold

    /// Extra Bold (800)
    static let extrabold: Font.Weight = .heavy

    /// Black (900)
    static let black: Font.Weight = .black

    // MARK: - Typography Scale

    /// Display text (48pt, bold)
    static let displayLarge = Font.system(size: 48, weight: .bold, design: .default)

    /// Hero title (36pt)
    static let h1 = Font.system(size: 36, weight: .bold)

    /// Section title (28pt)
    static let h2 = Font.system(size: 28, weight: .bold)

    /// Card title (24pt)
    static let h3 = Font.system(size: 24, weight: .semibold)

    /// Subsection title (20pt)
    static let h4 = Font.system(size: 20, weight: .semibold)

    /// Small heading (18pt)
    static let h5 = Font.system(size: 18, weight: .semibold)

    /// Body text (16pt)
    static let body = Font.system(size: 16, weight: .regular)

    /// Body medium (16pt, medium weight)
    static let bodyMedium = Font.system(size: 16, weight: .medium)

    /// Small text (14pt)
    static let small = Font.system(size: 14, weight: .regular)

    /// Label text for forms (14pt, medium weight)
    static let label = Font.system(size: 14, weight: .medium)

    /// Caption text (12pt)
    static let caption = Font.system(size: 12, weight: .regular)

    /// Tiny text (11pt)
    static let tiny = Font.system(size: 11, weight: .regular)
}
