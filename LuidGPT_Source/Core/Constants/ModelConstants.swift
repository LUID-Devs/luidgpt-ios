//
//  ModelConstants.swift
//  LuidGPT
//
//  Constants for model categories, colors, icons, and styling
//

import SwiftUI

// MARK: - Model Category Constants

enum ModelCategoryConstants {
    /// Category colors (matching web design)
    static let categoryColors: [String: (background: Color, foreground: Color)] = [
        "video-generation": (
            background: Color(red: 0.55, green: 0.27, blue: 0.07).opacity(0.2), // Purple-pink gradient
            foreground: Color(red: 0.75, green: 0.43, blue: 0.67)
        ),
        "image-generation": (
            background: Color.blue.opacity(0.2),
            foreground: Color.blue
        ),
        "image-editing": (
            background: Color.orange.opacity(0.2),
            foreground: Color.orange
        ),
        "text-generation": (
            background: Color.green.opacity(0.2),
            foreground: Color.green
        ),
        "audio-speech": (
            background: Color.teal.opacity(0.2),
            foreground: Color.teal
        ),
        "music-generation": (
            background: Color.pink.opacity(0.2),
            foreground: Color.pink
        ),
        "upscaling": (
            background: Color.cyan.opacity(0.2),
            foreground: Color.cyan
        ),
        "vision-documents": (
            background: Color.indigo.opacity(0.2),
            foreground: Color.indigo
        ),
        "3d-models": (
            background: Color.purple.opacity(0.2),
            foreground: Color.purple
        ),
        "face-avatar": (
            background: Color.mint.opacity(0.2),
            foreground: Color.mint
        ),
        "utility": (
            background: Color.gray.opacity(0.2),
            foreground: Color.gray
        )
    ]

    /// Get category colors
    static func colors(for slug: String) -> (background: Color, foreground: Color) {
        return categoryColors[slug] ?? (background: Color.gray.opacity(0.2), foreground: Color.gray)
    }

    /// Get category SF Symbol icon
    static func icon(for slug: String) -> String {
        return Category.icon(for: slug)
    }
}

// MARK: - Model Tier Constants

enum ModelTierConstants {
    /// Tier colors and styles
    static let tierColors: [String: (background: Color, foreground: Color)] = [
        "free": (
            background: Color.green.opacity(0.2),
            foreground: Color.green
        ),
        "standard": (
            background: Color.blue.opacity(0.2),
            foreground: Color.blue
        ),
        "premium": (
            background: Color.purple.opacity(0.2),
            foreground: Color.purple
        ),
        "enterprise": (
            background: Color.orange.opacity(0.2),
            foreground: Color.orange
        )
    ]

    /// Get tier colors
    static func colors(for tier: ReplicateModel.Tier) -> (background: Color, foreground: Color) {
        return tierColors[tier.rawValue] ?? (background: Color.gray.opacity(0.2), foreground: Color.gray)
    }

    /// Get tier badge text
    static func badgeText(for tier: ReplicateModel.Tier) -> String {
        return tier.displayName
    }
}

// MARK: - Model Card Styles

enum ModelCardStyle {
    /// Card corner radius
    static let cornerRadius: CGFloat = 12

    /// Card shadow
    static let shadowRadius: CGFloat = 8
    static let shadowOpacity: Double = 0.1

    /// Card aspect ratios
    static let imageAspectRatio: CGFloat = 16/10
    static let compactHeight: CGFloat = 80

    /// Spacing
    static let padding: CGFloat = 12
    static let iconSize: CGFloat = 40
    static let badgeIconSize: CGFloat = 12
}

// MARK: - Speed Tag Styles

enum SpeedTagConstants {
    /// Speed tag colors
    static let speedColors: [String: Color] = [
        "instant": .green,
        "fast": .blue,
        "slow": .orange
    ]

    /// Get speed color
    static func color(for speed: String) -> Color {
        return speedColors[speed] ?? .gray
    }

    /// Get speed display text
    static func displayText(for speed: String) -> String {
        switch speed {
        case "instant": return "<5s"
        case "fast": return "Fast"
        case "slow": return "Slow"
        default: return speed.capitalized
        }
    }
}

// MARK: - Feature Tag Styles

enum FeatureTagStyle {
    /// Feature colors
    static let colors: (background: Color, foreground: Color) = (
        background: Color.secondary.opacity(0.2),
        foreground: Color.secondary
    )

    /// Feature icon mapping
    static let featureIcons: [String: String] = [
        "text-to-video": "video.fill",
        "text-to-image": "photo.fill",
        "image-to-video": "arrow.right.doc.on.clipboard",
        "text-to-speech": "speaker.wave.2.fill",
        "voice-cloning": "waveform",
        "face-swap": "person.2.fill",
        "upscaling": "arrow.up.right.square.fill",
        "background-removal": "rectangle.split.3x1",
        "style-transfer": "paintbrush.fill"
    ]

    /// Get feature icon
    static func icon(for feature: String) -> String? {
        return featureIcons[feature]
    }
}

// MARK: - Grid Layout

enum ModelGridLayout {
    /// Grid columns for different screen sizes
    static let columns: [GridItem] = {
        #if os(iOS)
        return [
            GridItem(.adaptive(minimum: 160, maximum: 200), spacing: 12)
        ]
        #else
        return [
            GridItem(.adaptive(minimum: 200, maximum: 250), spacing: 16)
        ]
        #endif
    }()

    /// Compact grid for list view
    static let compactColumns: [GridItem] = [
        GridItem(.flexible(), spacing: 8)
    ]
}

// MARK: - Animation Constants

enum ModelAnimationConstants {
    static let cardAppearDuration: Double = 0.3
    static let cardAppearDelay: Double = 0.05 // delay per item
    static let cardHoverScale: CGFloat = 1.02
    static let cardTapScale: CGFloat = 0.98
}

// MARK: - Search Constants

enum ModelSearchConstants {
    static let searchDebounce: Double = 0.3 // seconds
    static let minSearchLength: Int = 2
    static let placeholder = "Search models..."
    static let recentSearchesLimit = 5
}

// MARK: - Pagination Constants

enum ModelPaginationConstants {
    static let defaultPageSize = 20
    static let loadMoreThreshold = 5 // items from end to trigger load more
}

// MARK: - Credit Display

enum CreditDisplayConstants {
    /// Credit badge colors by range
    static func creditColor(for credits: Int) -> Color {
        switch credits {
        case 0...1:
            return .green
        case 2...5:
            return .blue
        case 6...10:
            return .purple
        default:
            return .orange
        }
    }

    /// Format credits for display
    static func formatCredits(_ credits: Int) -> String {
        if credits == 1 {
            return "\(credits) credit"
        } else {
            return "\(credits) credits"
        }
    }

    /// Short format for compact display
    static func formatCreditsShort(_ credits: Int) -> String {
        return "\(credits) cr"
    }
}

// MARK: - Empty State Messages

enum ModelEmptyStateConstants {
    static let noModels = "No models found"
    static let noModelsDescription = "Try adjusting your search or filters"
    static let noFeaturedModels = "No featured models available"
    static let noSearchResults = "No results found"
    static let noSearchResultsDescription = "Try different search terms"
    static let loadingModels = "Loading models..."
    static let loadingCategories = "Loading categories..."
}
