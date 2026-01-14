//
//  GenerationResultView.swift
//  LuidGPT
//
//  Comprehensive result display for model generations with media rendering
//

import SwiftUI
import AVKit
import Photos

struct GenerationResultView: View {
    let generation: ModelGeneration
    let status: ModelDetailViewModel.ExecutionStatus
    let isLoading: Bool
    let error: String?

    let onFavoriteToggle: () -> Void
    let onRegenerate: () -> Void

    @State private var showFullScreen = false
    @State private var showInputDetails = false
    @State private var showShareSheet = false
    @State private var downloadStatus: DownloadStatus = .idle
    @State private var selectedOutputIndex = 0

    enum DownloadStatus: Equatable {
        case idle, downloading, success, failed(String)
    }

    var body: some View {
        VStack(spacing: LGSpacing.lg) {
            // Header with status
            headerSection

            if isLoading {
                loadingView
            } else if let error = error {
                errorView(error: error)
            } else {
                // Output display
                outputSection

                // Metadata
                metadataSection

                // Actions
                actionsSection

                // Input details (expandable)
                inputDetailsSection
            }
        }
        .padding(LGSpacing.lg)
        .background(LGColors.neutral800)
        .cornerRadius(12)
        .sheet(isPresented: $showFullScreen) {
            fullScreenOutputView
        }
        .sheet(isPresented: $showShareSheet) {
            if let url = currentOutputURL {
                ShareSheet(items: [url])
            }
        }
    }

    // MARK: - Header Section

    private var headerSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Generation Result")
                    .font(LGFonts.h4)
                    .foregroundColor(LGColors.foreground)

                if let title = generation.title {
                    Text(title)
                        .font(LGFonts.small)
                        .foregroundColor(LGColors.neutral400)
                }
            }

            Spacer()

            // Status badge
            HStack(spacing: 4) {
                Circle()
                    .fill(statusColor)
                    .frame(width: 8, height: 8)

                Text(status.displayText)
                    .font(LGFonts.small)
                    .foregroundColor(statusColor)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(statusColor.opacity(0.1))
            .cornerRadius(8)
        }
    }

    // MARK: - Loading View

    private var loadingView: some View {
        VStack(spacing: LGSpacing.md) {
            ProgressView()
                .scaleEffect(1.2)
                .tint(LGColors.VideoGeneration.main)

            Text(status.displayText)
                .font(LGFonts.body)
                .foregroundColor(LGColors.neutral400)

            if let estimatedTime = generation.executionTimeDisplay {
                Text("Estimated time: \(estimatedTime)")
                    .font(LGFonts.small)
                    .foregroundColor(LGColors.neutral500)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(LGSpacing.xl)
    }

    // MARK: - Error View

    private func errorView(error: String) -> some View {
        VStack(spacing: LGSpacing.md) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 32))
                .foregroundColor(LGColors.errorText)

            Text("Generation Failed")
                .font(LGFonts.h4)
                .foregroundColor(LGColors.foreground)

            Text(error)
                .font(LGFonts.small)
                .foregroundColor(LGColors.neutral400)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            Button(action: onRegenerate) {
                HStack(spacing: 8) {
                    Image(systemName: "arrow.clockwise")
                    Text("Try Again")
                }
                .font(LGFonts.body.weight(.semibold))
                .foregroundColor(.white)
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(LGColors.VideoGeneration.main)
                .cornerRadius(8)
            }
        }
        .padding(LGSpacing.lg)
    }

    // MARK: - Output Section

    private var outputSection: some View {
        VStack(spacing: LGSpacing.sm) {
            if let outputUrls = generation.outputUrls, outputUrls.count > 1 {
                // Multiple outputs - show carousel
                multipleOutputsView(urls: outputUrls)
            } else if let url = generation.outputUrl {
                // Single output
                singleOutputView(url: url)
            } else {
                // No output yet
                Text("No output available")
                    .font(LGFonts.small)
                    .foregroundColor(LGColors.neutral400)
                    .frame(maxWidth: .infinity)
                    .padding(LGSpacing.xl)
                    .background(LGColors.neutral800.opacity(0.5))
                    .cornerRadius(8)
            }
        }
    }

    private func singleOutputView(url: String) -> some View {
        Group {
            if generation.isImageOutput {
                imageOutputView(url: url)
            } else if generation.isVideoOutput {
                videoOutputView(url: url)
            } else {
                genericOutputView(url: url)
            }
        }
    }

    private func imageOutputView(url: String) -> some View {
        Button(action: { showFullScreen = true }) {
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
            .frame(maxHeight: 400)
        }
    }

    private func videoOutputView(url: String) -> some View {
        VStack(spacing: 0) {
            if let videoURL = URL(string: url) {
                VideoPlayer(player: AVPlayer(url: videoURL))
                    .frame(height: 300)
                    .cornerRadius(12)
            } else {
                errorPlaceholder
            }
        }
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
        .padding(LGSpacing.xl)
        .background(LGColors.neutral800.opacity(0.5))
        .cornerRadius(12)
    }

    private func multipleOutputsView(urls: [String]) -> some View {
        VStack(spacing: LGSpacing.sm) {
            // Main output display
            TabView(selection: $selectedOutputIndex) {
                ForEach(urls.indices, id: \.self) { index in
                    singleOutputView(url: urls[index])
                        .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .automatic))
            .frame(height: 400)

            // Output counter
            Text("\(selectedOutputIndex + 1) of \(urls.count)")
                .font(LGFonts.small)
                .foregroundColor(LGColors.neutral400)
        }
    }

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
                Text("Failed to load")
                    .font(LGFonts.small)
                    .foregroundColor(LGColors.neutral400)
            }
        }
        .frame(height: 300)
        .cornerRadius(12)
    }

    // MARK: - Metadata Section

    private var metadataSection: some View {
        HStack(spacing: LGSpacing.md) {
            // Execution time
            if let executionTime = generation.executionTimeDisplay {
                metadataBadge(
                    icon: "clock.fill",
                    label: "Time",
                    value: executionTime,
                    color: .blue
                )
            }

            // Credits used
            metadataBadge(
                icon: "sparkles",
                label: "Credits",
                value: "\(generation.creditsUsed)",
                color: LGColors.VideoGeneration.main
            )

            // Timestamp
            if let date = generation.createdDate {
                metadataBadge(
                    icon: "calendar",
                    label: "Created",
                    value: formatDate(date),
                    color: .purple
                )
            }
        }
    }

    private func metadataBadge(icon: String, label: String, value: String, color: Color) -> some View {
        VStack(spacing: 4) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 12))
                Text(value)
                    .font(.system(size: 13, weight: .bold))
            }
            .foregroundColor(color)

            Text(label)
                .font(.system(size: 10))
                .foregroundColor(LGColors.neutral500)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .background(LGColors.neutral800.opacity(0.5))
        .cornerRadius(8)
    }

    // MARK: - Actions Section

    private var actionsSection: some View {
        VStack(spacing: LGSpacing.sm) {
            // Primary actions row
            HStack(spacing: LGSpacing.sm) {
                // Download button
                actionButton(
                    icon: downloadStatus == .downloading ? "arrow.down.circle.fill" : "arrow.down.circle",
                    label: downloadButtonLabel,
                    color: downloadStatus == .success ? .green : LGColors.VideoGeneration.main,
                    action: handleDownload,
                    disabled: downloadStatus == .downloading
                )

                // Share button
                actionButton(
                    icon: "square.and.arrow.up",
                    label: "Share",
                    color: .blue,
                    action: { showShareSheet = true }
                )

                // Favorite button
                actionButton(
                    icon: generation.isFavorite ? "heart.fill" : "heart",
                    label: "Favorite",
                    color: generation.isFavorite ? .red : LGColors.neutral400,
                    action: onFavoriteToggle
                )
            }

            // Secondary actions row
            HStack(spacing: LGSpacing.sm) {
                // Full screen button
                actionButton(
                    icon: "arrow.up.left.and.arrow.down.right",
                    label: "Full Screen",
                    color: LGColors.neutral400,
                    action: { showFullScreen = true }
                )

                // Regenerate button
                actionButton(
                    icon: "arrow.clockwise",
                    label: "Regenerate",
                    color: LGColors.VideoGeneration.main,
                    action: onRegenerate
                )
            }

            // Download status message
            if case .failed(let message) = downloadStatus {
                Text(message)
                    .font(LGFonts.small)
                    .foregroundColor(LGColors.errorText)
            } else if case .success = downloadStatus {
                Text("Saved to Photos")
                    .font(LGFonts.small)
                    .foregroundColor(.green)
            }
        }
    }

    private func actionButton(
        icon: String,
        label: String,
        color: Color,
        action: @escaping () -> Void,
        disabled: Bool = false
    ) -> some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(disabled ? LGColors.neutral600 : color)

                Text(label)
                    .font(.system(size: 11))
                    .foregroundColor(disabled ? LGColors.neutral600 : LGColors.neutral300)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(LGColors.neutral800.opacity(0.5))
            .cornerRadius(8)
        }
        .disabled(disabled)
    }

    // MARK: - Input Details Section

    private var inputDetailsSection: some View {
        VStack(alignment: .leading, spacing: LGSpacing.sm) {
            Button(action: { showInputDetails.toggle() }) {
                HStack {
                    Text("Input Parameters")
                        .font(LGFonts.body.weight(.semibold))
                        .foregroundColor(LGColors.foreground)

                    Spacer()

                    Image(systemName: showInputDetails ? "chevron.up" : "chevron.down")
                        .font(.system(size: 12))
                        .foregroundColor(LGColors.neutral400)
                }
            }

            if showInputDetails {
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(Array(generation.input.keys.sorted()), id: \.self) { key in
                        inputParameterRow(key: key, value: generation.input[key])
                    }
                }
                .padding(LGSpacing.md)
                .background(LGColors.neutral800.opacity(0.3))
                .cornerRadius(8)
            }
        }
        .padding(.vertical, LGSpacing.sm)
    }

    private func inputParameterRow(key: String, value: AnyCodable?) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(key.capitalized)
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(LGColors.neutral400)

            Text(formatInputValue(value))
                .font(LGFonts.small)
                .foregroundColor(LGColors.foreground)
                .lineLimit(3)
        }
    }

    // MARK: - Full Screen View

    private var fullScreenOutputView: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()

                if let url = currentOutputURL {
                    if generation.isImageOutput {
                        fullScreenImageView(url: url)
                    } else if generation.isVideoOutput {
                        fullScreenVideoView(url: url)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") {
                        showFullScreen = false
                    }
                    .foregroundColor(.white)
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showShareSheet = true }) {
                        Image(systemName: "square.and.arrow.up")
                            .foregroundColor(.white)
                    }
                }
            }
        }
    }

    private func fullScreenImageView(url: URL) -> some View {
        AsyncImage(url: url) { phase in
            switch phase {
            case .success(let image):
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            case .failure:
                errorPlaceholder
            case .empty:
                ProgressView().tint(.white)
            @unknown default:
                EmptyView()
            }
        }
    }

    private func fullScreenVideoView(url: URL) -> some View {
        VideoPlayer(player: AVPlayer(url: url))
            .ignoresSafeArea()
    }

    // MARK: - Helper Methods

    private var currentOutputURL: URL? {
        if let outputUrls = generation.outputUrls, !outputUrls.isEmpty {
            return URL(string: outputUrls[selectedOutputIndex])
        } else if let outputUrl = generation.outputUrl {
            return URL(string: outputUrl)
        }
        return nil
    }

    private var statusColor: Color {
        switch status {
        case .idle, .preparing, .submitting:
            return LGColors.neutral400
        case .processing:
            return .orange
        case .completed:
            return .green
        case .failed:
            return LGColors.errorText
        }
    }

    private var downloadButtonLabel: String {
        switch downloadStatus {
        case .idle:
            return "Download"
        case .downloading:
            return "Saving..."
        case .success:
            return "Saved"
        case .failed:
            return "Retry"
        }
    }

    private func handleDownload() {
        guard let url = currentOutputURL else { return }

        if generation.isImageOutput {
            downloadImage(from: url)
        } else if generation.isVideoOutput {
            downloadVideo(from: url)
        } else {
            // For other types, open in Safari
            UIApplication.shared.open(url)
        }
    }

    private func downloadImage(from url: URL) {
        downloadStatus = .downloading

        Task {
            do {
                let (data, _) = try await URLSession.shared.data(from: url)

                guard let image = UIImage(data: data) else {
                    await MainActor.run {
                        downloadStatus = .failed("Invalid image data")
                    }
                    return
                }

                // Save to Photos
                try await saveImageToPhotos(image)

                await MainActor.run {
                    downloadStatus = .success

                    // Reset status after 3 seconds
                    Task {
                        try? await Task.sleep(nanoseconds: 3_000_000_000)
                        downloadStatus = .idle
                    }
                }

            } catch {
                await MainActor.run {
                    downloadStatus = .failed("Failed to download")
                }
            }
        }
    }

    private func downloadVideo(from url: URL) {
        downloadStatus = .downloading

        Task {
            do {
                let (localURL, _) = try await URLSession.shared.download(from: url)

                // Save to Photos
                try await saveVideoToPhotos(localURL)

                await MainActor.run {
                    downloadStatus = .success

                    // Reset status after 3 seconds
                    Task {
                        try? await Task.sleep(nanoseconds: 3_000_000_000)
                        downloadStatus = .idle
                    }
                }

            } catch {
                await MainActor.run {
                    downloadStatus = .failed("Failed to download")
                }
            }
        }
    }

    private func saveImageToPhotos(_ image: UIImage) async throws {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            PHPhotoLibrary.requestAuthorization { status in
                guard status == .authorized else {
                    continuation.resume(throwing: NSError(
                        domain: "Photos",
                        code: 1,
                        userInfo: [NSLocalizedDescriptionKey: "Photo library access denied"]
                    ))
                    return
                }

                PHPhotoLibrary.shared().performChanges({
                    PHAssetChangeRequest.creationRequestForAsset(from: image)
                }) { success, error in
                    if success {
                        continuation.resume()
                    } else {
                        continuation.resume(throwing: error ?? NSError(
                            domain: "Photos",
                            code: 2,
                            userInfo: [NSLocalizedDescriptionKey: "Failed to save image"]
                        ))
                    }
                }
            }
        }
    }

    private func saveVideoToPhotos(_ localURL: URL) async throws {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            PHPhotoLibrary.requestAuthorization { status in
                guard status == .authorized else {
                    continuation.resume(throwing: NSError(
                        domain: "Photos",
                        code: 1,
                        userInfo: [NSLocalizedDescriptionKey: "Photo library access denied"]
                    ))
                    return
                }

                PHPhotoLibrary.shared().performChanges({
                    PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: localURL)
                }) { success, error in
                    if success {
                        continuation.resume()
                    } else {
                        continuation.resume(throwing: error ?? NSError(
                            domain: "Photos",
                            code: 2,
                            userInfo: [NSLocalizedDescriptionKey: "Failed to save video"]
                        ))
                    }
                }
            }
        }
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date())
    }

    private func formatInputValue(_ value: AnyCodable?) -> String {
        guard let value = value else { return "N/A" }

        // Handle different types
        if let string = value.value as? String {
            // Truncate long strings (e.g., base64 images)
            if string.hasPrefix("data:image") {
                return "[Image data]"
            } else if string.count > 100 {
                return String(string.prefix(100)) + "..."
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

// MARK: - Share Sheet

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: items, applicationActivities: nil)
        return controller
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

// MARK: - Preview

#if DEBUG
struct GenerationResultView_Previews: PreviewProvider {
    static var previews: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Image generation
                GenerationResultView(
                    generation: .mockImageGeneration,
                    status: .completed,
                    isLoading: false,
                    error: nil,
                    onFavoriteToggle: {},
                    onRegenerate: {}
                )

                // Loading state
                GenerationResultView(
                    generation: .mockVideoGeneration,
                    status: .processing,
                    isLoading: true,
                    error: nil,
                    onFavoriteToggle: {},
                    onRegenerate: {}
                )

                // Error state
                GenerationResultView(
                    generation: .mockImageGeneration,
                    status: .failed,
                    isLoading: false,
                    error: "Insufficient credits",
                    onFavoriteToggle: {},
                    onRegenerate: {}
                )
            }
            .padding()
        }
        .background(Color.black)
        .preferredColorScheme(.dark)
    }
}
#endif
