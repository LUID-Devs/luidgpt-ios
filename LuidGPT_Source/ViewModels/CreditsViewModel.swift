//
//  CreditsViewModel.swift
//  LuidGPT
//
//  ViewModel for managing credit balance and transactions
//

import Foundation
import SwiftUI
import os.log

@MainActor
class CreditsViewModel: ObservableObject {
    // MARK: - Published Properties

    @Published var balance: CreditBalance?
    @Published var transactions: [CreditTransaction] = []
    @Published var packages: [CreditPackage] = []

    @Published var isLoading = false
    @Published var isRefreshing = false
    @Published var errorMessage: String?

    @Published var currentPage = 1
    @Published var hasMoreTransactions = false

    // MARK: - Dependencies

    private let creditService = CreditService.shared
    private let logger = OSLog(subsystem: "com.luidgpt.LuidGPT", category: "CreditsViewModel")

    // MARK: - Computed Properties

    var totalCredits: Int {
        balance?.totalCredits ?? 0
    }

    var isLowBalance: Bool {
        totalCredits < AppConfig.lowCreditsThreshold
    }

    var formattedBalance: String {
        return "\(totalCredits) credits"
    }

    // MARK: - Public Methods

    /// Fetch credit balance
    func fetchBalance() async {
        NSLog("💳 CreditsViewModel: Fetching balance...")
        os_log("💳 CreditsViewModel: Fetching balance...", log: logger, type: .info)

        // Don't show loading if we already have data (silent refresh)
        if balance == nil {
            isLoading = true
        }
        errorMessage = nil

        do {
            let newBalance = try await creditService.getBalance()
            self.balance = newBalance

            NSLog("💳 CreditsViewModel: Balance updated - %d credits", newBalance.totalCredits)
            os_log("💳 CreditsViewModel: Balance updated - %{public}d credits", log: logger, type: .info, newBalance.totalCredits)

        } catch let error as APIError {
            NSLog("❌ CreditsViewModel: Failed to fetch balance - %@", error.localizedDescription)
            os_log("❌ CreditsViewModel: Failed to fetch balance - %{public}@", log: logger, type: .error, error.localizedDescription)
            self.errorMessage = error.localizedDescription
        } catch {
            NSLog("❌ CreditsViewModel: Unexpected error - %@", error.localizedDescription)
            os_log("❌ CreditsViewModel: Unexpected error - %{public}@", log: logger, type: .error, error.localizedDescription)
            self.errorMessage = "Failed to load credit balance"
        }

        isLoading = false
        isRefreshing = false
    }

    /// Refresh credit balance (with loading indicator)
    func refreshBalance() async {
        NSLog("💳 CreditsViewModel: Refreshing balance...")
        isRefreshing = true
        await fetchBalance()
    }

    /// Fetch credit transaction history
    func fetchTransactions(page: Int = 1) async {
        NSLog("💳 CreditsViewModel: Fetching transactions (page: %d)...", page)
        os_log("💳 CreditsViewModel: Fetching transactions (page: %{public}d)...", log: logger, type: .info, page)

        if page == 1 {
            isLoading = true
        }
        errorMessage = nil

        do {
            let result = try await creditService.getTransactions(page: page, limit: AppConfig.defaultPageSize)

            if page == 1 {
                self.transactions = result.transactions
            } else {
                self.transactions.append(contentsOf: result.transactions)
            }

            self.currentPage = page
            self.hasMoreTransactions = result.pagination?.hasMore ?? false

            NSLog("💳 CreditsViewModel: Loaded %d transactions", result.transactions.count)
            os_log("💳 CreditsViewModel: Loaded %{public}d transactions", log: logger, type: .info, result.transactions.count)

        } catch let error as APIError {
            NSLog("❌ CreditsViewModel: Failed to fetch transactions - %@", error.localizedDescription)
            os_log("❌ CreditsViewModel: Failed to fetch transactions - %{public}@", log: logger, type: .error, error.localizedDescription)
            self.errorMessage = error.localizedDescription
        } catch {
            NSLog("❌ CreditsViewModel: Unexpected error - %@", error.localizedDescription)
            os_log("❌ CreditsViewModel: Unexpected error - %{public}@", log: logger, type: .error, error.localizedDescription)
            self.errorMessage = "Failed to load transactions"
        }

        isLoading = false
    }

    /// Load more transactions (pagination)
    func loadMoreTransactions() async {
        guard hasMoreTransactions, !isLoading else { return }
        await fetchTransactions(page: currentPage + 1)
    }

    /// Fetch available credit packages
    func fetchPackages() async {
        NSLog("💳 CreditsViewModel: Fetching packages...")
        os_log("💳 CreditsViewModel: Fetching packages...", log: logger, type: .info)

        isLoading = true
        errorMessage = nil

        do {
            let newPackages = try await creditService.getPackages()
            self.packages = newPackages

            NSLog("💳 CreditsViewModel: Loaded %d packages", newPackages.count)
            os_log("💳 CreditsViewModel: Loaded %{public}d packages", log: logger, type: .info, newPackages.count)

        } catch let error as APIError {
            NSLog("❌ CreditsViewModel: Failed to fetch packages - %@", error.localizedDescription)
            os_log("❌ CreditsViewModel: Failed to fetch packages - %{public}@", log: logger, type: .error, error.localizedDescription)
            self.errorMessage = error.localizedDescription
        } catch {
            NSLog("❌ CreditsViewModel: Unexpected error - %@", error.localizedDescription)
            os_log("❌ CreditsViewModel: Unexpected error - %{public}@", log: logger, type: .error, error.localizedDescription)
            self.errorMessage = "Failed to load credit packages"
        }

        isLoading = false
    }

    /// Create Stripe checkout session and return URL
    func purchaseCredits(packageId: String) async -> String? {
        NSLog("💳 CreditsViewModel: Purchasing package: %@", packageId)
        os_log("💳 CreditsViewModel: Purchasing package: %{public}@", log: logger, type: .info, packageId)

        isLoading = true
        errorMessage = nil

        do {
            let checkoutURL = try await creditService.createCheckoutSession(packageId: packageId)

            NSLog("💳 CreditsViewModel: Checkout URL created: %@", checkoutURL)
            os_log("💳 CreditsViewModel: Checkout URL created: %{public}@", log: logger, type: .info, checkoutURL)

            isLoading = false
            return checkoutURL

        } catch let error as APIError {
            NSLog("❌ CreditsViewModel: Failed to create checkout - %@", error.localizedDescription)
            os_log("❌ CreditsViewModel: Failed to create checkout - %{public}@", log: logger, type: .error, error.localizedDescription)
            self.errorMessage = error.localizedDescription
        } catch {
            NSLog("❌ CreditsViewModel: Unexpected error - %@", error.localizedDescription)
            os_log("❌ CreditsViewModel: Unexpected error - %{public}@", log: logger, type: .error, error.localizedDescription)
            self.errorMessage = "Failed to create checkout session"
        }

        isLoading = false
        return nil
    }

    /// Deduct credits locally after model execution (optimistic update)
    /// The actual balance will be refreshed from server
    func deductCreditsOptimistically(amount: Int) {
        guard var currentBalance = balance else { return }

        NSLog("💳 CreditsViewModel: Optimistically deducting %d credits", amount)
        os_log("💳 CreditsViewModel: Optimistically deducting %{public}d credits", log: logger, type: .info, amount)

        // Update balance optimistically
        currentBalance = CreditBalance(
            totalCredits: max(0, currentBalance.totalCredits - amount),
            subscriptionCredits: currentBalance.subscriptionCredits,
            purchasedCredits: max(0, currentBalance.purchasedCredits - amount),
            promotionalCredits: currentBalance.promotionalCredits,
            plan: currentBalance.plan,
            periodStart: currentBalance.periodStart,
            periodEnd: currentBalance.periodEnd,
            nextReset: currentBalance.nextReset
        )

        self.balance = currentBalance

        // Refresh from server to get accurate balance
        Task {
            await fetchBalance()
        }
    }

    /// Check if user has sufficient credits
    func hasSufficientCredits(required: Int) -> Bool {
        return totalCredits >= required
    }

    /// Clear error message
    func clearError() {
        errorMessage = nil
    }

    /// Reset state (e.g., on logout)
    func reset() {
        NSLog("💳 CreditsViewModel: Resetting state...")
        os_log("💳 CreditsViewModel: Resetting state...", log: logger, type: .info)

        balance = nil
        transactions = []
        packages = []
        isLoading = false
        isRefreshing = false
        errorMessage = nil
        currentPage = 1
        hasMoreTransactions = false
    }
}
