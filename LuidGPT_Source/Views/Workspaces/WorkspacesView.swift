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
            Color.black.ignoresSafeArea()

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
                    .foregroundColor(.white)

                Text("\(viewModel.workspaces.count) workspace\(viewModel.workspaces.count == 1 ? "" : "s")")
                    .font(LGFonts.small)
                    .foregroundColor(Color(white: 0.5))
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
                .foregroundColor(.black)
                .padding(.horizontal, LGSpacing.md)
                .padding(.vertical, LGSpacing.sm)
                .background(.white)
                .cornerRadius(10)
            }
        }
    }

    // MARK: - Current Workspace Section

    private func currentWorkspaceSection(workspace: Organization) -> some View {
        VStack(alignment: .leading, spacing: LGSpacing.md) {
            HStack {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.white)
                Text("Current Workspace")
                    .font(LGFonts.small.weight(.semibold))
                    .foregroundColor(.white)
            }

            VStack(alignment: .leading, spacing: LGSpacing.md) {
                HStack(spacing: LGSpacing.md) {
                    // Workspace icon - white with black text
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [
                                        .white,
                                        Color(white: 0.7)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 60, height: 60)

                        Text(workspace.initials)
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.black)
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        Text(workspace.name)
                            .font(LGFonts.h4)
                            .foregroundColor(.white)

                        if let role = workspace.role {
                            // Grayscale role badge
                            Text(role.capitalized)
                                .font(.system(size: 10, weight: .semibold))
                                .foregroundColor(.black)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color(white: 0.6))
                                .cornerRadius(4)
                        }

                        if let memberCount = workspace.memberCount, memberCount > 1 {
                            HStack(spacing: 4) {
                                Image(systemName: "person.2.fill")
                                    .font(.system(size: 12))
                                Text("\(memberCount) members")
                                    .font(LGFonts.small)
                            }
                            .foregroundColor(Color(white: 0.6))
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
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(.white)
                    .cornerRadius(10)
                }
            }
            .padding(LGSpacing.lg)
            .background(Color(white: 0.07))
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(.white, lineWidth: 2)
            )
        }
    }

    // MARK: - Workspaces List Section

    private var workspacesListSection: some View {
        VStack(alignment: .leading, spacing: LGSpacing.md) {
            Text("All Workspaces")
                .font(LGFonts.h3)
                .foregroundColor(.white)

            if viewModel.isLoading {
                ProgressView()
                    .tint(.white)
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
                .foregroundColor(Color(white: 0.3))

            Text("No workspaces yet")
                .font(LGFonts.body)
                .foregroundColor(Color(white: 0.5))

            Button(action: {
                showingCreateWorkspace = true
            }) {
                Text("Create Your First Workspace")
                    .font(LGFonts.body.weight(.semibold))
                    .foregroundColor(.black)
                    .padding(.horizontal, LGSpacing.lg)
                    .padding(.vertical, LGSpacing.md)
                    .background(.white)
                    .cornerRadius(10)
            }
        }
        .padding(LGSpacing.xl)
        .frame(maxWidth: .infinity)
        .background(Color(white: 0.07))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.white.opacity(0.1), lineWidth: 1)
        )
    }
}

// MARK: - Workspace Card Component

struct WorkspaceCard: View {
    let workspace: Organization
    let isCurrent: Bool
    let onSwitch: () -> Void

    var body: some View {
        HStack(spacing: LGSpacing.md) {
            // Workspace icon with white border
            ZStack {
                Circle()
                    .fill(Color(white: 0.15))
                    .frame(width: 48, height: 48)
                    .overlay(
                        Circle()
                            .stroke(.white, lineWidth: 1)
                    )

                Text(workspace.initials)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(workspace.name)
                    .font(LGFonts.body.weight(.semibold))
                    .foregroundColor(.white)

                HStack(spacing: LGSpacing.xs) {
                    if let role = workspace.role {
                        // Grayscale role badge
                        Text(role.capitalized)
                            .font(.system(size: 9, weight: .semibold))
                            .foregroundColor(.black)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color(white: 0.5))
                            .cornerRadius(3)
                    }

                    if let memberCount = workspace.memberCount, memberCount > 1 {
                        Text("•")
                            .foregroundColor(Color(white: 0.4))
                        Text("\(memberCount) members")
                            .font(LGFonts.small)
                            .foregroundColor(Color(white: 0.5))
                    }
                }
            }

            Spacer()

            if isCurrent {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.white)
            } else {
                Button(action: onSwitch) {
                    Text("Switch")
                        .font(LGFonts.small.weight(.semibold))
                        .foregroundColor(.black)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(.white)
                        .cornerRadius(8)
                }
            }
        }
        .padding(LGSpacing.md)
        .background(Color(white: 0.07))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.white.opacity(0.1), lineWidth: 1)
        )
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
            .foregroundColor(.white)

            Text(label)
                .font(.system(size: 10))
                .foregroundColor(Color(white: 0.5))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(Color(white: 0.15))
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
                Color.black.ignoresSafeArea()

                VStack(spacing: LGSpacing.lg) {
                    VStack(alignment: .leading, spacing: LGSpacing.sm) {
                        Text("Workspace Name")
                            .font(LGFonts.body.weight(.semibold))
                            .foregroundColor(.white)

                        TextField("Enter workspace name", text: $workspaceName)
                            .font(LGFonts.body)
                            .foregroundColor(.white)
                            .padding(LGSpacing.md)
                            .background(Color(white: 0.07))
                            .cornerRadius(10)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
                            )
                    }

                    Button(action: {
                        onCreated(workspaceName)
                        dismiss()
                    }) {
                        Text("Create Workspace")
                            .font(LGFonts.body.weight(.semibold))
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, LGSpacing.md)
                            .background(workspaceName.isEmpty ? Color(white: 0.3) : .white)
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
                    .foregroundColor(.white)
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
