//
//  LGCard.swift
//  LuidGPT
//
//  Reusable Card Component
//  Matches neutral-900 bg with rounded corners from web
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
        borderColor: Color? = LGColors.neutral800,
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
            .background(LGColors.neutral900)
            .cornerRadius(cornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(borderColor ?? .clear, lineWidth: borderWidth)
            )
            .shadow(color: shadow ? .black.opacity(0.3) : .clear, radius: 8, x: 0, y: 4)
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
        borderColor: Color? = LGColors.neutral800,
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
            .background(LGColors.neutral900)
            .cornerRadius(cornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(borderColor ?? .clear, lineWidth: borderWidth)
            )
            .shadow(color: shadow ? .black.opacity(0.3) : .clear, radius: 8, x: 0, y: 4)
    }
}

// MARK: - Preview

struct LGCard_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            LGCard {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Card Title")
                        .font(LGFonts.h5)
                        .foregroundColor(LGColors.foreground)
                    Text("This is a standard card with default styling matching the web app.")
                        .font(LGFonts.small)
                        .foregroundColor(LGColors.neutral400)
                }
            }

            LGCard(shadow: true) {
                Text("Card with shadow")
                    .font(LGFonts.body)
                    .foregroundColor(LGColors.foreground)
            }

            LGCard(borderColor: LGColors.blue500, borderWidth: 2) {
                Text("Card with custom border")
                    .font(LGFonts.body)
                    .foregroundColor(LGColors.foreground)
            }
        }
        .padding()
        .background(LGColors.background)
        .preferredColorScheme(.dark)
    }
}
