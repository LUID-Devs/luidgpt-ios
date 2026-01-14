//
//  CategoryNavigationView.swift
//  LuidGPT
//
//  Horizontal scrollable category navigation tabs
//

import SwiftUI

struct CategoryNavigationView: View {
    let categories: [Category]
    @Binding var selectedCategory: Category?
    let onCategorySelected: (Category?) -> Void

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                // "All Models" button
                CategoryButton(
                    title: "All Models",
                    icon: "square.grid.2x2",
                    isSelected: selectedCategory == nil,
                    count: totalModelCount
                ) {
                    selectedCategory = nil
                    onCategorySelected(nil)
                }

                // Category buttons
                ForEach(categories) { category in
                    CategoryButton(
                        title: category.name,
                        icon: Category.icon(for: category.slug),
                        isSelected: selectedCategory?.id == category.id,
                        colors: ModelCategoryConstants.colors(for: category.slug),
                        count: category.modelCountInt
                    ) {
                        selectedCategory = category
                        onCategorySelected(category)
                    }
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
        }
        .background(Color(.systemBackground))
    }

    private var totalModelCount: Int? {
        let total = categories.reduce(0) { $0 + ($1.modelCountInt ?? 0) }
        return total > 0 ? total : nil
    }
}

// MARK: - Category Button

struct CategoryButton: View {
    let title: String
    let icon: String
    let isSelected: Bool
    var colors: (background: Color, foreground: Color) = (
        background: Color.blue.opacity(0.2),
        foreground: Color.blue
    )
    var count: Int?
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 14, weight: .medium))

                Text(title)
                    .font(.system(size: 14, weight: .medium))

                if let count = count, count > 0 {
                    Text("\(count)")
                        .font(.system(size: 12, weight: .semibold))
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(
                            isSelected
                                ? Color.white.opacity(0.3)
                                : Color.secondary.opacity(0.2)
                        )
                        .cornerRadius(8)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                isSelected
                    ? colors.background
                    : Color(.systemGray6)
            )
            .foregroundColor(
                isSelected
                    ? colors.foreground
                    : Color.primary
            )
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(
                        isSelected ? colors.foreground.opacity(0.3) : Color.clear,
                        lineWidth: 1
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Compact Category Selector (for small screens)

struct CompactCategorySelector: View {
    let categories: [Category]
    @Binding var selectedCategory: Category?
    let onCategorySelected: (Category?) -> Void

    var body: some View {
        Menu {
            Button {
                selectedCategory = nil
                onCategorySelected(nil)
            } label: {
                Label("All Models", systemImage: "square.grid.2x2")
            }

            Divider()

            ForEach(Category.allCategories, id: \.slug) { categoryDef in
                if let category = categories.first(where: { $0.slug == categoryDef.slug }) {
                    Button {
                        selectedCategory = category
                        onCategorySelected(category)
                    } label: {
                        HStack {
                            Label(category.name, systemImage: categoryDef.icon)
                            if let count = category.modelCountInt, count > 0 {
                                Spacer()
                                Text("\(count)")
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
            }
        } label: {
            HStack {
                Image(systemName: selectedCategory == nil
                      ? "square.grid.2x2"
                      : Category.icon(for: selectedCategory?.slug ?? ""))
                Text(selectedCategory?.name ?? "All Models")
                Spacer()
                Image(systemName: "chevron.down")
                    .font(.system(size: 12, weight: .semibold))
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(10)
        }
    }
}

// MARK: - Preview

#if DEBUG
struct CategoryNavigationView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            CategoryNavigationView(
                categories: Category.mockCategories,
                selectedCategory: .constant(nil),
                onCategorySelected: { _ in }
            )

            Spacer()
        }
        .preferredColorScheme(.dark)
    }
}
#endif
