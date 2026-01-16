//
//  LGColors.swift
//  LuidGPT
//
//  Design System - Colors
//  Premium Black & White Aesthetic Theme
//  Sophisticated grayscale palette with pure black backgrounds
//

import SwiftUI

/// LuidGPT Color System - Black & White Aesthetic
/// Premium monochromatic design with high contrast and elegant grayscale variations
struct LGColors {

    // MARK: - Base Colors

    /// Pure black background (#000000)
    static let background = Color.black

    /// Secondary black background with slight elevation (#0A0A0A)
    static let backgroundElevated = Color(hex: "#0A0A0A")

    /// Tertiary background for cards (#121212)
    static let backgroundCard = Color(hex: "#121212")

    /// Primary foreground text - Pure white (#FFFFFF)
    static let foreground = Color.white

    /// Secondary foreground text - Light gray (#A3A3A3)
    static let foregroundSecondary = Color(hex: "#A3A3A3")

    /// Tertiary foreground text - Medium gray (#737373)
    static let foregroundTertiary = Color(hex: "#737373")

    // MARK: - Surface Colors (Monochrome Grays)

    static let neutral50 = Color(hex: "#FAFAFA")   // Near white
    static let neutral100 = Color(hex: "#F5F5F5")  // Very light gray
    static let neutral200 = Color(hex: "#E5E5E5")  // Light gray
    static let neutral300 = Color(hex: "#D4D4D4")  // Soft gray
    static let neutral400 = Color(hex: "#A3A3A3")  // Medium-light gray
    static let neutral500 = Color(hex: "#737373")  // Medium gray
    static let neutral600 = Color(hex: "#525252")  // Medium-dark gray
    static let neutral700 = Color(hex: "#404040")  // Dark gray
    static let neutral800 = Color(hex: "#262626")  // Very dark gray
    static let neutral900 = Color(hex: "#171717")  // Near black

    // MARK: - Primary Action Colors (Monochrome)

    /// Primary action - Bright white
    static let primary = Color.white
    static let primaryHover = Color(hex: "#F5F5F5")
    static let primaryActive = Color(hex: "#E5E5E5")

    /// Secondary action - Medium gray
    static let secondary = Color(hex: "#737373")
    static let secondaryHover = Color(hex: "#8A8A8A")
    static let secondaryActive = Color(hex: "#525252")

    // MARK: - Category Colors (11 Categories - Grayscale Spectrum)
    // Each category uses a distinct grayscale tone for differentiation

    /// Video Generation - Brightest white with subtle glow
    struct VideoGeneration {
        static let main = Color.white
        static let bg = Color.white.opacity(0.08)
        static let border = Color.white.opacity(0.20)
        static let gradient = LinearGradient(
            colors: [Color.white, Color(hex: "#F5F5F5")],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    /// Image Generation - Very light gray (95% brightness)
    struct ImageGeneration {
        static let main = Color(hex: "#F2F2F2")
        static let bg = Color(hex: "#F2F2F2").opacity(0.08)
        static let border = Color(hex: "#F2F2F2").opacity(0.20)
        static let gradient = LinearGradient(
            colors: [Color(hex: "#F2F2F2"), Color(hex: "#E8E8E8")],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    /// Image Editing - Light gray (85% brightness)
    struct ImageEditing {
        static let main = Color(hex: "#D9D9D9")
        static let bg = Color(hex: "#D9D9D9").opacity(0.08)
        static let border = Color(hex: "#D9D9D9").opacity(0.20)
        static let gradient = LinearGradient(
            colors: [Color(hex: "#D9D9D9"), Color(hex: "#CCCCCC")],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    /// Text Generation - Medium-light gray (75% brightness)
    struct TextGeneration {
        static let main = Color(hex: "#BFBFBF")
        static let bg = Color(hex: "#BFBFBF").opacity(0.08)
        static let border = Color(hex: "#BFBFBF").opacity(0.20)
        static let gradient = LinearGradient(
            colors: [Color(hex: "#BFBFBF"), Color(hex: "#B3B3B3")],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    /// Audio & Speech - Medium gray (65% brightness)
    struct AudioSpeech {
        static let main = Color(hex: "#A6A6A6")
        static let bg = Color(hex: "#A6A6A6").opacity(0.08)
        static let border = Color(hex: "#A6A6A6").opacity(0.20)
        static let gradient = LinearGradient(
            colors: [Color(hex: "#A6A6A6"), Color(hex: "#999999")],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    /// Music Generation - Medium gray (55% brightness)
    struct MusicGeneration {
        static let main = Color(hex: "#8C8C8C")
        static let bg = Color(hex: "#8C8C8C").opacity(0.08)
        static let border = Color(hex: "#8C8C8C").opacity(0.20)
        static let gradient = LinearGradient(
            colors: [Color(hex: "#8C8C8C"), Color(hex: "#808080")],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    /// Upscaling - Medium-dark gray (45% brightness)
    struct Upscaling {
        static let main = Color(hex: "#737373")
        static let bg = Color(hex: "#737373").opacity(0.08)
        static let border = Color(hex: "#737373").opacity(0.20)
        static let gradient = LinearGradient(
            colors: [Color(hex: "#737373"), Color(hex: "#666666")],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    /// Vision & Documents - Dark gray (40% brightness)
    struct VisionDocuments {
        static let main = Color(hex: "#666666")
        static let bg = Color(hex: "#666666").opacity(0.08)
        static let border = Color(hex: "#666666").opacity(0.20)
        static let gradient = LinearGradient(
            colors: [Color(hex: "#666666"), Color(hex: "#595959")],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    /// 3D Models - Darker gray (35% brightness)
    struct ThreeDModels {
        static let main = Color(hex: "#595959")
        static let bg = Color(hex: "#595959").opacity(0.08)
        static let border = Color(hex: "#595959").opacity(0.20)
        static let gradient = LinearGradient(
            colors: [Color(hex: "#595959"), Color(hex: "#4D4D4D")],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    /// Face & Avatar - Very dark gray (30% brightness)
    struct FaceAvatar {
        static let main = Color(hex: "#4D4D4D")
        static let bg = Color(hex: "#4D4D4D").opacity(0.08)
        static let border = Color(hex: "#4D4D4D").opacity(0.20)
        static let gradient = LinearGradient(
            colors: [Color(hex: "#4D4D4D"), Color(hex: "#404040")],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    /// Utility - Charcoal gray (25% brightness)
    struct Utility {
        static let main = Color(hex: "#404040")
        static let bg = Color(hex: "#404040").opacity(0.08)
        static let border = Color(hex: "#404040").opacity(0.20)
        static let gradient = LinearGradient(
            colors: [Color(hex: "#404040"), Color(hex: "#333333")],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    // MARK: - Tier Colors (Premium Grayscale)

    /// Free tier - Light gray with subtle shimmer
    struct FreeTier {
        static let main = Color(hex: "#A3A3A3")
        static let bg = Color(hex: "#A3A3A3").opacity(0.10)
        static let text = Color(hex: "#D4D4D4")
        static let border = Color(hex: "#A3A3A3").opacity(0.25)
        static let gradient = LinearGradient(
            colors: [Color(hex: "#A3A3A3"), Color(hex: "#8C8C8C")],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    /// Standard tier - Bright silver
    struct StandardTier {
        static let main = Color(hex: "#D4D4D4")
        static let bg = Color(hex: "#D4D4D4").opacity(0.10)
        static let text = Color(hex: "#F5F5F5")
        static let border = Color(hex: "#D4D4D4").opacity(0.25)
        static let gradient = LinearGradient(
            colors: [Color(hex: "#E5E5E5"), Color(hex: "#D4D4D4"), Color(hex: "#C2C2C2")],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    /// Premium tier - Pure white with platinum shimmer
    struct PremiumTier {
        static let main = Color.white
        static let bg = Color.white.opacity(0.12)
        static let text = Color.white
        static let border = Color.white.opacity(0.30)
        static let gradient = LinearGradient(
            colors: [
                Color.white,
                Color(hex: "#F5F5F5"),
                Color(hex: "#E8E8E8"),
                Color(hex: "#F5F5F5"),
                Color.white
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        // Additional platinum effect
        static let shimmer = LinearGradient(
            colors: [
                Color.white.opacity(0),
                Color.white.opacity(0.3),
                Color.white.opacity(0)
            ],
            startPoint: .leading,
            endPoint: .trailing
        )
    }

    // MARK: - Status Colors (Grayscale Tones)

    /// Success/Completed - Bright white
    static let success = Color(hex: "#FFFFFF")
    static let successBg = Color(hex: "#FFFFFF").opacity(0.10)
    static let successText = Color(hex: "#F5F5F5")
    static let successBorder = Color(hex: "#FFFFFF").opacity(0.25)
    static let successGradient = LinearGradient(
        colors: [Color.white, Color(hex: "#E8E8E8")],
        startPoint: .leading,
        endPoint: .trailing
    )

    /// Error/Failed - Medium gray
    static let error = Color(hex: "#737373")
    static let errorBg = Color(hex: "#737373").opacity(0.10)
    static let errorText = Color(hex: "#A3A3A3")
    static let errorBorder = Color(hex: "#737373").opacity(0.25)
    static let errorGradient = LinearGradient(
        colors: [Color(hex: "#737373"), Color(hex: "#595959")],
        startPoint: .leading,
        endPoint: .trailing
    )

    /// Warning - Light gray
    static let warning = Color(hex: "#BFBFBF")
    static let warningBg = Color(hex: "#BFBFBF").opacity(0.10)
    static let warningText = Color(hex: "#E5E5E5")
    static let warningBorder = Color(hex: "#BFBFBF").opacity(0.25)
    static let warningGradient = LinearGradient(
        colors: [Color(hex: "#BFBFBF"), Color(hex: "#A6A6A6")],
        startPoint: .leading,
        endPoint: .trailing
    )

    /// Info/Processing - Medium-light gray
    static let info = Color(hex: "#A3A3A3")
    static let infoBg = Color(hex: "#A3A3A3").opacity(0.10)
    static let infoText = Color(hex: "#D4D4D4")
    static let infoBorder = Color(hex: "#A3A3A3").opacity(0.25)
    static let infoGradient = LinearGradient(
        colors: [Color(hex: "#A3A3A3"), Color(hex: "#8C8C8C")],
        startPoint: .leading,
        endPoint: .trailing
    )

    // MARK: - Featured/Highlight

    /// Featured elements - Pure white with glow
    static let featured = Color.white
    static let featuredGlow = Color.white.opacity(0.40)
    static let featuredGradient = LinearGradient(
        colors: [
            Color.white,
            Color(hex: "#F5F5F5"),
            Color(hex: "#E8E8E8"),
            Color(hex: "#F5F5F5"),
            Color.white
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    // MARK: - Dividers & Borders

    /// Subtle divider line
    static let divider = Color.white.opacity(0.08)

    /// Standard border
    static let border = Color.white.opacity(0.15)

    /// Elevated border (stronger)
    static let borderElevated = Color.white.opacity(0.25)

    // MARK: - Overlays & Shadows

    /// Light overlay for modals/sheets
    static let overlay = Color.black.opacity(0.80)

    /// Glow effect for premium elements
    static let glow = Color.white.opacity(0.30)

    /// Subtle inner shadow effect
    static let innerShadow = Color.black.opacity(0.20)
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

    /// Get category gradient by slug
    static func categoryGradient(for slug: String) -> LinearGradient {
        switch slug {
        case "video-generation":
            return VideoGeneration.gradient
        case "image-generation":
            return ImageGeneration.gradient
        case "image-editing":
            return ImageEditing.gradient
        case "text-generation":
            return TextGeneration.gradient
        case "audio-speech":
            return AudioSpeech.gradient
        case "music-generation":
            return MusicGeneration.gradient
        case "upscaling":
            return Upscaling.gradient
        case "vision-documents":
            return VisionDocuments.gradient
        case "3d-models":
            return ThreeDModels.gradient
        case "face-avatar":
            return FaceAvatar.gradient
        case "utility":
            return Utility.gradient
        default:
            return Utility.gradient
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

    /// Get tier gradient by tier name
    static func tierGradient(for tier: String) -> LinearGradient {
        switch tier.lowercased() {
        case "free":
            return FreeTier.gradient
        case "premium":
            return PremiumTier.gradient
        default: // standard
            return StandardTier.gradient
        }
    }
}
