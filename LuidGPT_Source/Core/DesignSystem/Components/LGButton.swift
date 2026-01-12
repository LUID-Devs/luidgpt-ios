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
            .opacity(isDisabled || isLoading ? 0.6 : 1.0)
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
            return LGColors.blue600
        case .secondary:
            return LGColors.neutral800
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
            return .white
        case .secondary:
            return LGColors.foreground
        case .outline:
            return LGColors.blue400
        case .ghost:
            return LGColors.neutral300
        case .danger:
            return .white
        }
    }

    private var borderColor: Color {
        switch style {
        case .outline:
            return LGColors.neutral700
        default:
            return .clear
        }
    }

    private var borderWidth: CGFloat {
        switch style {
        case .outline:
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
        }
        .disabled(isDisabled)
    }

    private var backgroundColor: Color {
        switch style {
        case .primary:
            return LGColors.blue600
        case .secondary:
            return LGColors.neutral800
        case .ghost:
            return .clear
        case .outline:
            return .clear
        case .danger:
            return LGColors.error.opacity(0.2)
        }
    }

    private var textColor: Color {
        switch style {
        case .primary:
            return .white
        case .danger:
            return LGColors.error
        default:
            return LGColors.neutral300
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

                Divider().background(LGColors.neutral700)

                Text("With Icons")
                    .font(LGFonts.h3)
                    .foregroundColor(LGColors.foreground)

                LGButton("Generate", icon: "play.fill", style: .primary, action: {})
                LGButton("Download", icon: "arrow.down.circle", iconPosition: .trailing, style: .secondary, action: {})

                Divider().background(LGColors.neutral700)

                Text("Sizes")
                    .font(LGFonts.h3)
                    .foregroundColor(LGColors.foreground)

                LGButton("Small", size: .small, action: {})
                LGButton("Medium", size: .medium, action: {})
                LGButton("Large", size: .large, action: {})

                Divider().background(LGColors.neutral700)

                Text("States")
                    .font(LGFonts.h3)
                    .foregroundColor(LGColors.foreground)

                LGButton("Loading", isLoading: true, action: {})
                LGButton("Disabled", isDisabled: true, action: {})
                LGButton("Full Width", fullWidth: true, action: {})

                Divider().background(LGColors.neutral700)

                Text("Icon Buttons")
                    .font(LGFonts.h3)
                    .foregroundColor(LGColors.foreground)

                HStack(spacing: 16) {
                    LGIconButton(icon: "heart", action: {})
                    LGIconButton(icon: "star.fill", style: .primary, action: {})
                    LGIconButton(icon: "trash", style: .danger, action: {})
                    LGIconButton(icon: "square.and.arrow.up", style: .secondary, action: {})
                }
            }
            .padding()
        }
        .background(LGColors.background)
        .preferredColorScheme(.dark)
    }
}
