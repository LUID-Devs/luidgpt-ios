//
//  UsageView.swift
//  LuidGPT
//
//  Credit usage tracking and transaction history
//

import SwiftUI

struct UsageView: View {
    @EnvironmentObject var creditsViewModel: CreditsViewModel
    @State private var transactions: [CreditTransaction] = []
    @State private var isLoading = false

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            ScrollView {
                VStack(spacing: LGSpacing.lg) {
                    // Credit Balance Card
                    creditBalanceCard

                    // Usage Stats
                    usageStatsSection

                    // Transaction History
                    transactionHistorySection
                }
                .padding(LGSpacing.lg)
            }
        }
        .navigationTitle("Usage")
        .navigationBarTitleDisplayMode(.large)
        .task {
            await loadUsageData()
        }
    }

    // MARK: - Credit Balance Card

    private var creditBalanceCard: some View {
        VStack(spacing: LGSpacing.md) {
            HStack {
                VStack(alignment: .leading, spacing: LGSpacing.xs) {
                    Text("Available Credits")
                        .font(LGFonts.small)
                        .foregroundColor(Color(white: 0.5))

                    if creditsViewModel.isLoading {
                        ProgressView()
                            .tint(.white)
                    } else {
                        Text("\(creditsViewModel.totalCredits)")
                            .font(.system(size: 40, weight: .bold))
                            .foregroundColor(.white)
                    }
                }

                Spacer()

                Image(systemName: "sparkles")
                    .font(.system(size: 48))
                    .foregroundColor(Color(white: 0.3))
            }

            NavigationLink(destination: BillingView()) {
                HStack {
                    Text("Get More Credits")
                        .font(LGFonts.body.weight(.semibold))
                        .foregroundColor(.black)

                    Spacer()

                    Image(systemName: "arrow.right")
                        .foregroundColor(.black)
                }
                .padding(LGSpacing.md)
                .background(.white)
                .cornerRadius(10)
            }
        }
        .padding(LGSpacing.lg)
        .background(Color(white: 0.07))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.white.opacity(0.1), lineWidth: 1)
        )
    }

    // MARK: - Usage Stats

    private var usageStatsSection: some View {
        VStack(spacing: LGSpacing.md) {
            Text("Usage Statistics")
                .font(LGFonts.h3)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .leading)

            VStack(spacing: LGSpacing.sm) {
                UsageStatRow(
                    icon: "calendar",
                    title: "This Month",
                    value: "\(monthlyUsage) credits"
                )

                UsageStatRow(
                    icon: "arrow.down.circle",
                    title: "Total Used",
                    value: "\(totalUsed) credits"
                )

                UsageStatRow(
                    icon: "arrow.up.circle",
                    title: "Total Earned",
                    value: "\(totalEarned) credits"
                )
            }
        }
    }

    // MARK: - Transaction History

    private var transactionHistorySection: some View {
        VStack(spacing: LGSpacing.md) {
            Text("Transaction History")
                .font(LGFonts.h3)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .leading)

            if isLoading {
                ProgressView()
                    .tint(.white)
                    .padding(LGSpacing.xl)
            } else if transactions.isEmpty {
                VStack(spacing: LGSpacing.md) {
                    Image(systemName: "doc.text")
                        .font(.system(size: 48))
                        .foregroundColor(Color(white: 0.3))

                    Text("No transactions yet")
                        .font(LGFonts.body)
                        .foregroundColor(Color(white: 0.5))
                }
                .padding(LGSpacing.xl)
                .frame(maxWidth: .infinity)
                .background(Color(white: 0.07))
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
            } else {
                VStack(spacing: LGSpacing.xs) {
                    ForEach(transactions) { transaction in
                        TransactionRow(transaction: transaction)
                    }
                }
            }
        }
    }

    // MARK: - Helpers

    private var monthlyUsage: Int {
        let calendar = Calendar.current
        let now = Date()
        return transactions.filter { transaction in
            transaction.type == "deduct" &&
            calendar.isDate(transaction.createdAt, equalTo: now, toGranularity: .month)
        }.reduce(0) { $0 + $1.amount }
    }

    private var totalUsed: Int {
        transactions.filter { $0.type == "deduct" }.reduce(0) { $0 + $1.amount }
    }

    private var totalEarned: Int {
        transactions.filter { ["add", "purchase", "subscription"].contains($0.type) }.reduce(0) { $0 + $1.amount }
    }

    private func loadUsageData() async {
        isLoading = true
        defer { isLoading = false }

        await creditsViewModel.fetchBalance()
        // TODO: Fetch transaction history from API
        // For now, using mock data
        transactions = []
    }
}

// MARK: - Usage Stat Row

struct UsageStatRow: View {
    let icon: String
    let title: String
    let value: String

    var body: some View {
        HStack(spacing: LGSpacing.md) {
            ZStack {
                Circle()
                    .fill(Color(white: 0.15))
                    .frame(width: 40, height: 40)

                Image(systemName: icon)
                    .font(.system(size: 18))
                    .foregroundColor(.white)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(LGFonts.small)
                    .foregroundColor(Color(white: 0.5))

                Text(value)
                    .font(LGFonts.body.weight(.semibold))
                    .foregroundColor(.white)
            }

            Spacer()
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

// MARK: - Transaction Row

struct TransactionRow: View {
    let transaction: CreditTransaction

    var body: some View {
        let isCredit = ["add", "purchase", "subscription"].contains(transaction.type)

        HStack(spacing: LGSpacing.md) {
            ZStack {
                Circle()
                    .fill(Color(white: 0.15))
                    .frame(width: 40, height: 40)

                Image(systemName: isCredit ? "plus" : "minus")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(isCredit ? Color(white: 0.8) : Color(white: 0.4))
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(transaction.description ?? "Transaction")
                    .font(LGFonts.body)
                    .foregroundColor(.white)
                    .lineLimit(1)

                Text(formatDate(transaction.createdAt))
                    .font(LGFonts.small)
                    .foregroundColor(Color(white: 0.5))
            }

            Spacer()

            Text("\(isCredit ? "+" : "-")\(transaction.amount)")
                .font(LGFonts.body.weight(.semibold))
                .foregroundColor(isCredit ? Color(white: 0.8) : Color(white: 0.4))
        }
        .padding(LGSpacing.md)
        .background(Color(white: 0.07))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.white.opacity(0.1), lineWidth: 1)
        )
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}

// MARK: - Preview

#if DEBUG
struct UsageView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            UsageView()
                .environmentObject(CreditsViewModel())
        }
    }
}
#endif
