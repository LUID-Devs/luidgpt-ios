//
//  LoginView.swift
//  LuidGPT
//
//  Login screen with email/password authentication
//

import SwiftUI

struct LoginView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @Binding var showingRegister: Bool

    @State private var email = ""
    @State private var password = ""
    @State private var showingForgotPassword = false
    @FocusState private var focusedField: Field?

    enum Field {
        case email, password
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Header with logo
                headerSection
                    .padding(.top, 60)
                    .padding(.bottom, 48)

                // Login form
                loginFormSection
                    .padding(.horizontal, LGSpacing.lg)

                Spacer(minLength: 40)
            }
        }
        .background(LGColors.background)
        .sheet(isPresented: $showingForgotPassword) {
            ForgotPasswordView()
        }
    }

    // MARK: - Header Section

    private var headerSection: some View {
        VStack(spacing: 16) {
            // App logo
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
                    .frame(width: 80, height: 80)

                Image(systemName: "sparkles")
                    .font(.system(size: 36, weight: .bold))
                    .foregroundColor(.white)
            }

            Text("Welcome back")
                .font(LGFonts.h2)
                .foregroundColor(LGColors.foreground)

            Text("Login to continue creating with AI")
                .font(LGFonts.body)
                .foregroundColor(LGColors.neutral400)
        }
    }

    // MARK: - Login Form Section

    private var loginFormSection: some View {
        VStack(spacing: 24) {
            // Error message
            if let errorMessage = authViewModel.errorMessage {
                HStack(spacing: 12) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(LGColors.errorText)

                    Text(errorMessage)
                        .font(LGFonts.small)
                        .foregroundColor(LGColors.errorText)

                    Spacer()

                    Button(action: { authViewModel.clearError() }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(LGColors.neutral500)
                    }
                }
                .padding(LGSpacing.md)
                .background(LGColors.errorBg)
                .cornerRadius(LGSpacing.cardRadius)
                .overlay(
                    RoundedRectangle(cornerRadius: LGSpacing.cardRadius)
                        .stroke(LGColors.errorBorder, lineWidth: 1)
                )
            }

            // Email field
            VStack(alignment: .leading, spacing: 8) {
                Text("Email")
                    .font(LGFonts.label)
                    .foregroundColor(LGColors.foreground)

                LGTextField(
                    text: $email,
                    placeholder: "you@example.com",
                    icon: "envelope.fill",
                    keyboardType: .emailAddress,
                    autocapitalization: .never
                )
                .focused($focusedField, equals: .email)
                .submitLabel(.next)
                .onSubmit {
                    focusedField = .password
                }
            }

            // Password field
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Password")
                        .font(LGFonts.label)
                        .foregroundColor(LGColors.foreground)

                    Spacer()

                    Button(action: { showingForgotPassword = true }) {
                        Text("Forgot?")
                            .font(LGFonts.small)
                            .foregroundColor(LGColors.VideoGeneration.main)
                    }
                }

                LGTextField(
                    text: $password,
                    placeholder: "••••••••",
                    icon: "lock.fill",
                    isSecure: true
                )
                .focused($focusedField, equals: .password)
                .submitLabel(.go)
                .onSubmit {
                    handleLogin()
                }
            }

            // Login button
            LGButton(
                "Login",
                style: .primary,
                isLoading: authViewModel.isLoading,
                fullWidth: true
            ) {
                handleLogin()
            }
            .padding(.top, 8)

            // Register link
            HStack(spacing: 4) {
                Text("Don't have an account?")
                    .font(LGFonts.body)
                    .foregroundColor(LGColors.neutral400)

                Button(action: { showingRegister = true }) {
                    Text("Sign up")
                        .font(LGFonts.body.weight(.semibold))
                        .foregroundColor(LGColors.VideoGeneration.main)
                }
            }
            .padding(.top, 8)
        }
    }

    // MARK: - Actions

    private func handleLogin() {
        // Dismiss keyboard
        focusedField = nil

        // Validate inputs
        guard !email.isEmpty, !password.isEmpty else {
            return
        }

        Task {
            await authViewModel.login(email: email.lowercased().trimmingCharacters(in: .whitespaces), password: password)
        }
    }
}

// MARK: - Preview

#if DEBUG
struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView(showingRegister: .constant(false))
            .environmentObject(AuthViewModel())
    }
}
#endif
