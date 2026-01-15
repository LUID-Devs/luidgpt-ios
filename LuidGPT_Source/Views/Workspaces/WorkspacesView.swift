//
//  WorkspacesView.swift
//  LuidGPT
//
//  Workspace management and team collaboration
//

import SwiftUI

struct WorkspacesView: View {
    @StateObject private var viewModel = WorkspacesViewModel()
    @State private var showingCreateWorkspace = false

    var body: some View {
        ZStack {
            LGColors.background.ignoresSafeArea()

            ScrollView {
                VStack(spacing: LGSpacing.lg) {
                    // Header with create button
                    headerSection

                    // Current Workspace
                    if let currentWorkspace = viewModel.currentWorkspace {
                        currentWorkspaceSection(workspace: currentWorkspace)
                    }

                    // All Workspaces
                    workspacesListSection
                }
                .padding(LGSpacing.lg)
            }
        }
        .navigationTitle("Workspaces")
        .navigationBarTitleDisplayMode(.large)
        .task {
            await viewModel.loadWorkspaces()
        }
        .sheet(isPresented: $showingCreateWorkspace) {
            CreateWorkspaceSheet(onCreated: { name in
                Task {
                    await viewModel.createWorkspace(name: name)
                }
            })
        }
    }

    // MARK: - Header Section

    private var headerSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Your Workspaces")
                    .font(LGFonts.h3)
                    .foregroundColor(.black)

                Text("\(viewModel.workspaces.count) workspace\(viewModel.workspaces.count == 1 ? "" : "s")")
                    .font(LGFonts.small)
                    .foregroundColor(LGColors.neutral600)
            }

            Spacer()

            Button(action: {
                showingCreateWorkspace = true
            }) {
                HStack(spacing: 6) {
                    Image(systemName: "plus")
                        .font(.system(size: 14, weight: .semibold))
                    Text("New")
                        .font(LGFonts.body.weight(.semibold))
                }
                .foregroundColor(.white)
                .padding(.horizontal, LGSpacing.md)
                .padding(.vertical, LGSpacing.sm)
                .background(LGColors.VideoGeneration.main)
                .cornerRadius(10)
            }
        }
    }

    // MARK: - Current Workspace Section

    private func currentWorkspaceSection(workspace: Organization) -> some View {
        VStack(alignment: .leading, spacing: LGSpacing.md) {
            HStack {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(LGColors.success)
                Text("Current Workspace")
                    .font(LGFonts.small.weight(.semibold))
                    .foregroundColor(LGColors.success)
            }

            VStack(alignment: .leading, spacing: LGSpacing.md) {
                HStack(spacing: LGSpacing.md) {
                    // Workspace icon
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [
                                        LGColors.VideoGeneration.main,
                                        LGColors.ImageGeneration.main
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 60, height: 60)

                        Text(workspace.initials)
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.white)
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        Text(workspace.name)
                            .font(LGFonts.h4)
                            .foregroundColor(.black)

                        if let role = workspace.role {
                            Text(role.capitalized)
                                .font(LGFonts.small)
                                .foregroundColor(LGColors.neutral600)
                        }

                        if let memberCount = workspace.memberCount, memberCount > 1 {
                            HStack(spacing: 4) {
                                Image(systemName: "person.2.fill")
                                    .font(.system(size: 12))
                                Text("\(memberCount) members")
                                    .font(LGFonts.small)
                            }
                            .foregroundColor(LGColors.blue500)
                        }
                    }

                    Spacer()
                }

                // Quick stats
                HStack(spacing: LGSpacing.sm) {
                    WorkspaceStatBadge(
                        icon: "photo.stack",
                        value: "\(workspace.generationsCount ?? 0)",
                        label: "Generations"
                    )

                    WorkspaceStatBadge(
                        icon: "sparkles",
                        value: "\(workspace.creditsUsed ?? 0)",
                        label: "Credits Used"
                    )
                }

                // Manage button
                Button(action: {
                    // Navigate to workspace settings
                }) {
                    HStack {
                        Image(systemName: "gearshape")
                        Text("Manage Workspace")
                            .font(LGFonts.body.weight(.semibold))
                    }
                    .foregroundColor(LGColors.VideoGeneration.main)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(LGColors.VideoGeneration.main.opacity(0.1))
                    .cornerRadius(10)
                }
            }
            .padding(LGSpacing.lg)
            .background(Color.white)
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(LGColors.success, lineWidth: 2)
            )
        }
    }

    // MARK: - Workspaces List Section

    private var workspacesListSection: some View {
        VStack(alignment: .leading, spacing: LGSpacing.md) {
            Text("All Workspaces")
                .font(LGFonts.h3)
                .foregroundColor(.black)

            if viewModel.isLoading {
                ProgressView()
                    .padding(LGSpacing.xl)
                    .frame(maxWidth: .infinity)
            } else if viewModel.workspaces.isEmpty {
                emptyStateView
            } else {
                VStack(spacing: LGSpacing.sm) {
                    ForEach(viewModel.workspaces) { workspace in
                        WorkspaceCard(
                            workspace: workspace,
                            isCurrent: workspace.id == viewModel.currentWorkspace?.id,
                            onSwitch: {
                                Task {
                                    await viewModel.switchWorkspace(to: workspace)
                                }
                            }
                        )
                    }
                }
            }
        }
    }

    private var emptyStateView: some View {
        VStack(spacing: LGSpacing.md) {
            Image(systemName: "building.2")
                .font(.system(size: 48))
                .foregroundColor(LGColors.neutral400)

            Text("No workspaces yet")
                .font(LGFonts.body)
                .foregroundColor(LGColors.neutral600)

            Button(action: {
                showingCreateWorkspace = true
            }) {
                Text("Create Your First Workspace")
                    .font(LGFonts.body.weight(.semibold))
                    .foregroundColor(.white)
                    .padding(.horizontal, LGSpacing.lg)
                    .padding(.vertical, LGSpacing.md)
                    .background(LGColors.VideoGeneration.main)
                    .cornerRadius(10)
            }
        }
        .padding(LGSpacing.xl)
        .frame(maxWidth: .infinity)
        .background(Color.white)
        .cornerRadius(12)
    }
}

// MARK: - Workspace Card Component

struct WorkspaceCard: View {
    let workspace: Organization
    let isCurrent: Bool
    let onSwitch: () -> Void

    var body: some View {
        HStack(spacing: LGSpacing.md) {
            // Workspace icon
            ZStack {
                Circle()
                    .fill(LGColors.neutral100)
                    .frame(width: 48, height: 48)

                Text(workspace.initials)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(LGColors.neutral700)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(workspace.name)
                    .font(LGFonts.body.weight(.semibold))
                    .foregroundColor(.black)

                HStack(spacing: LGSpacing.xs) {
                    if let role = workspace.role {
                        Text(role.capitalized)
                            .font(LGFonts.small)
                            .foregroundColor(LGColors.neutral600)
                    }

                    if let memberCount = workspace.memberCount, memberCount > 1 {
                        Text("•")
                            .foregroundColor(LGColors.neutral400)
                        Text("\(memberCount) members")
                            .font(LGFonts.small)
                            .foregroundColor(LGColors.neutral600)
                    }
                }
            }

            Spacer()

            if isCurrent {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(LGColors.success)
            } else {
                Button(action: onSwitch) {
                    Text("Switch")
                        .font(LGFonts.small.weight(.semibold))
                        .foregroundColor(LGColors.blue500)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(LGColors.blue500.opacity(0.1))
                        .cornerRadius(8)
                }
            }
        }
        .padding(LGSpacing.md)
        .background(Color.white)
        .cornerRadius(12)
    }
}

// MARK: - Workspace Stat Badge

struct WorkspaceStatBadge: View {
    let icon: String
    let value: String
    let label: String

    var body: some View {
        VStack(spacing: 4) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 12))
                Text(value)
                    .font(.system(size: 14, weight: .bold))
            }
            .foregroundColor(LGColors.VideoGeneration.main)

            Text(label)
                .font(.system(size: 10))
                .foregroundColor(LGColors.neutral600)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(LGColors.neutral100)
        .cornerRadius(8)
    }
}

// MARK: - Create Workspace Sheet

struct CreateWorkspaceSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var workspaceName = ""
    let onCreated: (String) -> Void

    var body: some View {
        NavigationView {
            ZStack {
                LGColors.background.ignoresSafeArea()

                VStack(spacing: LGSpacing.lg) {
                    VStack(alignment: .leading, spacing: LGSpacing.sm) {
                        Text("Workspace Name")
                            .font(LGFonts.body.weight(.semibold))
                            .foregroundColor(.black)

                        TextField("Enter workspace name", text: $workspaceName)
                            .font(LGFonts.body)
                            .padding(LGSpacing.md)
                            .background(Color.white)
                            .cornerRadius(10)
                    }

                    Button(action: {
                        onCreated(workspaceName)
                        dismiss()
                    }) {
                        Text("Create Workspace")
                            .font(LGFonts.body.weight(.semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, LGSpacing.md)
                            .background(workspaceName.isEmpty ? LGColors.neutral400 : LGColors.VideoGeneration.main)
                            .cornerRadius(10)
                    }
                    .disabled(workspaceName.isEmpty)

                    Spacer()
                }
                .padding(LGSpacing.lg)
            }
            .navigationTitle("New Workspace")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Workspaces ViewModel

@MainActor
class WorkspacesViewModel: ObservableObject {
    @Published var workspaces: [Organization] = []
    @Published var currentWorkspace: Organization?
    @Published var isLoading = false
    @Published var error: String?

    private let workspacesAPI = WorkspacesAPIService.shared

    func loadWorkspaces() async {
        isLoading = true
        error = nil
        defer { isLoading = false }

        do {
            workspaces = try await workspacesAPI.fetchWorkspaces()

            // Set first workspace as current if none selected
            if currentWorkspace == nil, let first = workspaces.first {
                currentWorkspace = first
            }
        } catch {
            self.error = error.localizedDescription
            print("❌ Error loading workspaces: \(error)")
        }
    }

    func createWorkspace(name: String) async {
        do {
            let newWorkspace = try await workspacesAPI.createWorkspace(
                name: name,
                description: nil,
                logo: nil
            )
            workspaces.append(newWorkspace)

            // Set as current workspace if it's the first one
            if workspaces.count == 1 {
                currentWorkspace = newWorkspace
            }
        } catch {
            self.error = error.localizedDescription
            print("❌ Error creating workspace: \(error)")
        }
    }

    func switchWorkspace(to workspace: Organization) async {
        currentWorkspace = workspace
        // TODO: Persist current workspace selection to UserDefaults
        // UserDefaults.standard.set(workspace.id, forKey: "currentWorkspaceId")
    }
}

// MARK: - Preview

#if DEBUG
struct WorkspacesView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            WorkspacesView()
        }
    }
}
#endif
