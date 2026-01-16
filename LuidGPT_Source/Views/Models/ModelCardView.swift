//
//  ModelCardView.swift
//  LuidGPT
//
//  Card component for displaying individual AI models
//

import SwiftUI

struct ModelCardView: View {
    let model: ReplicateModel
    var showCategory: Bool = true

    @State private var isPressed = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Model image or icon placeholder
            modelImageSection
                .frame(height: 110)

            // Model info section
            VStack(alignment: .leading, spacing: 6) {
                // Title and featured badge
                HStack(alignment: .top, spacing: 6) {
                    Text(model.name)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                        .lineLimit(1)

                    if model.isFeatured {
                        Image(systemName: "star.fill")
                            .font(.system(size: 10))
                            .foregroundColor(Color.white.opacity(0.8))
                    }

                    Spacer(minLength: 0)
                }

                // Provider
                if let provider = model.providerDisplayName {
                    Text("by \(provider)")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(Color.white.opacity(0.5))
                        .lineLimit(1)
                }

                // Description
                if let description = model.description {
                    Text(description)
                        .font(.system(size: 11))
                        .foregroundColor(Color.white.opacity(0.6))
                        .lineLimit(2)
                }

                Spacer(minLength: 4)

                // Tags section
                VStack(spacing: 6) {
                    HStack(spacing: 6) {
                        // Category badge
                        if showCategory {
                            categoryBadge
                        }

                        // Speed badge
                        if let speedTag = model.speedTag {
                            speedBadge(speedTag)
                        }

                        Spacer(minLength: 0)
                    }

                    HStack {
                        Spacer()
                        // Credit cost
                        creditBadge
                    }
                }
            }
            .padding(10)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(maxWidth: .infinity)
        .background(Color.black)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.white.opacity(0.2), lineWidth: 1)
        )
        .shadow(color: Color.white.opacity(0.05), radius: 8, x: 0, y: 4)
        .scaleEffect(isPressed ? ModelAnimationConstants.cardTapScale : 1.0)
        .animation(.easeInOut(duration: 0.1), value: isPressed)
    }

    // MARK: - Subviews

    @ViewBuilder
    private var modelImageSection: some View {
        if let imageURL = model.displayImage, let url = URL(string: imageURL) {
            AsyncImage(url: url) { phase in
                switch phase {
                case .empty:
                    placeholder
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFill()
                case .failure:
                    placeholder
                @unknown default:
                    placeholder
                }
            }
            .frame(maxWidth: .infinity)
            .clipped()
        } else {
            placeholder
                .frame(maxWidth: .infinity)
        }
    }

    private var placeholder: some View {
        ZStack {
            // Grayscale category background
            categoryGrayscaleColor(for: model.categorySlug)

            Image(systemName: Category.icon(for: model.categorySlug))
                .font(.system(size: 36, weight: .regular))
                .foregroundColor(.white)
        }
    }

    @ViewBuilder
    private var categoryBadge: some View {
        if let category = model.category {
            let grayscale = categoryGrayscaleColor(for: category.slug)

            HStack(spacing: 3) {
                Image(systemName: Category.icon(for: category.slug))
                    .font(.system(size: 9, weight: .bold))
                Text(category.name)
                    .font(.system(size: 10, weight: .bold))
                    .lineLimit(1)
            }
            .padding(.horizontal, 7)
            .padding(.vertical, 4)
            .background(grayscale)
            .foregroundColor(.white)
            .cornerRadius(5)
        }
    }

    private func speedBadge(_ speed: String) -> some View {
        let badgeColor = speedGrayscaleColor(for: speed)

        return HStack(spacing: 2) {
            Image(systemName: "bolt.fill")
                .font(.system(size: 8, weight: .bold))
            Text(SpeedTagConstants.displayText(for: speed))
                .font(.system(size: 10, weight: .bold))
                .lineLimit(1)
        }
        .padding(.horizontal, 7)
        .padding(.vertical, 4)
        .background(badgeColor)
        .foregroundColor(.white)
        .cornerRadius(5)
    }

    private var creditBadge: some View {
        let credits = model.creditCost ?? 2
        let tierGrayscale = tierGrayscaleColor(for: model.tier)

        return HStack(spacing: 3) {
            Image(systemName: "sparkles")
                .font(.system(size: 9, weight: .bold))
            Text("\(credits)")
                .font(.system(size: 12, weight: .black))
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(tierGrayscale)
        .foregroundColor(.white)
        .cornerRadius(5)
    }

    // MARK: - Grayscale Colors

    private func categoryGrayscaleColor(for slug: String) -> Color {
        switch slug {
        case "text-to-image": return Color(white: 0.2)
        case "text-to-video": return Color(white: 0.25)
        case "image-to-image": return Color(white: 0.3)
        case "video-to-video": return Color(white: 0.35)
        case "image-to-video": return Color(white: 0.4)
        case "text-to-speech": return Color(white: 0.45)
        case "speech-to-text": return Color(white: 0.5)
        case "text-to-3d": return Color(white: 0.55)
        default: return Color(white: 0.3)
        }
    }

    private func speedGrayscaleColor(for speed: String) -> Color {
        switch speed.lowercased() {
        case "fast": return Color(white: 0.7)
        case "medium": return Color(white: 0.5)
        case "slow": return Color(white: 0.3)
        default: return Color(white: 0.5)
        }
    }

    private func tierGrayscaleColor(for tier: ReplicateModel.Tier) -> Color {
        switch tier {
        case .free: return Color(white: 0.4)
        case .standard: return Color(white: 0.6)
        case .premium: return Color(white: 0.8)
        case .enterprise: return Color(white: 0.9)
        }
    }
}

// MARK: - Compact Variant

struct ModelCardCompactView: View {
    let model: ReplicateModel

    var body: some View {
        HStack(spacing: 12) {
            // Icon
            ZStack {
                categoryGrayscaleColor(for: model.categorySlug)

                Image(systemName: Category.icon(for: model.categorySlug))
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(.white)
            }
            .frame(width: 48, height: 48)
            .cornerRadius(10)

            // Info
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Text(model.name)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.white)
                        .lineLimit(1)

                    if model.isFeatured {
                        Image(systemName: "star.fill")
                            .font(.system(size: 10))
                            .foregroundColor(Color.white.opacity(0.8))
                    }

                    Spacer()
                }

                if let provider = model.providerDisplayName {
                    Text(provider)
                        .font(.system(size: 12))
                        .foregroundColor(Color.white.opacity(0.5))
                        .lineLimit(1)
                }
            }

            Spacer()

            // Credits
            VStack(alignment: .trailing, spacing: 2) {
                let credits = model.creditCost ?? 2

                HStack(spacing: 3) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 10))
                    Text("\(credits)")
                        .font(.system(size: 13, weight: .semibold))
                }
                .foregroundColor(.white)

                if let speedTag = model.speedTag {
                    Text(SpeedTagConstants.displayText(for: speedTag))
                        .font(.system(size: 11))
                        .foregroundColor(Color.white.opacity(0.6))
                }
            }

            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(Color.white.opacity(0.5))
        }
        .padding(12)
        .background(Color.black)
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.white.opacity(0.2), lineWidth: 1)
        )
        .shadow(color: Color.white.opacity(0.05), radius: 4, x: 0, y: 2)
    }

    private func categoryGrayscaleColor(for slug: String) -> Color {
        switch slug {
        case "text-to-image": return Color(white: 0.2)
        case "text-to-video": return Color(white: 0.25)
        case "image-to-image": return Color(white: 0.3)
        case "video-to-video": return Color(white: 0.35)
        case "image-to-video": return Color(white: 0.4)
        case "text-to-speech": return Color(white: 0.45)
        case "speech-to-text": return Color(white: 0.5)
        case "text-to-3d": return Color(white: 0.55)
        default: return Color(white: 0.3)
        }
    }
}

// MARK: - Featured Variant (for horizontal scroll)

struct ModelCardFeaturedView: View {
    let model: ReplicateModel
    let rank: Int?

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Image with rank badge
            ZStack(alignment: .topLeading) {
                if let imageURL = model.displayImage, let url = URL(string: imageURL) {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        default:
                            placeholderView
                        }
                    }
                } else {
                    placeholderView
                }

                // Rank badge
                if let rank = rank {
                    Text("\(rank)")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(.black)
                        .frame(width: 24, height: 24)
                        .background(Circle().fill(.white))
                        .padding(8)
                }
            }
            .frame(height: 100)
            .clipped()

            // Model info
            VStack(alignment: .leading, spacing: 4) {
                Text(model.name)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.white)
                    .lineLimit(1)

                let credits = model.creditCost ?? 2
                Text(CreditDisplayConstants.formatCreditsShort(credits))
                    .font(.system(size: 11))
                    .foregroundColor(Color.white.opacity(0.6))
            }
            .padding(8)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(width: 140)
        .background(Color.black)
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.white.opacity(0.2), lineWidth: 1)
        )
        .shadow(color: Color.white.opacity(0.05), radius: 4, x: 0, y: 2)
    }

    private var placeholderView: some View {
        ZStack {
            categoryGrayscaleColor(for: model.categorySlug)

            Image(systemName: Category.icon(for: model.categorySlug))
                .font(.system(size: 32, weight: .regular))
                .foregroundColor(.white)
        }
    }

    private func categoryGrayscaleColor(for slug: String) -> Color {
        switch slug {
        case "text-to-image": return Color(white: 0.2)
        case "text-to-video": return Color(white: 0.25)
        case "image-to-image": return Color(white: 0.3)
        case "video-to-video": return Color(white: 0.35)
        case "image-to-video": return Color(white: 0.4)
        case "text-to-speech": return Color(white: 0.45)
        case "speech-to-text": return Color(white: 0.5)
        case "text-to-3d": return Color(white: 0.55)
        default: return Color(white: 0.3)
        }
    }
}

// MARK: - Loading Skeleton

struct ModelCardSkeletonView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Rectangle()
                .fill(Color.white.opacity(0.1))
                .frame(height: 110)

            VStack(alignment: .leading, spacing: 6) {
                Rectangle()
                    .fill(Color.white.opacity(0.1))
                    .frame(height: 16)
                    .frame(maxWidth: .infinity)

                Rectangle()
                    .fill(Color.white.opacity(0.1))
                    .frame(height: 12)
                    .frame(maxWidth: 100)

                Rectangle()
                    .fill(Color.white.opacity(0.1))
                    .frame(height: 12)
                    .frame(maxWidth: .infinity)

                Spacer(minLength: 4)

                HStack {
                    Rectangle()
                        .fill(Color.white.opacity(0.1))
                        .frame(width: 60, height: 20)
                    Spacer()
                    Rectangle()
                        .fill(Color.white.opacity(0.1))
                        .frame(width: 40, height: 20)
                }
            }
            .padding(10)
        }
        .frame(maxWidth: .infinity)
        .background(Color.black)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.white.opacity(0.2), lineWidth: 1)
        )
        .shadow(color: Color.white.opacity(0.05), radius: 8, x: 0, y: 4)
    }
}

// MARK: - Preview

#if DEBUG
struct ModelCardView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ScrollView {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 160))], spacing: 12) {
                    ForEach(ReplicateModel.mockModels) { model in
                        ModelCardView(model: model)
                    }

                    ModelCardSkeletonView()
                }
                .padding()
            }
            .background(Color.black)
            .preferredColorScheme(.dark)

            VStack(spacing: 12) {
                ForEach(ReplicateModel.mockModels) { model in
                    ModelCardCompactView(model: model)
                }
            }
            .padding()
            .background(Color.black)
            .preferredColorScheme(.dark)

            ScrollView(.horizontal) {
                HStack(spacing: 12) {
                    ForEach(Array(ReplicateModel.mockModels.enumerated()), id: \.element.id) { index, model in
                        ModelCardFeaturedView(model: model, rank: index + 1)
                    }
                }
                .padding()
            }
            .background(Color.black)
            .preferredColorScheme(.dark)
        }
    }
}
#endif
