//
//  ModelDetailView.swift
//  LuidGPT
//
//  Model detail screen with execution form, results, and history
//

import SwiftUI

struct ModelDetailView: View {
    let modelId: String

    @StateObject private var viewModel = ModelDetailViewModel()
    @EnvironmentObject var creditsViewModel: CreditsViewModel

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            if viewModel.modelLoading {
                loadingView
            } else if let error = viewModel.modelError {
                errorView(error: error)
            } else if let model = viewModel.model {
                contentView(model: model)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarBackground(Color.black, for: .navigationBar)
        .task {
            await viewModel.loadModel(modelId: modelId)
            await creditsViewModel.fetchBalance()
        }
    }

    // MARK: - Content View

    private func contentView(model: ReplicateModel) -> some View {
        ScrollView {
            VStack(spacing: 0) {
                // Breadcrumb navigation
                breadcrumbView(model: model)
                    .padding(.horizontal, LGSpacing.lg)
                    .padding(.vertical, LGSpacing.md)

                // Main content - stacked layout for iPhone
                VStack(spacing: LGSpacing.lg) {
                    leftColumn(model: model)
                    rightColumn(model: model)
                }
                .padding(.horizontal, LGSpacing.lg)
            }
            .padding(.bottom, LGSpacing.xl)
        }
    }

    // MARK: - Breadcrumb Navigation

    private func breadcrumbView(model: ReplicateModel) -> some View {
        HStack(spacing: LGSpacing.xs) {
            Button(action: { dismiss() }) {
                HStack(spacing: 4) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 12, weight: .semibold))
                    Text("Models")
                        .font(LGFonts.small)
                }
                .foregroundColor(Color.white.opacity(0.6))
            }

            if let category = model.category {
                Image(systemName: "chevron.right")
                    .font(.system(size: 10))
                    .foregroundColor(Color.white.opacity(0.4))

                Text(category.name)
                    .font(LGFonts.small)
                    .foregroundColor(Color.white.opacity(0.6))
            }

            Image(systemName: "chevron.right")
                .font(.system(size: 10))
                .foregroundColor(Color.white.opacity(0.4))

            Text(model.name)
                .font(LGFonts.small.weight(.semibold))
                .foregroundColor(.white)
                .lineLimit(1)
        }
    }

    // MARK: - Left Column (Model Info)

    private func leftColumn(model: ReplicateModel) -> some View {
        VStack(spacing: LGSpacing.md) {
            // Model card
            modelInfoCard(model: model)

            // Credit balance widget
            creditBalanceCard()
        }
    }

    private func modelInfoCard(model: ReplicateModel) -> some View {
        VStack(alignment: .leading, spacing: LGSpacing.md) {
            // Cover image with placeholder
            if let imageUrl = model.displayImage, let url = URL(string: imageUrl) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        image.resizable().aspectRatio(contentMode: .fill)
                    default:
                        categoryPlaceholder(model: model)
                    }
                }
                .frame(height: 160).frame(maxWidth: .infinity).clipShape(RoundedRectangle(cornerRadius: 12))
            }

            // Title & provider
            VStack(alignment: .leading, spacing: 4) {
                Text(model.name).font(LGFonts.h3).foregroundColor(.white)
                if let provider = model.providerDisplayName {
                    Text("by \(provider)").font(LGFonts.small).foregroundColor(Color.white.opacity(0.5))
                }
            }

            // Description
            if let description = model.description {
                Text(description).font(LGFonts.small).foregroundColor(Color.white.opacity(0.7)).lineLimit(4)
            }

            // Quick stats
            HStack(spacing: LGSpacing.sm) {
                statBadge(icon: "sparkles", value: "\(viewModel.effectiveCreditCost)", label: "Credits", color: .white)
                statBadge(icon: "clock", value: viewModel.speedEstimate, label: "Speed", color: Color(white: 0.7))
                statBadge(icon: "shield", value: model.tier.displayName, label: "Tier", color: tierGrayscaleColor(for: model.tier))
            }

            // Category badge
            if let category = model.category {
                let grayscaleColor = categoryGrayscaleColor(for: category.slug)
                HStack(spacing: 4) {
                    Image(systemName: Category.icon(for: category.slug)).font(.system(size: 11, weight: .semibold))
                    Text(category.name).font(.system(size: 12, weight: .semibold))
                }
                .padding(.horizontal, 10).padding(.vertical, 6).background(grayscaleColor).foregroundColor(.white).cornerRadius(8)
            }
        }
        .padding(LGSpacing.md)
        .background(Color(white: 0.1))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.white.opacity(0.2), lineWidth: 1)
        )
    }

    private func categoryPlaceholder(model: ReplicateModel) -> some View {
        let grayscaleColor = categoryGrayscaleColor(for: model.categorySlug)
        return ZStack {
            grayscaleColor
            Image(systemName: Category.icon(for: model.categorySlug)).font(.system(size: 48)).foregroundColor(.white)
        }
    }

    private func statBadge(icon: String, value: String, label: String, color: Color) -> some View {
        VStack(spacing: 4) {
            HStack(spacing: 4) {
                Image(systemName: icon).font(.system(size: 12))
                Text(value).font(.system(size: 13, weight: .bold))
            }
            .foregroundColor(color)
            Text(label).font(.system(size: 10)).foregroundColor(Color.white.opacity(0.5))
        }
        .frame(maxWidth: .infinity).padding(.vertical, 8).background(Color.white.opacity(0.05)).cornerRadius(8)
    }

    private func creditBalanceCard() -> some View {
        HStack(spacing: LGSpacing.md) {
            ZStack {
                Circle().fill(Color.white.opacity(0.1)).frame(width: 40, height: 40)
                Image(systemName: "sparkles").font(.system(size: 16)).foregroundColor(.white)
            }
            VStack(alignment: .leading, spacing: 2) {
                Text("Your Balance").font(.system(size: 11)).foregroundColor(Color.white.opacity(0.5))
                if creditsViewModel.isLoading {
                    ProgressView().scaleEffect(0.7)
                } else {
                    Text("\(creditsViewModel.totalCredits) credits").font(.system(size: 16, weight: .bold)).foregroundColor(.white)
                }
            }
            Spacer()
        }
        .padding(LGSpacing.md)
        .background(Color(white: 0.1))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.white.opacity(0.2), lineWidth: 1)
        )
    }

    // MARK: - Right Column (Form & Results)

    private func rightColumn(model: ReplicateModel) -> some View {
        VStack(spacing: LGSpacing.lg) {
            // Dynamic form
            if viewModel.schemaLoading {
                schemaLoadingView
            } else {
                DynamicFormView(
                    schema: viewModel.schema,
                    modelCredits: viewModel.effectiveCreditCost,
                    modelName: model.name,
                    isLoading: viewModel.executionLoading,
                    error: viewModel.executionError,
                    userCredits: creditsViewModel.totalCredits,
                    onSubmit: { input in
                        Task {
                            await viewModel.executeModel(
                                modelId: model.modelId,
                                input: input,
                                title: nil,
                                tags: nil
                            )
                        }
                    }
                )
            }

            // Generation result
            if let result = viewModel.executionResult {
                GenerationResultView(
                    generation: result,
                    status: viewModel.executionStatus,
                    isLoading: viewModel.executionLoading,
                    error: viewModel.executionError,
                    onFavoriteToggle: {
                        Task {
                            await viewModel.toggleFavorite()
                        }
                    },
                    onRegenerate: {
                        Task {
                            await viewModel.retryExecution()
                        }
                    }
                )
            } else if viewModel.executionStatus != .idle {
                // Show loading state when execution starts but no result yet
                GenerationResultView(
                    generation: ModelGeneration.placeholder(modelId: model.modelId),
                    status: viewModel.executionStatus,
                    isLoading: viewModel.executionLoading,
                    error: viewModel.executionError,
                    onFavoriteToggle: {},
                    onRegenerate: {}
                )
            }

            // Recent generations
            if !viewModel.recentGenerations.isEmpty {
                recentGenerationsView()
            }
        }
    }

    private var schemaLoadingView: some View {
        VStack(spacing: LGSpacing.md) {
            ProgressView().tint(.white)
            Text("Loading form...").font(LGFonts.small).foregroundColor(Color.white.opacity(0.6))
        }
        .frame(maxWidth: .infinity)
        .padding(LGSpacing.xl)
        .background(Color(white: 0.1))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.white.opacity(0.2), lineWidth: 1)
        )
    }

    private func recentGenerationsView() -> some View {
        VStack(alignment: .leading, spacing: LGSpacing.md) {
            HStack {
                Image(systemName: "clock.fill").foregroundColor(.white)
                Text("Recent Generations").font(LGFonts.h4).foregroundColor(.white)
                Spacer()
                Text("\(viewModel.recentGenerations.count)").font(LGFonts.small).foregroundColor(Color.white.opacity(0.6)).padding(.horizontal, 8).padding(.vertical, 4).background(Color.white.opacity(0.1)).cornerRadius(6)
            }
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: LGSpacing.sm) {
                    ForEach(viewModel.recentGenerations) { generation in
                        generationThumbnail(generation)
                    }
                }
            }
        }
        .padding(LGSpacing.md)
        .background(Color(white: 0.1))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.white.opacity(0.2), lineWidth: 1)
        )
    }

    private func generationThumbnail(_ generation: ModelGeneration) -> some View {
        ZStack {
            Color(white: 0.2)
            if generation.isImageOutput {
                Image(systemName: "photo").font(.system(size: 32)).foregroundColor(Color.white.opacity(0.5))
            } else if generation.isVideoOutput {
                Image(systemName: "play.circle.fill").font(.system(size: 32)).foregroundColor(.white)
            }
        }
        .frame(width: 100, height: 100).clipShape(RoundedRectangle(cornerRadius: 8))
    }

    // MARK: - Loading & Error States

    private var loadingView: some View {
        VStack(spacing: LGSpacing.lg) {
            ProgressView().scaleEffect(1.5).tint(.white)
            Text("Loading model...").font(LGFonts.body).foregroundColor(.white)
        }
    }

    private func errorView(error: String) -> some View {
        VStack(spacing: LGSpacing.lg) {
            Image(systemName: "exclamationmark.triangle").font(.system(size: 48)).foregroundColor(.red)
            Text("Model Not Found").font(LGFonts.h3).foregroundColor(.white)
            Text(error).font(LGFonts.small).foregroundColor(Color.white.opacity(0.7)).multilineTextAlignment(.center)
            LGButton("Go Back", style: .outline, fullWidth: false) { dismiss() }
        }
        .padding(LGSpacing.xl)
    }

    // MARK: - Helper Functions

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

    private func tierGrayscaleColor(for tier: ReplicateModel.Tier) -> Color {
        switch tier {
        case .free: return Color(white: 0.4)
        case .standard: return Color(white: 0.6)
        case .premium: return Color(white: 0.8)
        case .enterprise: return Color(white: 0.9)
        }
    }
}

// MARK: - Preview

#if DEBUG
struct ModelDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ModelDetailView(modelId: "black-forest-labs/flux-1.1-pro")
                .environmentObject(CreditsViewModel())
        }
        .preferredColorScheme(.dark)
    }
}
#endif
