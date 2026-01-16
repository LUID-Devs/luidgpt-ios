//
//  LGLoadingView.swift
//  LuidGPT
//
//  Loading states, skeletons, and empty states
//

import SwiftUI

/// Loading view with spinner and optional message
struct LGLoadingView: View {
    let message: String?
    let size: LoadingSize

    enum LoadingSize {
        case small
        case medium
        case large

        var spinnerSize: CGFloat {
            switch self {
            case .small: return 20
            case .medium: return 32
            case .large: return 48
            }
        }
    }

    init(message: String? = nil, size: LoadingSize = .medium) {
        self.message = message
        self.size = size
    }

    var body: some View {
        VStack(spacing: 16) {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: LGColors.foreground))
                .scaleEffect(size.spinnerSize / 20)

            if let message = message {
                Text(message)
                    .font(LGFonts.small)
                    .foregroundColor(LGColors.neutral600)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(LGColors.background)
    }
}

/// Full-screen loading overlay
struct LGLoadingOverlay: View {
    let message: String

    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()

            VStack(spacing: 20) {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: LGColors.foreground))
                    .scaleEffect(1.5)

                Text(message)
                    .font(LGFonts.body)
                    .fontWeight(.medium)
                    .foregroundColor(LGColors.foreground)

                Text("This may take a moment...")
                    .font(LGFonts.small)
                    .foregroundColor(LGColors.neutral600)
            }
            .padding(32)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(LGColors.background)
                    .shadow(color: .black.opacity(0.15), radius: 24, x: 0, y: 8)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(LGColors.neutral200, lineWidth: 1)
            )
        }
    }
}

/// Empty state view
struct LGEmptyState: View {
    let icon: String
    let title: String
    let message: String
    let actionTitle: String?
    let action: (() -> Void)?

    init(
        icon: String,
        title: String,
        message: String,
        actionTitle: String? = nil,
        action: (() -> Void)? = nil
    ) {
        self.icon = icon
        self.title = title
        self.message = message
        self.actionTitle = actionTitle
        self.action = action
    }

    var body: some View {
        VStack(spacing: 20) {
            // Icon
            ZStack {
                Circle()
                    .fill(LGColors.neutral100)
                    .frame(width: 80, height: 80)

                Image(systemName: icon)
                    .font(.system(size: 32, weight: .light))
                    .foregroundColor(LGColors.neutral500)
            }

            // Text
            VStack(spacing: 8) {
                Text(title)
                    .font(LGFonts.h4)
                    .fontWeight(.semibold)
                    .foregroundColor(LGColors.foreground)

                Text(message)
                    .font(LGFonts.small)
                    .foregroundColor(LGColors.neutral600)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }

            // Action button
            if let actionTitle = actionTitle, let action = action {
                LGButton(actionTitle, style: .primary, action: action)
                    .padding(.top, 8)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(LGColors.background)
    }
}

/// Error state view
struct LGErrorView: View {
    let title: String
    let message: String
    let retryAction: (() -> Void)?

    init(
        title: String = "Something went wrong",
        message: String,
        retryAction: (() -> Void)? = nil
    ) {
        self.title = title
        self.message = message
        self.retryAction = retryAction
    }

    var body: some View {
        VStack(spacing: 20) {
            // Error icon
            ZStack {
                Circle()
                    .fill(LGColors.errorBg)
                    .frame(width: 80, height: 80)

                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 32))
                    .foregroundColor(LGColors.error)
            }

            // Text
            VStack(spacing: 8) {
                Text(title)
                    .font(LGFonts.h4)
                    .fontWeight(.semibold)
                    .foregroundColor(LGColors.foreground)

                Text(message)
                    .font(LGFonts.small)
                    .foregroundColor(LGColors.neutral600)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }

            // Retry button
            if let retryAction = retryAction {
                LGButton("Try Again", icon: "arrow.clockwise", style: .outline, action: retryAction)
                    .padding(.top, 8)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(LGColors.background)
    }
}

/// Skeleton loading card (for list items)
struct LGSkeletonCard: View {
    let hasImage: Bool

    init(hasImage: Bool = true) {
        self.hasImage = hasImage
    }

    var body: some View {
        LGCardNoPadding {
            VStack(alignment: .leading, spacing: 0) {
                // Image placeholder
                if hasImage {
                    Rectangle()
                        .fill(LGColors.neutral100)
                        .frame(height: 180)
                        .shimmer()
                }

                // Content
                VStack(alignment: .leading, spacing: 12) {
                    // Title
                    RoundedRectangle(cornerRadius: 4)
                        .fill(LGColors.neutral100)
                        .frame(height: 20)
                        .frame(maxWidth: .infinity)
                        .shimmer()

                    // Subtitle
                    RoundedRectangle(cornerRadius: 4)
                        .fill(LGColors.neutral100)
                        .frame(height: 16)
                        .frame(width: 150)
                        .shimmer()

                    // Badges
                    HStack(spacing: 8) {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(LGColors.neutral100)
                            .frame(width: 80, height: 24)
                            .shimmer()

                        RoundedRectangle(cornerRadius: 12)
                            .fill(LGColors.neutral100)
                            .frame(width: 60, height: 24)
                            .shimmer()
                    }
                }
                .padding(16)
            }
        }
    }
}

/// Skeleton row for list items
struct LGSkeletonRow: View {
    let hasIcon: Bool

    init(hasIcon: Bool = true) {
        self.hasIcon = hasIcon
    }

    var body: some View {
        HStack(spacing: 12) {
            if hasIcon {
                Circle()
                    .fill(LGColors.neutral100)
                    .frame(width: 48, height: 48)
                    .shimmer()
            }

            VStack(alignment: .leading, spacing: 8) {
                RoundedRectangle(cornerRadius: 4)
                    .fill(LGColors.neutral100)
                    .frame(height: 16)
                    .frame(maxWidth: .infinity)
                    .shimmer()

                RoundedRectangle(cornerRadius: 4)
                    .fill(LGColors.neutral100)
                    .frame(height: 14)
                    .frame(width: 120)
                    .shimmer()
            }
        }
        .padding(.vertical, 8)
    }
}

/// Minimal skeleton text lines
struct LGSkeletonText: View {
    let lines: Int
    let lastLineWidth: CGFloat

    init(lines: Int = 3, lastLineWidth: CGFloat = 0.6) {
        self.lines = lines
        self.lastLineWidth = lastLineWidth
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ForEach(0..<lines, id: \.self) { index in
                RoundedRectangle(cornerRadius: 4)
                    .fill(LGColors.neutral100)
                    .frame(height: 14)
                    .frame(maxWidth: index == lines - 1 ? .infinity : nil)
                    .frame(width: index == lines - 1 ? nil : UIScreen.main.bounds.width * lastLineWidth)
                    .shimmer()
            }
        }
    }
}

// MARK: - Shimmer Effect

struct Shimmer: ViewModifier {
    @State private var phase: CGFloat = 0

    func body(content: Content) -> some View {
        content
            .overlay(
                LinearGradient(
                    colors: [
                        .clear,
                        LGColors.neutral200.opacity(0.6),
                        .clear
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .offset(x: phase)
                .mask(content)
            )
            .onAppear {
                withAnimation(.linear(duration: 1.5).repeatForever(autoreverses: false)) {
                    phase = 300
                }
            }
    }
}

extension View {
    func shimmer() -> some View {
        modifier(Shimmer())
    }
}

// MARK: - Pulse Animation for Loading States

struct Pulse: ViewModifier {
    @State private var isAnimating = false

    func body(content: Content) -> some View {
        content
            .opacity(isAnimating ? 0.4 : 1.0)
            .onAppear {
                withAnimation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
                    isAnimating = true
                }
            }
    }
}

extension View {
    func pulse() -> some View {
        modifier(Pulse())
    }
}

// MARK: - Preview

struct LGLoadingView_Previews: PreviewProvider {
    static var previews: some View {
        TabView {
            // Loading views
            VStack(spacing: 40) {
                LGLoadingView(size: .small)
                LGLoadingView(message: "Loading models...", size: .medium)
                LGLoadingView(message: "Generating...", size: .large)
            }
            .tabItem {
                Label("Loading", systemImage: "arrow.clockwise")
            }

            // Empty state
            LGEmptyState(
                icon: "square.stack.3d.up.slash",
                title: "No models found",
                message: "Try adjusting your filters or search terms",
                actionTitle: "Clear Filters",
                action: {}
            )
            .tabItem {
                Label("Empty", systemImage: "tray")
            }

            // Error state
            LGErrorView(
                message: "Unable to load models. Please check your internet connection.",
                retryAction: {}
            )
            .tabItem {
                Label("Error", systemImage: "exclamationmark.triangle")
            }

            // Skeleton
            ScrollView {
                VStack(spacing: 16) {
                    LGSkeletonCard()
                    LGSkeletonCard(hasImage: false)

                    Divider().background(LGColors.neutral300)

                    ForEach(0..<3) { _ in
                        LGSkeletonRow()
                    }

                    Divider().background(LGColors.neutral300)

                    LGSkeletonText(lines: 4)
                }
                .padding()
            }
            .background(LGColors.background)
            .tabItem {
                Label("Skeleton", systemImage: "rectangle.on.rectangle")
            }
        }
        .preferredColorScheme(.light)
    }
}
