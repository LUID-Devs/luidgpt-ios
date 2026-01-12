//
//  AuthenticationView.swift
//  LuidGPT
//
//  Main authentication flow container (Login/Register/Verification)
//

import SwiftUI

/// Main authentication view that handles navigation between login, register, and verification
struct AuthenticationView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var showingRegister = false

    var body: some View {
        ZStack {
            LGColors.background
                .ignoresSafeArea()

            if let email = authViewModel.pendingVerificationEmail {
                // Show email verification screen
                VerifyEmailView(email: email)
                    .transition(.move(edge: .trailing))
            } else if showingRegister {
                // Show registration screen
                RegisterView(showingRegister: $showingRegister)
                    .transition(.move(edge: .trailing))
            } else {
                // Show login screen
                LoginView(showingRegister: $showingRegister)
                    .transition(.move(edge: .leading))
            }
        }
        .animation(.easeInOut, value: showingRegister)
        .animation(.easeInOut, value: authViewModel.pendingVerificationEmail)
    }
}

// MARK: - Preview

#if DEBUG
struct AuthenticationView_Previews: PreviewProvider {
    static var previews: some View {
        AuthenticationView()
            .environmentObject(AuthViewModel())
    }
}
#endif
