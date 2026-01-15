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
            LGColors.background.ignoresSafeArea()

            ScrollView {
                VStack(spacing: LGSpacing.lg) {
                    // Header
                    VStack(spacing: LGSpacing.sm) {
                        Text("Choose Your Plan")
                            .font(LGFonts.h2)
                            .foregroundColor(.black)

                        Text("Upgrade to unlock more credits and features")
                            .font(LGFonts.body)
                            .foregroundColor(LGColors.neutral600)
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
                            color: LGColors.ImageEditing.main,
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
                            color: LGColors.blue500,
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
                            color: LGColors.VideoGeneration.main,
                            isSelected: selectedPlan == "premium"
                        ) {
                            selectedPlan = "premium"
                        }
                    }

                    // Subscribe Button
                    if selectedPlan != nil {
                        LGButton("Subscribe to \(selectedPlan!.capitalized)", style: .primary, fullWidth: true) {
                            // Handle subscription
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
    let color: Color
    let isSelected: Bool
    var isPopular: Bool = false
    let onSelect: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: LGSpacing.md) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(name)
                        .font(LGFonts.h4)
                        .foregroundColor(.black)

                    HStack(alignment: .firstTextBaseline, spacing: 4) {
                        Text(price)
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(.black)

                        Text(period)
                            .font(LGFonts.small)
                            .foregroundColor(LGColors.neutral600)
                    }
                }

                Spacer()

                if isPopular {
                    Text("POPULAR")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(color)
                        .cornerRadius(4)
                }
            }

            // Credits
            HStack {
                Image(systemName: "sparkles")
                    .foregroundColor(color)
                Text(credits)
                    .font(LGFonts.body.weight(.semibold))
                    .foregroundColor(color)
            }

            Divider()

            // Features
            VStack(alignment: .leading, spacing: LGSpacing.sm) {
                ForEach(features, id: \.self) { feature in
                    HStack(spacing: LGSpacing.sm) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 16))
                            .foregroundColor(color)

                        Text(feature)
                            .font(LGFonts.small)
                            .foregroundColor(.black)
                    }
                }
            }

            // Select Button
            Button(action: onSelect) {
                Text(isSelected ? "Selected" : "Select Plan")
                    .font(LGFonts.body.weight(.semibold))
                    .foregroundColor(isSelected ? .white : color)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(isSelected ? color : color.opacity(0.1))
                    .cornerRadius(10)
            }
        }
        .padding(LGSpacing.lg)
        .background(Color.white)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(isSelected ? color : Color.clear, lineWidth: 2)
        )
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
