//
//  BillingView.swift
//  LuidGPT
//
//  Subscription management and credit purchases
//

import SwiftUI

struct BillingView: View {
    @State private var selectedPlan: String? = nil

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            ScrollView {
                VStack(spacing: LGSpacing.lg) {
                    // Header
                    VStack(spacing: LGSpacing.sm) {
                        Text("Choose Your Plan")
                            .font(LGFonts.h2)
                            .foregroundColor(.white)

                        Text("Upgrade to unlock more credits and features")
                            .font(LGFonts.body)
                            .foregroundColor(Color(white: 0.5))
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, LGSpacing.lg)

                    // Pricing Plans
                    VStack(spacing: LGSpacing.md) {
                        PricingCard(
                            name: "Free",
                            price: "$0",
                            period: "forever",
                            credits: "10 credits/month",
                            features: [
                                "Basic AI models",
                                "Community support",
                                "10 generations/month"
                            ],
                            tier: "free",
                            isSelected: selectedPlan == "free"
                        ) {
                            selectedPlan = "free"
                        }

                        PricingCard(
                            name: "Standard",
                            price: "$19",
                            period: "/month",
                            credits: "500 credits/month",
                            features: [
                                "All AI models",
                                "Priority support",
                                "Unlimited generations",
                                "Higher quality outputs"
                            ],
                            tier: "standard",
                            isSelected: selectedPlan == "standard",
                            isPopular: true
                        ) {
                            selectedPlan = "standard"
                        }

                        PricingCard(
                            name: "Premium",
                            price: "$49",
                            period: "/month",
                            credits: "2000 credits/month",
                            features: [
                                "All Standard features",
                                "Advanced AI models",
                                "Dedicated support",
                                "API access",
                                "Team collaboration"
                            ],
                            tier: "premium",
                            isSelected: selectedPlan == "premium"
                        ) {
                            selectedPlan = "premium"
                        }
                    }

                    // Subscribe Button
                    if selectedPlan != nil {
                        Button(action: {
                            // Handle subscription
                        }) {
                            Text("Subscribe to \(selectedPlan!.capitalized)")
                                .font(LGFonts.body.weight(.semibold))
                                .foregroundColor(.black)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, LGSpacing.md)
                                .background(.white)
                                .cornerRadius(10)
                        }
                        .padding(.top, LGSpacing.md)
                    }
                }
                .padding(LGSpacing.lg)
            }
        }
        .navigationTitle("Billing")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Pricing Card

struct PricingCard: View {
    let name: String
    let price: String
    let period: String
    let credits: String
    let features: [String]
    let tier: String
    let isSelected: Bool
    var isPopular: Bool = false
    let onSelect: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: LGSpacing.md) {
            // Header with Tier Badge
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(name)
                        .font(LGFonts.h4)
                        .foregroundColor(.white)

                    HStack(alignment: .firstTextBaseline, spacing: 4) {
                        Text(price)
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(.white)

                        Text(period)
                            .font(LGFonts.small)
                            .foregroundColor(Color(white: 0.5))
                    }
                }

                Spacer()

                // Tier Badge (grayscale)
                tierBadge
            }

            // Credits
            HStack {
                Image(systemName: "sparkles")
                    .foregroundColor(.white)
                Text(credits)
                    .font(LGFonts.body.weight(.semibold))
                    .foregroundColor(.white)
            }

            Divider()
                .background(Color.white.opacity(0.2))

            // Features
            VStack(alignment: .leading, spacing: LGSpacing.sm) {
                ForEach(features, id: \.self) { feature in
                    HStack(spacing: LGSpacing.sm) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 16))
                            .foregroundColor(.white)

                        Text(feature)
                            .font(LGFonts.small)
                            .foregroundColor(.white)
                    }
                }
            }

            // Select Button
            Button(action: onSelect) {
                Text(isSelected ? "Selected" : "Select Plan")
                    .font(LGFonts.body.weight(.semibold))
                    .foregroundColor(isSelected ? .black : .white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(isSelected ? .white : Color(white: 0.15))
                    .cornerRadius(10)
            }
        }
        .padding(LGSpacing.lg)
        .background(Color(white: 0.07))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(isSelected ? .white : Color.white.opacity(0.1), lineWidth: isSelected ? 2 : 1)
        )
    }

    @ViewBuilder
    private var tierBadge: some View {
        let badgeColor = getBadgeColor()

        if isPopular {
            VStack(spacing: 4) {
                Text("POPULAR")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.black)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(.white)
                    .cornerRadius(4)

                Text(tier.uppercased())
                    .font(.system(size: 9, weight: .semibold))
                    .foregroundColor(badgeColor)
            }
        } else {
            Text(tier.uppercased())
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(.black)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(badgeColor)
                .cornerRadius(4)
        }
    }

    private func getBadgeColor() -> Color {
        switch tier {
        case "free":
            return Color(white: 0.3)
        case "standard":
            return Color(white: 0.6)
        case "premium":
            return Color(white: 0.9)
        default:
            return Color(white: 0.5)
        }
    }
}

// MARK: - Preview

#if DEBUG
struct BillingView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            BillingView()
        }
    }
}
#endif
