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
                        .foregroundColor(Color.black)
                        .lineLimit(1)

                    if model.isFeatured {
                        Image(systemName: "star.fill")
                            .font(.system(size: 10))
                            .foregroundColor(.yellow)
                    }

                    Spacer(minLength: 0)
                }

                // Provider
                if let provider = model.providerDisplayName {
                    Text("by \(provider)")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(Color.gray)
                        .lineLimit(1)
                }

                // Description
                if let description = model.description {
                    Text(description)
                        .font(.system(size: 11))
                        .foregroundColor(Color.gray)
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
        .background(Color(uiColor: .systemBackground))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.black.opacity(0.2), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
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
            let colors = ModelCategoryConstants.colors(for: model.categorySlug)

            colors.background

            Image(systemName: Category.icon(for: model.categorySlug))
                .font(.system(size: 36, weight: .regular))
                .foregroundColor(colors.foreground)
        }
    }

    @ViewBuilder
    private var categoryBadge: some View {
        if let category = model.category {
            let colors = ModelCategoryConstants.colors(for: category.slug)

            HStack(spacing: 3) {
                Image(systemName: Category.icon(for: category.slug))
                    .font(.system(size: 9, weight: .bold))
                Text(category.name)
                    .font(.system(size: 10, weight: .bold))
                    .lineLimit(1)
            }
            .padding(.horizontal, 7)
            .padding(.vertical, 4)
            .background(colors.background)
            .foregroundColor(colors.foreground)
            .cornerRadius(5)
        }
    }

    private func speedBadge(_ speed: String) -> some View {
        let badgeColor = SpeedTagConstants.color(for: speed)

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
        let tierColors = ModelTierConstants.colors(for: model.tier)

        return HStack(spacing: 3) {
            Image(systemName: "sparkles")
                .font(.system(size: 9, weight: .bold))
            Text("\(credits)")
                .font(.system(size: 12, weight: .black))
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(tierColors.background)
        .foregroundColor(tierColors.foreground)
        .cornerRadius(5)
    }
}

// MARK: - Compact Variant

struct ModelCardCompactView: View {
    let model: ReplicateModel

    var body: some View {
        HStack(spacing: 12) {
            // Icon
            ZStack {
                let colors = ModelCategoryConstants.colors(for: model.categorySlug)

                colors.background

                Image(systemName: Category.icon(for: model.categorySlug))
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(colors.foreground)
            }
            .frame(width: 48, height: 48)
            .cornerRadius(10)

            // Info
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Text(model.name)
                        .font(.system(size: 15, weight: .semibold))
                        .lineLimit(1)

                    if model.isFeatured {
                        Image(systemName: "star.fill")
                            .font(.system(size: 10))
                            .foregroundColor(.yellow)
                    }

                    Spacer()
                }

                if let provider = model.providerDisplayName {
                    Text(provider)
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
            }

            Spacer()

            // Credits
            VStack(alignment: .trailing, spacing: 2) {
                let credits = model.creditCost ?? 2
                let tierColors = ModelTierConstants.colors(for: model.tier)

                HStack(spacing: 3) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 10))
                    Text("\(credits)")
                        .font(.system(size: 13, weight: .semibold))
                }
                .foregroundColor(tierColors.foreground)

                if let speedTag = model.speedTag {
                    Text(SpeedTagConstants.displayText(for: speedTag))
                        .font(.system(size: 11))
                        .foregroundColor(SpeedTagConstants.color(for: speedTag))
                }
            }

            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(.secondary)
        }
        .padding(12)
        .background(Color.white)
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.black.opacity(0.1), lineWidth: 1.5)
        )
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
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
                        .foregroundColor(.white)
                        .frame(width: 24, height: 24)
                        .background(
                            Circle()
                                .fill(Color.orange)
                        )
                        .padding(8)
                }
            }
            .frame(height: 100)
            .clipped()

            // Model info
            VStack(alignment: .leading, spacing: 4) {
                Text(model.name)
                    .font(.system(size: 13, weight: .semibold))
                    .lineLimit(1)

                let credits = model.creditCost ?? 2
                Text(CreditDisplayConstants.formatCreditsShort(credits))
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
            }
            .padding(8)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(width: 140)
        .background(Color.white)
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.black.opacity(0.1), lineWidth: 1.5)
        )
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
    }

    private var placeholderView: some View {
        ZStack {
            let colors = ModelCategoryConstants.colors(for: model.categorySlug)

            colors.background

            Image(systemName: Category.icon(for: model.categorySlug))
                .font(.system(size: 32, weight: .regular))
                .foregroundColor(colors.foreground)
        }
    }
}

// MARK: - Loading Skeleton

struct ModelCardSkeletonView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Rectangle()
                .fill(Color(.systemGray5))
                .frame(height: 110)

            VStack(alignment: .leading, spacing: 6) {
                Rectangle()
                    .fill(Color(.systemGray5))
                    .frame(height: 16)
                    .frame(maxWidth: .infinity)

                Rectangle()
                    .fill(Color(.systemGray5))
                    .frame(height: 12)
                    .frame(maxWidth: 100)

                Rectangle()
                    .fill(Color(.systemGray5))
                    .frame(height: 12)
                    .frame(maxWidth: .infinity)

                Spacer(minLength: 4)

                HStack {
                    Rectangle()
                        .fill(Color(.systemGray5))
                        .frame(width: 60, height: 20)
                    Spacer()
                    Rectangle()
                        .fill(Color(.systemGray5))
                        .frame(width: 40, height: 20)
                }
            }
            .padding(10)
        }
        .frame(maxWidth: .infinity)
        .background(Color(uiColor: .systemBackground))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.black.opacity(0.2), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
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
            .preferredColorScheme(.dark)

            VStack(spacing: 12) {
                ForEach(ReplicateModel.mockModels) { model in
                    ModelCardCompactView(model: model)
                }
            }
            .padding()
            .preferredColorScheme(.light)

            ScrollView(.horizontal) {
                HStack(spacing: 12) {
                    ForEach(Array(ReplicateModel.mockModels.enumerated()), id: \.element.id) { index, model in
                        ModelCardFeaturedView(model: model, rank: index + 1)
                    }
                }
                .padding()
            }
            .preferredColorScheme(.dark)
        }
    }
}
#endif
