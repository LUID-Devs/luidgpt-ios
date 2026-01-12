//
//  LGBadge.swift
//  LuidGPT
//
//  Reusable Badge Component
//  For categories, tiers, status indicators, and tags
//

import SwiftUI

/// Badge style variants
enum LGBadgeStyle {
    case category(String) // category slug
    case tier(String) // tier name
    case status(Status)
    case custom(bg: Color, text: Color, border: Color?)

    enum Status {
        case success
        case error
        case warning
        case info
        case processing
    }
}

/// Badge size variants
enum LGBadgeSize {
    case small
    case medium
    case large

    var fontSize: Font {
        switch self {
        case .small: return LGFonts.tiny
        case .medium: return LGFonts.caption
        case .large: return LGFonts.small
        }
    }

    var padding: EdgeInsets {
        switch self {
        case .small:
            return EdgeInsets(top: 2, leading: 6, bottom: 2, trailing: 6)
        case .medium:
            return EdgeInsets(top: 4, leading: 8, bottom: 4, trailing: 8)
        case .large:
            return EdgeInsets(top: 6, leading: 12, bottom: 6, trailing: 12)
        }
    }

    var iconSize: CGFloat {
        switch self {
        case .small: return 10
        case .medium: return 12
        case .large: return 14
        }
    }
}

/// LuidGPT Badge Component
struct LGBadge: View {
    let text: String
    let icon: String? // SF Symbol name
    let style: LGBadgeStyle
    let size: LGBadgeSize

    init(
        _ text: String,
        icon: String? = nil,
        style: LGBadgeStyle = .custom(bg: LGColors.neutral800, text: LGColors.neutral300, border: nil),
        size: LGBadgeSize = .medium
    ) {
        self.text = text
        self.icon = icon
        self.style = style
        self.size = size
    }

    var body: some View {
        HStack(spacing: 4) {
            if let icon = icon {
                Image(systemName: icon)
                    .font(.system(size: size.iconSize, weight: .semibold))
            }

            Text(text)
                .font(size.fontSize)
                .fontWeight(.medium)
        }
        .foregroundColor(textColor)
        .padding(size.padding)
        .background(backgroundColor)
        .cornerRadius(LGSpacing.badgeRadius)
        .overlay(
            RoundedRectangle(cornerRadius: LGSpacing.badgeRadius)
                .stroke(borderColor ?? .clear, lineWidth: borderWidth)
        )
    }

    // MARK: - Style Properties

    private var backgroundColor: Color {
        switch style {
        case .category(let slug):
            let colors = LGColors.categoryColor(for: slug)
            return colors.bg
        case .tier(let tier):
            let colors = LGColors.tierColor(for: tier)
            return colors.bg
        case .status(let status):
            switch status {
            case .success:
                return LGColors.successBg
            case .error:
                return LGColors.errorBg
            case .warning:
                return LGColors.warningBg
            case .info:
                return LGColors.infoBg
            case .processing:
                return LGColors.blue500.opacity(0.2)
            }
        case .custom(let bg, _, _):
            return bg
        }
    }

    private var textColor: Color {
        switch style {
        case .category(let slug):
            let colors = LGColors.categoryColor(for: slug)
            return colors.main
        case .tier(let tier):
            let colors = LGColors.tierColor(for: tier)
            return colors.text
        case .status(let status):
            switch status {
            case .success:
                return LGColors.successText
            case .error:
                return LGColors.errorText
            case .warning:
                return LGColors.warningText
            case .info:
                return LGColors.infoText
            case .processing:
                return LGColors.blue400
            }
        case .custom(_, let text, _):
            return text
        }
    }

    private var borderColor: Color? {
        switch style {
        case .custom(_, _, let border):
            return border
        default:
            return nil
        }
    }

    private var borderWidth: CGFloat {
        borderColor != nil ? 1 : 0
    }
}

// MARK: - Credit Badge

/// Special badge for displaying credit costs
struct LGCreditBadge: View {
    let credits: Int
    let tier: String
    let size: LGBadgeSize

    init(
        credits: Int,
        tier: String = "standard",
        size: LGBadgeSize = .medium
    ) {
        self.credits = credits
        self.tier = tier
        self.size = size
    }

    var body: some View {
        LGBadge(
            "\(credits) \(credits == 1 ? "credit" : "credits")",
            icon: "sparkles",
            style: .tier(tier),
            size: size
        )
    }
}

// MARK: - Status Badge with Dot

/// Badge with a status dot indicator
struct LGStatusBadge: View {
    let text: String
    let status: LGBadgeStyle.Status
    let size: LGBadgeSize

    init(
        _ text: String,
        status: LGBadgeStyle.Status,
        size: LGBadgeSize = .medium
    ) {
        self.text = text
        self.status = status
        self.size = size
    }

    var body: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(dotColor)
                .frame(width: dotSize, height: dotSize)

            Text(text)
                .font(size.fontSize)
                .fontWeight(.medium)
                .foregroundColor(textColor)
        }
        .padding(size.padding)
        .background(backgroundColor)
        .cornerRadius(LGSpacing.badgeRadius)
    }

    private var dotSize: CGFloat {
        switch size {
        case .small: return 6
        case .medium: return 8
        case .large: return 10
        }
    }

    private var dotColor: Color {
        switch status {
        case .success:
            return LGColors.success
        case .error:
            return LGColors.error
        case .warning:
            return LGColors.warning
        case .info:
            return LGColors.info
        case .processing:
            return LGColors.blue500
        }
    }

    private var textColor: Color {
        switch status {
        case .success:
            return LGColors.successText
        case .error:
            return LGColors.errorText
        case .warning:
            return LGColors.warningText
        case .info:
            return LGColors.infoText
        case .processing:
            return LGColors.blue400
        }
    }

    private var backgroundColor: Color {
        switch status {
        case .success:
            return LGColors.successBg
        case .error:
            return LGColors.errorBg
        case .warning:
            return LGColors.warningBg
        case .info:
            return LGColors.infoBg
        case .processing:
            return LGColors.blue500.opacity(0.1)
        }
    }
}

// MARK: - Preview

struct LGBadge_Previews: PreviewProvider {
    static var previews: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                Text("Category Badges")
                    .font(LGFonts.h4)
                    .foregroundColor(LGColors.foreground)

                FlowLayout(spacing: 8) {
                    LGBadge("Video Generation", style: .category("video-generation"))
                    LGBadge("Image Generation", style: .category("image-generation"))
                    LGBadge("Image Editing", style: .category("image-editing"))
                    LGBadge("Text Generation", style: .category("text-generation"))
                    LGBadge("Audio & Speech", style: .category("audio-speech"))
                    LGBadge("Music", style: .category("music-generation"))
                    LGBadge("Upscaling", style: .category("upscaling"))
                    LGBadge("Vision", style: .category("vision-documents"))
                    LGBadge("3D Models", style: .category("3d-models"))
                    LGBadge("Face & Avatar", style: .category("face-avatar"))
                    LGBadge("Utility", style: .category("utility"))
                }

                Divider().background(LGColors.neutral700)

                Text("Tier Badges")
                    .font(LGFonts.h4)
                    .foregroundColor(LGColors.foreground)

                HStack(spacing: 12) {
                    LGBadge("Free", style: .tier("free"))
                    LGBadge("Standard", style: .tier("standard"))
                    LGBadge("Premium", style: .tier("premium"))
                }

                Divider().background(LGColors.neutral700)

                Text("Credit Badges")
                    .font(LGFonts.h4)
                    .foregroundColor(LGColors.foreground)

                HStack(spacing: 12) {
                    LGCreditBadge(credits: 1, tier: "free", size: .small)
                    LGCreditBadge(credits: 5, tier: "standard")
                    LGCreditBadge(credits: 10, tier: "premium", size: .large)
                }

                Divider().background(LGColors.neutral700)

                Text("Status Badges")
                    .font(LGFonts.h4)
                    .foregroundColor(LGColors.foreground)

                VStack(alignment: .leading, spacing: 8) {
                    LGBadge("Success", icon: "checkmark.circle.fill", style: .status(.success))
                    LGBadge("Error", icon: "xmark.circle.fill", style: .status(.error))
                    LGBadge("Warning", icon: "exclamationmark.triangle.fill", style: .status(.warning))
                    LGBadge("Info", icon: "info.circle.fill", style: .status(.info))
                    LGBadge("Processing", icon: "arrow.clockwise", style: .status(.processing))
                }

                Divider().background(LGColors.neutral700)

                Text("Status Badges with Dots")
                    .font(LGFonts.h4)
                    .foregroundColor(LGColors.foreground)

                VStack(alignment: .leading, spacing: 8) {
                    LGStatusBadge("Completed", status: .success)
                    LGStatusBadge("Failed", status: .error)
                    LGStatusBadge("Pending", status: .warning)
                    LGStatusBadge("Processing", status: .processing)
                }

                Divider().background(LGColors.neutral700)

                Text("Badge Sizes")
                    .font(LGFonts.h4)
                    .foregroundColor(LGColors.foreground)

                VStack(alignment: .leading, spacing: 8) {
                    LGBadge("Small", icon: "star.fill", style: .tier("premium"), size: .small)
                    LGBadge("Medium", icon: "star.fill", style: .tier("premium"), size: .medium)
                    LGBadge("Large", icon: "star.fill", style: .tier("premium"), size: .large)
                }
            }
            .padding()
        }
        .background(LGColors.background)
        .preferredColorScheme(.dark)
    }
}

// MARK: - FlowLayout Helper

struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(
            in: proposal.replacingUnspecifiedDimensions().width,
            subviews: subviews,
            spacing: spacing
        )
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(
            in: bounds.width,
            subviews: subviews,
            spacing: spacing
        )
        for (index, subview) in subviews.enumerated() {
            subview.place(at: CGPoint(x: bounds.minX + result.positions[index].x, y: bounds.minY + result.positions[index].y), proposal: .unspecified)
        }
    }

    struct FlowResult {
        var size: CGSize = .zero
        var positions: [CGPoint] = []

        init(in maxWidth: CGFloat, subviews: Subviews, spacing: CGFloat) {
            var x: CGFloat = 0
            var y: CGFloat = 0
            var lineHeight: CGFloat = 0

            for subview in subviews {
                let size = subview.sizeThatFits(.unspecified)

                if x + size.width > maxWidth && x > 0 {
                    x = 0
                    y += lineHeight + spacing
                    lineHeight = 0
                }

                positions.append(CGPoint(x: x, y: y))
                lineHeight = max(lineHeight, size.height)
                x += size.width + spacing
            }

            self.size = CGSize(width: maxWidth, height: y + lineHeight)
        }
    }
}
