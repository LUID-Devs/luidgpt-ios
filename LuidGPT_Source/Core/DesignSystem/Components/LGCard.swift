//
//  LGCard.swift
//  LuidGPT
//
//  Reusable Card Component
//  Light card with subtle background and borders
//

import SwiftUI

/// LuidGPT Card Component
/// Standard card style matching the web app's design
struct LGCard<Content: View>: View {
    let content: Content
    let padding: CGFloat
    let cornerRadius: CGFloat
    let borderColor: Color?
    let borderWidth: CGFloat
    let shadow: Bool

    init(
        padding: CGFloat = LGSpacing.cardPadding,
        cornerRadius: CGFloat = LGSpacing.cardRadius,
        borderColor: Color? = LGColors.neutral200,
        borderWidth: CGFloat = 1,
        shadow: Bool = false,
        @ViewBuilder content: () -> Content
    ) {
        self.padding = padding
        self.cornerRadius = cornerRadius
        self.borderColor = borderColor
        self.borderWidth = borderWidth
        self.shadow = shadow
        self.content = content()
    }

    var body: some View {
        content
            .padding(padding)
            .background(LGColors.background) // Pure white background
            .cornerRadius(cornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(borderColor ?? LGColors.neutral200, lineWidth: borderWidth)
            )
            .shadow(
                color: shadow ? Color.black.opacity(0.08) : .clear,
                radius: shadow ? 12 : 0,
                x: 0,
                y: shadow ? 4 : 0
            )
    }
}

/// Variant: LGCardNoPadding - For custom padding control
struct LGCardNoPadding<Content: View>: View {
    let content: Content
    let cornerRadius: CGFloat
    let borderColor: Color?
    let borderWidth: CGFloat
    let shadow: Bool

    init(
        cornerRadius: CGFloat = LGSpacing.cardRadius,
        borderColor: Color? = LGColors.neutral200,
        borderWidth: CGFloat = 1,
        shadow: Bool = false,
        @ViewBuilder content: () -> Content
    ) {
        self.cornerRadius = cornerRadius
        self.borderColor = borderColor
        self.borderWidth = borderWidth
        self.shadow = shadow
        self.content = content()
    }

    var body: some View {
        content
            .background(LGColors.background) // Pure white background
            .cornerRadius(cornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(borderColor ?? LGColors.neutral200, lineWidth: borderWidth)
            )
            .shadow(
                color: shadow ? Color.black.opacity(0.08) : .clear,
                radius: shadow ? 12 : 0,
                x: 0,
                y: shadow ? 4 : 0
            )
    }
}

/// Elevated card variant with stronger shadow
struct LGCardElevated<Content: View>: View {
    let content: Content
    let padding: CGFloat
    let cornerRadius: CGFloat

    init(
        padding: CGFloat = LGSpacing.cardPadding,
        cornerRadius: CGFloat = LGSpacing.cardRadius,
        @ViewBuilder content: () -> Content
    ) {
        self.padding = padding
        self.cornerRadius = cornerRadius
        self.content = content()
    }

    var body: some View {
        content
            .padding(padding)
            .background(LGColors.background)
            .cornerRadius(cornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(LGColors.neutral200, lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 2)
            .shadow(color: Color.black.opacity(0.04), radius: 16, x: 0, y: 4)
    }
}

/// Subtle card variant with minimal border, no shadow
struct LGCardSubtle<Content: View>: View {
    let content: Content
    let padding: CGFloat
    let cornerRadius: CGFloat

    init(
        padding: CGFloat = LGSpacing.cardPadding,
        cornerRadius: CGFloat = LGSpacing.cardRadius,
        @ViewBuilder content: () -> Content
    ) {
        self.padding = padding
        self.cornerRadius = cornerRadius
        self.content = content()
    }

    var body: some View {
        content
            .padding(padding)
            .background(LGColors.neutral50) // Very subtle gray background
            .cornerRadius(cornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(LGColors.neutral200, lineWidth: 0.5)
            )
    }
}

// MARK: - Preview

struct LGCard_Previews: PreviewProvider {
    static var previews: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("Card Variants")
                    .font(LGFonts.h3)
                    .foregroundColor(LGColors.foreground)

                LGCard {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Standard Card")
                            .font(LGFonts.h5)
                            .foregroundColor(LGColors.foreground)
                        Text("Clean white background with subtle gray border for definition.")
                            .font(LGFonts.small)
                            .foregroundColor(LGColors.neutral600)
                    }
                }

                LGCard(shadow: true) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Card with Shadow")
                            .font(LGFonts.h5)
                            .foregroundColor(LGColors.foreground)
                        Text("Subtle shadow provides elevation and depth.")
                            .font(LGFonts.small)
                            .foregroundColor(LGColors.neutral600)
                    }
                }

                LGCardElevated {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Elevated Card")
                            .font(LGFonts.h5)
                            .foregroundColor(LGColors.foreground)
                        Text("Multi-layer shadow for stronger emphasis.")
                            .font(LGFonts.small)
                            .foregroundColor(LGColors.neutral600)
                    }
                }

                LGCardSubtle {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Subtle Card")
                            .font(LGFonts.h5)
                            .foregroundColor(LGColors.foreground)
                        Text("Minimal styling with light gray background.")
                            .font(LGFonts.small)
                            .foregroundColor(LGColors.neutral600)
                    }
                }

                LGCard(borderColor: LGColors.foreground, borderWidth: 2) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Bold Border Card")
                            .font(LGFonts.h5)
                            .foregroundColor(LGColors.foreground)
                        Text("Strong black border for emphasis.")
                            .font(LGFonts.small)
                            .foregroundColor(LGColors.neutral600)
                    }
                }
            }
            .padding()
        }
        .background(LGColors.neutral50)
        .preferredColorScheme(.light)
    }
}
