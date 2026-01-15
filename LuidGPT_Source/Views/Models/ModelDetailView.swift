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
            Color.white.ignoresSafeArea()

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
        .toolbarBackground(Color.white, for: .navigationBar)
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
                .foregroundColor(LGColors.neutral400)
            }

            if let category = model.category {
                Image(systemName: "chevron.right")
                    .font(.system(size: 10))
                    .foregroundColor(LGColors.neutral600)

                Text(category.name)
                    .font(LGFonts.small)
                    .foregroundColor(LGColors.neutral400)
            }

            Image(systemName: "chevron.right")
                .font(.system(size: 10))
                .foregroundColor(LGColors.neutral600)

            Text(model.name)
                .font(LGFonts.small.weight(.semibold))
                .foregroundColor(LGColors.foreground)
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
                Text(model.name).font(LGFonts.h3).foregroundColor(.black)
                if let provider = model.providerDisplayName {
                    Text("by \(provider)").font(LGFonts.small).foregroundColor(LGColors.neutral600)
                }
            }

            // Description
            if let description = model.description {
                Text(description).font(LGFonts.small).foregroundColor(LGColors.neutral700).lineLimit(4)
            }

            // Quick stats
            HStack(spacing: LGSpacing.sm) {
                statBadge(icon: "sparkles", value: "\(viewModel.effectiveCreditCost)", label: "Credits", color: LGColors.VideoGeneration.main)
                statBadge(icon: "clock", value: viewModel.speedEstimate, label: "Speed", color: .green)
                statBadge(icon: "shield", value: model.tier.displayName, label: "Tier", color: .purple)
            }

            // Category badge
            if let category = model.category {
                let colors = ModelCategoryConstants.colors(for: category.slug)
                HStack(spacing: 4) {
                    Image(systemName: Category.icon(for: category.slug)).font(.system(size: 11, weight: .semibold))
                    Text(category.name).font(.system(size: 12, weight: .semibold))
                }
                .padding(.horizontal, 10).padding(.vertical, 6).background(colors.background).foregroundColor(colors.foreground).cornerRadius(8)
            }
        }
        .padding(LGSpacing.md).background(Color.white).cornerRadius(12)
    }

    private func categoryPlaceholder(model: ReplicateModel) -> some View {
        let colors = ModelCategoryConstants.colors(for: model.categorySlug)
        return ZStack {
            colors.background
            Image(systemName: Category.icon(for: model.categorySlug)).font(.system(size: 48)).foregroundColor(colors.foreground.opacity(0.5))
        }
    }

    private func statBadge(icon: String, value: String, label: String, color: Color) -> some View {
        VStack(spacing: 4) {
            HStack(spacing: 4) {
                Image(systemName: icon).font(.system(size: 12))
                Text(value).font(.system(size: 13, weight: .bold))
            }
            .foregroundColor(color)
            Text(label).font(.system(size: 10)).foregroundColor(LGColors.neutral600)
        }
        .frame(maxWidth: .infinity).padding(.vertical, 8).background(LGColors.neutral100).cornerRadius(8)
    }

    private func creditBalanceCard() -> some View {
        HStack(spacing: LGSpacing.md) {
            ZStack {
                Circle().fill(LGColors.VideoGeneration.main.opacity(0.2)).frame(width: 40, height: 40)
                Image(systemName: "sparkles").font(.system(size: 16)).foregroundColor(LGColors.VideoGeneration.main)
            }
            VStack(alignment: .leading, spacing: 2) {
                Text("Your Balance").font(.system(size: 11)).foregroundColor(LGColors.neutral600)
                if creditsViewModel.isLoading {
                    ProgressView().scaleEffect(0.7)
                } else {
                    Text("\(creditsViewModel.totalCredits) credits").font(.system(size: 16, weight: .bold)).foregroundColor(.black)
                }
            }
            Spacer()
        }
        .padding(LGSpacing.md).background(Color.white).cornerRadius(12)
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
            ProgressView().tint(LGColors.VideoGeneration.main)
            Text("Loading form...").font(LGFonts.small).foregroundColor(LGColors.neutral600)
        }
        .frame(maxWidth: .infinity).padding(LGSpacing.xl).background(Color.white).cornerRadius(12)
    }

    private func recentGenerationsView() -> some View {
        VStack(alignment: .leading, spacing: LGSpacing.md) {
            HStack {
                Image(systemName: "clock.fill").foregroundColor(LGColors.VideoGeneration.main)
                Text("Recent Generations").font(LGFonts.h4).foregroundColor(.black)
                Spacer()
                Text("\(viewModel.recentGenerations.count)").font(LGFonts.small).foregroundColor(LGColors.neutral600).padding(.horizontal, 8).padding(.vertical, 4).background(LGColors.neutral100).cornerRadius(6)
            }
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: LGSpacing.sm) {
                    ForEach(viewModel.recentGenerations) { generation in
                        generationThumbnail(generation)
                    }
                }
            }
        }
        .padding(LGSpacing.md).background(Color.white).cornerRadius(12)
    }

    private func generationThumbnail(_ generation: ModelGeneration) -> some View {
        ZStack {
            Color.gray.opacity(0.3)
            if generation.isImageOutput {
                Image(systemName: "photo").font(.system(size: 32)).foregroundColor(.gray)
            } else if generation.isVideoOutput {
                Image(systemName: "play.circle.fill").font(.system(size: 32)).foregroundColor(.white)
            }
        }
        .frame(width: 100, height: 100).clipShape(RoundedRectangle(cornerRadius: 8))
    }

    // MARK: - Loading & Error States

    private var loadingView: some View {
        VStack(spacing: LGSpacing.lg) {
            ProgressView().scaleEffect(1.5).tint(LGColors.VideoGeneration.main)
            Text("Loading model...").font(LGFonts.body).foregroundColor(LGColors.foreground)
        }
    }

    private func errorView(error: String) -> some View {
        VStack(spacing: LGSpacing.lg) {
            Image(systemName: "exclamationmark.triangle").font(.system(size: 48)).foregroundColor(LGColors.errorText)
            Text("Model Not Found").font(LGFonts.h3).foregroundColor(LGColors.foreground)
            Text(error).font(LGFonts.small).foregroundColor(LGColors.foregroundSecondary).multilineTextAlignment(.center)
            LGButton("Go Back", style: .outline, fullWidth: false) { dismiss() }
        }
        .padding(LGSpacing.xl)
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
