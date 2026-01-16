//
//  LGButton.swift
//  LuidGPT
//
//  Reusable Button Component
//  Matches web app button styles with haptic feedback
//

import SwiftUI

/// Button style variants
enum LGButtonStyle {
    case primary
    case secondary
    case outline
    case ghost
    case danger
}

/// Button size variants
enum LGButtonSize {
    case small
    case medium
    case large

    var height: CGFloat {
        switch self {
        case .small: return 36
        case .medium: return 44
        case .large: return 52
        }
    }

    var fontSize: Font {
        switch self {
        case .small: return LGFonts.small
        case .medium: return LGFonts.body
        case .large: return LGFonts.bodyMedium
        }
    }

    var padding: EdgeInsets {
        switch self {
        case .small:
            return EdgeInsets(top: 8, leading: 12, bottom: 8, trailing: 12)
        case .medium:
            return EdgeInsets(top: 12, leading: 16, bottom: 12, trailing: 16)
        case .large:
            return EdgeInsets(top: 16, leading: 24, bottom: 16, trailing: 24)
        }
    }
}

/// LuidGPT Button Component
struct LGButton: View {
    let title: String
    let icon: String? // SF Symbol name
    let iconPosition: IconPosition
    let style: LGButtonStyle
    let size: LGButtonSize
    let isLoading: Bool
    let isDisabled: Bool
    let fullWidth: Bool
    let action: () -> Void

    enum IconPosition {
        case leading
        case trailing
    }

    init(
        _ title: String,
        icon: String? = nil,
        iconPosition: IconPosition = .leading,
        style: LGButtonStyle = .primary,
        size: LGButtonSize = .medium,
        isLoading: Bool = false,
        isDisabled: Bool = false,
        fullWidth: Bool = false,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.icon = icon
        self.iconPosition = iconPosition
        self.style = style
        self.size = size
        self.isLoading = isLoading
        self.isDisabled = isDisabled
        self.fullWidth = fullWidth
        self.action = action
    }

    var body: some View {
        Button(action: {
            if !isLoading && !isDisabled {
                // Haptic feedback
                let generator = UIImpactFeedbackGenerator(style: .medium)
                generator.impactOccurred()
                action()
            }
        }) {
            HStack(spacing: 8) {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: textColor))
                        .scaleEffect(0.8)
                } else {
                    if iconPosition == .leading, let icon = icon {
                        Image(systemName: icon)
                            .font(.system(size: 16, weight: .semibold))
                    }

                    Text(title)
                        .font(size.fontSize)
                        .fontWeight(.semibold)

                    if iconPosition == .trailing, let icon = icon {
                        Image(systemName: icon)
                            .font(.system(size: 16, weight: .semibold))
                    }
                }
            }
            .foregroundColor(textColor)
            .padding(size.padding)
            .frame(maxWidth: fullWidth ? .infinity : nil)
            .frame(height: size.height)
            .background(backgroundColor)
            .cornerRadius(LGSpacing.buttonRadius)
            .overlay(
                RoundedRectangle(cornerRadius: LGSpacing.buttonRadius)
                    .stroke(borderColor, lineWidth: borderWidth)
            )
            .shadow(color: shadowColor, radius: shadowRadius, x: 0, y: shadowY)
            .opacity(isDisabled || isLoading ? 0.5 : 1.0)
        }
        .disabled(isDisabled || isLoading)
    }

    // MARK: - Style Properties

    private var backgroundColor: Color {
        if isDisabled || isLoading {
            return baseBackgroundColor.opacity(0.5)
        }
        return baseBackgroundColor
    }

    private var baseBackgroundColor: Color {
        switch style {
        case .primary:
            return LGColors.foreground // Black
        case .secondary:
            return LGColors.neutral100 // Very light gray
        case .outline:
            return .clear
        case .ghost:
            return .clear
        case .danger:
            return LGColors.error
        }
    }

    private var textColor: Color {
        switch style {
        case .primary:
            return LGColors.background // White text on black
        case .secondary:
            return LGColors.foreground // Black text on light gray
        case .outline:
            return LGColors.foreground // Black text
        case .ghost:
            return LGColors.neutral600 // Medium gray
        case .danger:
            return .white
        }
    }

    private var borderColor: Color {
        switch style {
        case .outline:
            return LGColors.neutral300 // Light gray border
        case .ghost:
            return .clear
        default:
            return .clear
        }
    }

    private var borderWidth: CGFloat {
        switch style {
        case .outline:
            return 1.5
        default:
            return 0
        }
    }

    private var shadowColor: Color {
        switch style {
        case .primary:
            return Color.black.opacity(0.1)
        case .secondary:
            return Color.black.opacity(0.05)
        default:
            return .clear
        }
    }

    private var shadowRadius: CGFloat {
        switch style {
        case .primary:
            return 4
        case .secondary:
            return 2
        default:
            return 0
        }
    }

    private var shadowY: CGFloat {
        switch style {
        case .primary:
            return 2
        case .secondary:
            return 1
        default:
            return 0
        }
    }
}

// MARK: - Icon-only Button

struct LGIconButton: View {
    let icon: String
    let size: CGFloat
    let style: LGButtonStyle
    let isDisabled: Bool
    let action: () -> Void

    init(
        icon: String,
        size: CGFloat = 44,
        style: LGButtonStyle = .ghost,
        isDisabled: Bool = false,
        action: @escaping () -> Void
    ) {
        self.icon = icon
        self.size = size
        self.style = style
        self.isDisabled = isDisabled
        self.action = action
    }

    var body: some View {
        Button(action: {
            if !isDisabled {
                let generator = UIImpactFeedbackGenerator(style: .light)
                generator.impactOccurred()
                action()
            }
        }) {
            Image(systemName: icon)
                .font(.system(size: size * 0.5, weight: .semibold))
                .foregroundColor(textColor)
                .frame(width: size, height: size)
                .background(backgroundColor)
                .cornerRadius(size / 4)
                .overlay(
                    RoundedRectangle(cornerRadius: size / 4)
                        .stroke(borderColor, lineWidth: borderWidth)
                )
        }
        .disabled(isDisabled)
        .opacity(isDisabled ? 0.5 : 1.0)
    }

    private var backgroundColor: Color {
        switch style {
        case .primary:
            return LGColors.foreground // Black
        case .secondary:
            return LGColors.neutral100 // Light gray
        case .ghost:
            return .clear
        case .outline:
            return .clear
        case .danger:
            return LGColors.errorBg
        }
    }

    private var textColor: Color {
        switch style {
        case .primary:
            return LGColors.background // White
        case .secondary:
            return LGColors.foreground // Black
        case .ghost:
            return LGColors.neutral600 // Medium gray
        case .outline:
            return LGColors.foreground // Black
        case .danger:
            return LGColors.error
        }
    }

    private var borderColor: Color {
        switch style {
        case .outline:
            return LGColors.neutral300
        default:
            return .clear
        }
    }

    private var borderWidth: CGFloat {
        switch style {
        case .outline:
            return 1.5
        default:
            return 0
        }
    }
}

// MARK: - Preview

struct LGButton_Previews: PreviewProvider {
    static var previews: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("Button Styles")
                    .font(LGFonts.h3)
                    .foregroundColor(LGColors.foreground)

                LGButton("Primary Button", style: .primary, action: {})
                LGButton("Secondary Button", style: .secondary, action: {})
                LGButton("Outline Button", style: .outline, action: {})
                LGButton("Ghost Button", style: .ghost, action: {})
                LGButton("Danger Button", style: .danger, action: {})

                Divider().background(LGColors.neutral300)

                Text("With Icons")
                    .font(LGFonts.h3)
                    .foregroundColor(LGColors.foreground)

                LGButton("Generate", icon: "play.fill", style: .primary, action: {})
                LGButton("Download", icon: "arrow.down.circle", iconPosition: .trailing, style: .secondary, action: {})

                Divider().background(LGColors.neutral300)

                Text("Sizes")
                    .font(LGFonts.h3)
                    .foregroundColor(LGColors.foreground)

                LGButton("Small", size: .small, action: {})
                LGButton("Medium", size: .medium, action: {})
                LGButton("Large", size: .large, action: {})

                Divider().background(LGColors.neutral300)

                Text("States")
                    .font(LGFonts.h3)
                    .foregroundColor(LGColors.foreground)

                LGButton("Loading", isLoading: true, action: {})
                LGButton("Disabled", isDisabled: true, action: {})
                LGButton("Full Width", fullWidth: true, action: {})

                Divider().background(LGColors.neutral300)

                Text("Icon Buttons")
                    .font(LGFonts.h3)
                    .foregroundColor(LGColors.foreground)

                HStack(spacing: 16) {
                    LGIconButton(icon: "heart", action: {})
                    LGIconButton(icon: "star.fill", style: .primary, action: {})
                    LGIconButton(icon: "trash", style: .danger, action: {})
                    LGIconButton(icon: "square.and.arrow.up", style: .secondary, action: {})
                    LGIconButton(icon: "ellipsis", style: .outline, action: {})
                }
            }
            .padding()
        }
        .background(LGColors.background)
        .preferredColorScheme(.light)
    }
}
