//
//  LGColors.swift
//  LuidGPT
//
//  Design System - Colors
//  Matches luidgpt-frontend color palette exactly
//

import SwiftUI

/// LuidGPT Color System
/// Matches the web app's dark theme with neutral grays and vibrant category colors
struct LGColors {

    // MARK: - Base Colors

    /// Pure white background (#FFFFFF)
    static let background = Color.white

    /// Primary foreground text (#000000)
    static let foreground = Color.black

    /// Secondary foreground text (#525252)
    static let foregroundSecondary = Color(hex: "#525252")

    // MARK: - Surface Colors (Neutral Grays)

    static let neutral50 = Color(hex: "#FAFAFA")
    static let neutral100 = Color(hex: "#F5F5F5")
    static let neutral200 = Color(hex: "#E5E5E5")
    static let neutral300 = Color(hex: "#D4D4D4")
    static let neutral400 = Color(hex: "#A3A3A3")
    static let neutral500 = Color(hex: "#737373")
    static let neutral600 = Color(hex: "#525252")
    static let neutral700 = Color(hex: "#404040")
    static let neutral800 = Color(hex: "#262626")

    // MARK: - Primary Action Colors

    static let blue500 = Color(hex: "#3B82F6")
    static let blue600 = Color(hex: "#2563EB")
    static let blue700 = Color(hex: "#1D4ED8")
    static let blue400 = Color(hex: "#60A5FA")
    static let blue300 = Color(hex: "#93C5FD")

    // MARK: - Category Colors (11 Categories)

    /// Video Generation - Purple
    struct VideoGeneration {
        static let main = Color(hex: "#A855F7")
        static let bg = main.opacity(0.2)
        static let border = main.opacity(0.3)
    }

    /// Image Generation - Blue
    struct ImageGeneration {
        static let main = Color(hex: "#3B82F6")
        static let bg = main.opacity(0.2)
        static let border = main.opacity(0.3)
    }

    /// Image Editing - Green
    struct ImageEditing {
        static let main = Color(hex: "#22C55E")
        static let bg = main.opacity(0.2)
        static let border = main.opacity(0.3)
    }

    /// Text Generation - Yellow
    struct TextGeneration {
        static let main = Color(hex: "#EAB308")
        static let bg = main.opacity(0.2)
        static let border = main.opacity(0.3)
    }

    /// Audio & Speech - Red
    struct AudioSpeech {
        static let main = Color(hex: "#EF4444")
        static let bg = main.opacity(0.2)
        static let border = main.opacity(0.3)
    }

    /// Music Generation - Pink
    struct MusicGeneration {
        static let main = Color(hex: "#EC4899")
        static let bg = main.opacity(0.2)
        static let border = main.opacity(0.3)
    }

    /// Upscaling - Cyan
    struct Upscaling {
        static let main = Color(hex: "#06B6D4")
        static let bg = main.opacity(0.2)
        static let border = main.opacity(0.3)
    }

    /// Vision & Documents - Orange
    struct VisionDocuments {
        static let main = Color(hex: "#F97316")
        static let bg = main.opacity(0.2)
        static let border = main.opacity(0.3)
    }

    /// 3D Models - Indigo
    struct ThreeDModels {
        static let main = Color(hex: "#6366F1")
        static let bg = main.opacity(0.2)
        static let border = main.opacity(0.3)
    }

    /// Face & Avatar - Teal
    struct FaceAvatar {
        static let main = Color(hex: "#14B8A6")
        static let bg = main.opacity(0.2)
        static let border = main.opacity(0.3)
    }

    /// Utility - Gray
    struct Utility {
        static let main = Color(hex: "#6B7280")
        static let bg = main.opacity(0.2)
        static let border = main.opacity(0.3)
    }

    // MARK: - Tier Colors

    /// Free tier - Green
    struct FreeTier {
        static let main = Color(hex: "#22C55E")
        static let bg = main.opacity(0.2)
        static let text = Color(hex: "#4ADE80")
        static let border = main.opacity(0.3)
    }

    /// Standard tier - Blue
    struct StandardTier {
        static let main = Color(hex: "#3B82F6")
        static let bg = main.opacity(0.2)
        static let text = Color(hex: "#60A5FA")
        static let border = main.opacity(0.3)
    }

    /// Premium tier - Purple
    struct PremiumTier {
        static let main = Color(hex: "#A855F7")
        static let bg = main.opacity(0.2)
        static let text = Color(hex: "#C084FC")
        static let border = main.opacity(0.3)
    }

    // MARK: - Status Colors

    /// Success/Completed - Green
    static let success = Color(hex: "#22C55E")
    static let successBg = success.opacity(0.1)
    static let successText = Color(hex: "#4ADE80")
    static let successBorder = success.opacity(0.3)

    /// Error/Failed - Red
    static let error = Color(hex: "#EF4444")
    static let errorBg = error.opacity(0.1)
    static let errorText = Color(hex: "#F87171")
    static let errorBorder = error.opacity(0.3)

    /// Warning - Yellow
    static let warning = Color(hex: "#EAB308")
    static let warningBg = warning.opacity(0.1)
    static let warningText = Color(hex: "#FACC15")
    static let warningBorder = warning.opacity(0.3)

    /// Info/Processing - Blue
    static let info = blue500
    static let infoBg = blue500.opacity(0.1)
    static let infoText = blue400

    // MARK: - Featured/Highlight

    static let featured = Color(hex: "#FACC15") // Yellow for stars/featured
    static let featuredGradient = LinearGradient(
        colors: [Color(hex: "#F59E0B"), Color(hex: "#EAB308")],
        startPoint: .leading,
        endPoint: .trailing
    )
}

// MARK: - Color Extension for Hex Support

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - Category Color Helper

extension LGColors {
    /// Get category colors by slug
    static func categoryColor(for slug: String) -> (main: Color, bg: Color, border: Color) {
        switch slug {
        case "video-generation":
            return (VideoGeneration.main, VideoGeneration.bg, VideoGeneration.border)
        case "image-generation":
            return (ImageGeneration.main, ImageGeneration.bg, ImageGeneration.border)
        case "image-editing":
            return (ImageEditing.main, ImageEditing.bg, ImageEditing.border)
        case "text-generation":
            return (TextGeneration.main, TextGeneration.bg, TextGeneration.border)
        case "audio-speech":
            return (AudioSpeech.main, AudioSpeech.bg, AudioSpeech.border)
        case "music-generation":
            return (MusicGeneration.main, MusicGeneration.bg, MusicGeneration.border)
        case "upscaling":
            return (Upscaling.main, Upscaling.bg, Upscaling.border)
        case "vision-documents":
            return (VisionDocuments.main, VisionDocuments.bg, VisionDocuments.border)
        case "3d-models":
            return (ThreeDModels.main, ThreeDModels.bg, ThreeDModels.border)
        case "face-avatar":
            return (FaceAvatar.main, FaceAvatar.bg, FaceAvatar.border)
        case "utility":
            return (Utility.main, Utility.bg, Utility.border)
        default:
            return (Utility.main, Utility.bg, Utility.border)
        }
    }

    /// Get tier colors by tier name
    static func tierColor(for tier: String) -> (main: Color, bg: Color, text: Color, border: Color) {
        switch tier.lowercased() {
        case "free":
            return (FreeTier.main, FreeTier.bg, FreeTier.text, FreeTier.border)
        case "premium":
            return (PremiumTier.main, PremiumTier.bg, PremiumTier.text, PremiumTier.border)
        default: // standard
            return (StandardTier.main, StandardTier.bg, StandardTier.text, StandardTier.border)
        }
    }
}
