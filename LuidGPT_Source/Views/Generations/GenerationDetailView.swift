//
//  GenerationDetailView.swift
//  LuidGPT
//
//  Full-screen detail view for a single generation
//

import SwiftUI
import AVKit

struct GenerationDetailView: View {
    let generation: ModelGeneration
    @ObservedObject var viewModel: GenerationsViewModel

    @Environment(\.dismiss) private var dismiss
    @State private var showShareSheet = false
    @State private var showDeleteConfirmation = false
    @State private var showInputDetails = false

    var body: some View {
        NavigationView {
            ZStack {
                LGColors.background.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: LGSpacing.lg) {
                        // Main output display
                        outputSection

                        // Metadata section
                        metadataSection

                        // Actions section
                        actionsSection

                        // Input details
                        inputDetailsSection

                        // Model info
                        if let model = generation.replicateModel {
                            modelInfoSection(model)
                        }
                    }
                    .padding(LGSpacing.lg)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                    .foregroundColor(LGColors.VideoGeneration.main)
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack(spacing: 16) {
                        Button(action: { showShareSheet = true }) {
                            Image(systemName: "square.and.arrow.up")
                                .foregroundColor(LGColors.VideoGeneration.main)
                        }

                        Button(action: {
                            Task {
                                await viewModel.toggleFavorite(generation: generation)
                            }
                        }) {
                            Image(systemName: generation.isFavorite ? "heart.fill" : "heart")
                                .foregroundColor(generation.isFavorite ? .red : LGColors.VideoGeneration.main)
                        }
                    }
                }
            }
            .sheet(isPresented: $showShareSheet) {
                if let url = generation.outputUrl, let outputURL = URL(string: url) {
                    ShareSheet(items: [outputURL])
                }
            }
            .alert("Delete Generation", isPresented: $showDeleteConfirmation) {
                Button("Cancel", role: .cancel) {}
                Button("Delete", role: .destructive) {
                    Task {
                        await viewModel.deleteGeneration(generation: generation)
                        dismiss()
                    }
                }
            } message: {
                Text("Are you sure you want to delete this generation? This action cannot be undone.")
            }
        }
    }

    // MARK: - Output Section

    @ViewBuilder
    private var outputSection: some View {
        VStack(spacing: LGSpacing.sm) {
            // Title and status
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(generation.title ?? "Untitled Generation")
                        .font(LGFonts.h3)
                        .foregroundColor(LGColors.foreground)

                    HStack(spacing: 6) {
                        Circle()
                            .fill(statusColor)
                            .frame(width: 8, height: 8)

                        Text(generation.status.displayName)
                            .font(LGFonts.small)
                            .foregroundColor(statusColor)
                    }
                }

                Spacer()

                if let tags = generation.tags, !tags.isEmpty {
                    VStack(alignment: .trailing, spacing: 4) {
                        ForEach(tags.prefix(3), id: \.self) { tag in
                            Text("#\(tag)")
                                .font(.system(size: 11))
                                .foregroundColor(LGColors.neutral400)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(LGColors.neutral800)
                                .cornerRadius(6)
                        }
                    }
                }
            }

            // Output media
            if let url = generation.outputUrl {
                if generation.isImageOutput {
                    AsyncImage(url: URL(string: url)) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .cornerRadius(12)
                        case .failure:
                            errorPlaceholder
                        case .empty:
                            loadingPlaceholder
                        @unknown default:
                            EmptyView()
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .frame(maxHeight: 500)
                } else if generation.isVideoOutput {
                    VideoPlayer(player: AVPlayer(url: URL(string: url)!))
                        .frame(height: 400)
                        .cornerRadius(12)
                } else {
                    genericOutputView(url: url)
                }
            } else if generation.status.isRunning {
                processingPlaceholder
            } else {
                errorPlaceholder
            }
        }
        .padding(LGSpacing.md)
        .background(LGColors.neutral800)
        .cornerRadius(12)
    }

    // MARK: - Metadata Section

    private var metadataSection: some View {
        VStack(spacing: LGSpacing.md) {
            HStack {
                Text("Details")
                    .font(LGFonts.h4)
                    .foregroundColor(LGColors.foreground)
                Spacer()
            }

            VStack(spacing: 12) {
                metadataRow(
                    icon: "sparkles",
                    label: "Credits Used",
                    value: "\(generation.creditsUsed)",
                    color: LGColors.VideoGeneration.main
                )

                if let execTime = generation.executionTimeDisplay {
                    metadataRow(
                        icon: "clock.fill",
                        label: "Execution Time",
                        value: execTime,
                        color: .blue
                    )
                }

                metadataRow(
                    icon: "calendar",
                    label: "Created",
                    value: formatDate(generation.createdDate),
                    color: .purple
                )

                metadataRow(
                    icon: "number",
                    label: "Generation ID",
                    value: String(generation.id.prefix(8)) + "...",
                    color: LGColors.neutral400
                )
            }
        }
        .padding(LGSpacing.md)
        .background(LGColors.neutral800)
        .cornerRadius(12)
    }

    private func metadataRow(icon: String, label: String, value: String, color: Color) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(color)
                .frame(width: 24)

            Text(label)
                .font(LGFonts.body)
                .foregroundColor(LGColors.neutral400)

            Spacer()

            Text(value)
                .font(LGFonts.body.weight(.semibold))
                .foregroundColor(LGColors.foreground)
        }
    }

    // MARK: - Actions Section

    private var actionsSection: some View {
        VStack(spacing: LGSpacing.sm) {
            HStack {
                Text("Actions")
                    .font(LGFonts.h4)
                    .foregroundColor(LGColors.foreground)
                Spacer()
            }

            HStack(spacing: LGSpacing.sm) {
                actionButton(
                    icon: "arrow.down.circle",
                    label: "Download",
                    color: LGColors.VideoGeneration.main
                ) {
                    // Download functionality (similar to GenerationResultView)
                    if let url = generation.outputUrl {
                        UIApplication.shared.open(URL(string: url)!)
                    }
                }

                actionButton(
                    icon: "square.and.arrow.up",
                    label: "Share",
                    color: .blue
                ) {
                    showShareSheet = true
                }

                actionButton(
                    icon: generation.isFavorite ? "heart.fill" : "heart",
                    label: "Favorite",
                    color: generation.isFavorite ? .red : LGColors.neutral400
                ) {
                    Task {
                        await viewModel.toggleFavorite(generation: generation)
                    }
                }
            }

            HStack(spacing: LGSpacing.sm) {
                actionButton(
                    icon: "trash",
                    label: "Delete",
                    color: LGColors.errorText
                ) {
                    showDeleteConfirmation = true
                }

                if generation.status == .completed {
                    actionButton(
                        icon: "arrow.clockwise",
                        label: "Regenerate",
                        color: LGColors.VideoGeneration.main
                    ) {
                        // TODO: Implement regenerate functionality
                        // This would navigate to the model detail view with pre-filled inputs
                    }
                }
            }
        }
        .padding(LGSpacing.md)
        .background(LGColors.neutral800)
        .cornerRadius(12)
    }

    private func actionButton(
        icon: String,
        label: String,
        color: Color,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(color)

                Text(label)
                    .font(.system(size: 11))
                    .foregroundColor(LGColors.neutral300)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(LGColors.neutral800.opacity(0.5))
            .cornerRadius(8)
        }
    }

    // MARK: - Input Details Section

    private var inputDetailsSection: some View {
        VStack(alignment: .leading, spacing: LGSpacing.sm) {
            Button(action: { showInputDetails.toggle() }) {
                HStack {
                    Text("Input Parameters")
                        .font(LGFonts.h4)
                        .foregroundColor(LGColors.foreground)

                    Spacer()

                    Image(systemName: showInputDetails ? "chevron.up" : "chevron.down")
                        .font(.system(size: 12))
                        .foregroundColor(LGColors.neutral400)
                }
            }

            if showInputDetails {
                VStack(alignment: .leading, spacing: 12) {
                    ForEach(Array(generation.input.keys.sorted()), id: \.self) { key in
                        inputParameterRow(key: key, value: generation.input[key])
                    }
                }
                .padding(LGSpacing.md)
                .background(LGColors.neutral800.opacity(0.3))
                .cornerRadius(8)
            }
        }
        .padding(LGSpacing.md)
        .background(LGColors.neutral800)
        .cornerRadius(12)
    }

    private func inputParameterRow(key: String, value: AnyCodable?) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(key.capitalized)
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(LGColors.neutral400)

            Text(formatInputValue(value))
                .font(LGFonts.small)
                .foregroundColor(LGColors.foreground)
                .lineLimit(5)
        }
    }

    // MARK: - Model Info Section

    private func modelInfoSection(_ model: ReplicateModel) -> some View {
        VStack(alignment: .leading, spacing: LGSpacing.sm) {
            Text("Model Information")
                .font(LGFonts.h4)
                .foregroundColor(LGColors.foreground)

            HStack(spacing: LGSpacing.md) {
                if let imageUrl = model.displayImage, let url = URL(string: imageUrl) {
                    AsyncImage(url: url) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } placeholder: {
                        Color.gray.opacity(0.3)
                    }
                    .frame(width: 60, height: 60)
                    .cornerRadius(8)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(model.name)
                        .font(LGFonts.body.weight(.semibold))
                        .foregroundColor(LGColors.foreground)

                    if let provider = model.providerDisplayName {
                        Text("by \(provider)")
                            .font(LGFonts.small)
                            .foregroundColor(LGColors.neutral400)
                    }

                    if let category = model.category {
                        let colors = ModelCategoryConstants.colors(for: category.slug)
                        Text(category.name)
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(colors.foreground)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(colors.background)
                            .cornerRadius(6)
                    }
                }

                Spacer()
            }
        }
        .padding(LGSpacing.md)
        .background(LGColors.neutral800)
        .cornerRadius(12)
    }

    // MARK: - Placeholder Views

    private var loadingPlaceholder: some View {
        ZStack {
            LGColors.neutral800
            ProgressView()
                .tint(LGColors.VideoGeneration.main)
        }
        .frame(height: 300)
        .cornerRadius(12)
    }

    private var errorPlaceholder: some View {
        ZStack {
            LGColors.neutral800
            VStack(spacing: 8) {
                Image(systemName: "exclamationmark.triangle")
                    .font(.system(size: 32))
                    .foregroundColor(LGColors.errorText)
                Text(generation.errorMessage ?? "Generation failed")
                    .font(LGFonts.small)
                    .foregroundColor(LGColors.neutral400)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
        }
        .frame(height: 300)
        .cornerRadius(12)
    }

    private var processingPlaceholder: some View {
        ZStack {
            LGColors.neutral800
            VStack(spacing: 12) {
                ProgressView()
                    .scaleEffect(1.2)
                    .tint(LGColors.VideoGeneration.main)
                Text("Processing...")
                    .font(LGFonts.body)
                    .foregroundColor(LGColors.neutral400)
                Text("This may take a few minutes")
                    .font(LGFonts.small)
                    .foregroundColor(LGColors.neutral500)
            }
        }
        .frame(height: 300)
        .cornerRadius(12)
    }

    private func genericOutputView(url: String) -> some View {
        VStack(spacing: LGSpacing.sm) {
            Image(systemName: "doc.fill")
                .font(.system(size: 48))
                .foregroundColor(LGColors.neutral400)

            Text("Output available")
                .font(LGFonts.body)
                .foregroundColor(LGColors.foreground)

            Button(action: {
                if let outputURL = URL(string: url) {
                    UIApplication.shared.open(outputURL)
                }
            }) {
                Text("Open in Browser")
                    .font(LGFonts.small)
                    .foregroundColor(LGColors.VideoGeneration.main)
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 300)
        .background(LGColors.neutral800.opacity(0.5))
        .cornerRadius(12)
    }

    // MARK: - Helper Methods

    private var statusColor: Color {
        switch generation.status {
        case .pending, .processing:
            return .orange
        case .completed:
            return .green
        case .failed, .cancelled:
            return LGColors.errorText
        }
    }

    private func formatDate(_ date: Date?) -> String {
        guard let date = date else { return "N/A" }

        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter.localizedString(for: date, relativeTo: Date())
    }

    private func formatInputValue(_ value: AnyCodable?) -> String {
        guard let value = value else { return "N/A" }

        // Handle different types
        if let string = value.value as? String {
            // Truncate long strings (e.g., base64 images)
            if string.hasPrefix("data:image") {
                return "[Image data]"
            } else if string.count > 200 {
                return String(string.prefix(200)) + "..."
            }
            return string
        } else if let number = value.value as? NSNumber {
            return "\(number)"
        } else if let bool = value.value as? Bool {
            return bool ? "Yes" : "No"
        } else if let array = value.value as? [Any] {
            return "[\(array.count) items]"
        } else if let dict = value.value as? [String: Any] {
            return "{\(dict.count) properties}"
        }

        return "\(value.value)"
    }
}

// MARK: - Preview

#if DEBUG
struct GenerationDetailView_Previews: PreviewProvider {
    static var previews: some View {
        GenerationDetailView(
            generation: .mockImageGeneration,
            viewModel: .mock()
        )
        .preferredColorScheme(.dark)
    }
}
#endif
