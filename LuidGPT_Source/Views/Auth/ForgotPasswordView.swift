//
//  ForgotPasswordView.swift
//  LuidGPT
//
//  Password reset flow with code verification
//

import SwiftUI

struct ForgotPasswordView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.dismiss) var dismiss

    @State private var step: ResetStep = .requestCode
    @State private var email = ""
    @State private var code = ""
    @State private var newPassword = ""
    @State private var confirmPassword = ""
    @State private var showSuccess = false
    @FocusState private var focusedField: Field?

    enum ResetStep {
        case requestCode
        case enterCode
        case newPassword
    }

    enum Field {
        case email, code, newPassword, confirmPassword
    }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 0) {
                    // Header
                    headerSection
                        .padding(.top, 40)
                        .padding(.bottom, 32)

                    // Step content
                    stepContentSection
                        .padding(.horizontal, LGSpacing.lg)

                    Spacer(minLength: 40)
                }
            }
            .background(LGColors.background)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .foregroundColor(LGColors.foregroundSecondary)
                    }
                }
            }
            .alert("Password Reset Successful", isPresented: $showSuccess) {
                Button("Go to Login") {
                    dismiss()
                }
            } message: {
                Text("Your password has been reset successfully. You can now login with your new password.")
            }
        }
    }

    // MARK: - Header Section

    private var headerSection: some View {
        VStack(spacing: 16) {
            // Icon with elegant black and white design
            ZStack {
                // Outer circle with white border
                Circle()
                    .stroke(LGColors.border, lineWidth: 1.5)
                    .frame(width: 60, height: 60)

                // Inner circle with gradient fill
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                LGColors.neutral800,
                                LGColors.background
                            ],
                            center: .center,
                            startRadius: 5,
                            endRadius: 30
                        )
                    )
                    .frame(width: 57, height: 57)

                Image(systemName: iconName)
                    .font(.system(size: 28))
                    .foregroundColor(LGColors.foreground)
            }
            .shadow(color: LGColors.glow.opacity(0.5), radius: 15, x: 0, y: 0)

            Text(headerTitle)
                .font(LGFonts.h3)
                .foregroundColor(LGColors.foreground)

            Text(headerSubtitle)
                .font(LGFonts.body)
                .foregroundColor(LGColors.foregroundSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, LGSpacing.md)
        }
    }

    // MARK: - Step Content

    @ViewBuilder
    private var stepContentSection: some View {
        switch step {
        case .requestCode:
            requestCodeForm
        case .enterCode:
            enterCodeForm
        case .newPassword:
            newPasswordForm
        }
    }

    // MARK: - Request Code Form

    private var requestCodeForm: some View {
        VStack(spacing: 20) {
            // Error message
            if let errorMessage = authViewModel.errorMessage {
                errorMessageBanner(errorMessage)
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
                .submitLabel(.go)
                .onSubmit {
                    handleRequestCode()
                }
            }

            // Send code button
            LGButton(
                "Send Reset Code",
                style: .primary,
                isLoading: authViewModel.isLoading,
                fullWidth: true
            ) {
                handleRequestCode()
            }
            .padding(.top, 8)
        }
    }

    // MARK: - Enter Code Form

    private var enterCodeForm: some View {
        VStack(spacing: 20) {
            // Error message
            if let errorMessage = authViewModel.errorMessage {
                errorMessageBanner(errorMessage)
            }

            // Show email
            HStack {
                Text("Code sent to:")
                    .font(LGFonts.small)
                    .foregroundColor(LGColors.foregroundTertiary)

                Text(email)
                    .font(LGFonts.small.weight(.semibold))
                    .foregroundColor(LGColors.foreground)

                Spacer()

                Button(action: { step = .requestCode }) {
                    Text("Change")
                        .font(LGFonts.small)
                        .foregroundColor(LGColors.foregroundSecondary)
                }
            }
            .padding(LGSpacing.sm)
            .background(LGColors.backgroundCard)
            .cornerRadius(LGSpacing.buttonRadius)
            .overlay(
                RoundedRectangle(cornerRadius: LGSpacing.buttonRadius)
                    .stroke(LGColors.border, lineWidth: 1)
            )

            // Code field
            VStack(alignment: .leading, spacing: 8) {
                Text("Verification Code")
                    .font(LGFonts.label)
                    .foregroundColor(LGColors.foreground)

                LGTextField(
                    text: $code,
                    placeholder: "Enter 6-digit code",
                    icon: "number",
                    keyboardType: .numberPad
                )
                .focused($focusedField, equals: .code)
                .onSubmit {
                    handleVerifyCode()
                }
            }

            // Continue button
            LGButton(
                "Continue",
                style: .primary,
                isLoading: authViewModel.isLoading,
                fullWidth: true
            ) {
                handleVerifyCode()
            }
            .padding(.top, 8)

            // Resend code button
            Button(action: handleRequestCode) {
                Text("Didn't receive the code? Resend")
                    .font(LGFonts.small)
                    .foregroundColor(LGColors.foregroundTertiary)
            }
        }
    }

    // MARK: - New Password Form

    private var newPasswordForm: some View {
        VStack(spacing: 20) {
            // Error message
            if let errorMessage = authViewModel.errorMessage {
                errorMessageBanner(errorMessage)
            }

            // New password field
            VStack(alignment: .leading, spacing: 8) {
                Text("New Password")
                    .font(LGFonts.label)
                    .foregroundColor(LGColors.foreground)

                LGTextField(
                    text: $newPassword,
                    placeholder: "••••••••",
                    icon: "lock.fill",
                    isSecure: true
                )
                .focused($focusedField, equals: .newPassword)
                .submitLabel(.next)
                .onSubmit {
                    focusedField = .confirmPassword
                }

                // Password strength (grayscale)
                if !newPassword.isEmpty {
                    Text(authViewModel.passwordStrengthDescription(newPassword))
                        .font(LGFonts.caption)
                        .foregroundColor(passwordStrengthColor)
                }
            }

            // Confirm password field
            VStack(alignment: .leading, spacing: 8) {
                Text("Confirm Password")
                    .font(LGFonts.label)
                    .foregroundColor(LGColors.foreground)

                LGTextField(
                    text: $confirmPassword,
                    placeholder: "••••••••",
                    icon: "lock.fill",
                    isError: !confirmPassword.isEmpty && newPassword != confirmPassword,
                    errorMessage: newPassword != confirmPassword ? "Passwords do not match" : nil,
                    isSecure: true
                )
                .focused($focusedField, equals: .confirmPassword)
                .submitLabel(.go)
                .onSubmit {
                    handleResetPassword()
                }
            }

            // Reset button
            LGButton(
                "Reset Password",
                style: .primary,
                isLoading: authViewModel.isLoading,
                isDisabled: newPassword.isEmpty || newPassword != confirmPassword,
                fullWidth: true
            ) {
                handleResetPassword()
            }
            .padding(.top, 8)
        }
    }

    // MARK: - Helper Views

    private func errorMessageBanner(_ message: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundColor(LGColors.errorText)

            Text(message)
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

    // MARK: - Computed Properties

    private var headerTitle: String {
        switch step {
        case .requestCode: return "Forgot Password?"
        case .enterCode: return "Enter Verification Code"
        case .newPassword: return "Create New Password"
        }
    }

    private var headerSubtitle: String {
        switch step {
        case .requestCode: return "Enter your email address and we'll send you a code to reset your password"
        case .enterCode: return "Enter the 6-digit code we sent to your email"
        case .newPassword: return "Choose a strong password for your account"
        }
    }

    private var iconName: String {
        switch step {
        case .requestCode: return "lock.fill"
        case .enterCode: return "envelope.fill"
        case .newPassword: return "key.fill"
        }
    }

    private var passwordStrengthColor: Color {
        let strength = authViewModel.passwordStrengthDescription(newPassword)
        switch strength {
        case "Weak": return LGColors.neutral500      // Medium gray
        case "Fair": return LGColors.neutral400      // Medium-light gray
        case "Good", "Strong": return LGColors.foreground  // White
        default: return LGColors.neutral500
        }
    }

    // MARK: - Actions

    private func handleRequestCode() {
        focusedField = nil

        guard !email.isEmpty else {
            return
        }

        guard authViewModel.isValidEmail(email) else {
            authViewModel.errorMessage = "Please enter a valid email address"
            return
        }

        Task {
            await authViewModel.forgotPassword(email: email.lowercased().trimmingCharacters(in: .whitespaces))

            // Move to next step if no error
            if authViewModel.errorMessage == nil {
                step = .enterCode
            }
        }
    }

    private func handleVerifyCode() {
        focusedField = nil

        guard code.count == 6 else {
            authViewModel.errorMessage = "Please enter the 6-digit code"
            return
        }

        // Move to password step (code will be validated when resetting)
        step = .newPassword
    }

    private func handleResetPassword() {
        focusedField = nil

        guard !newPassword.isEmpty else {
            return
        }

        guard newPassword == confirmPassword else {
            authViewModel.errorMessage = "Passwords do not match"
            return
        }

        guard authViewModel.isValidPassword(newPassword) else {
            authViewModel.errorMessage = "Password must be at least 8 characters with uppercase, lowercase, and numbers"
            return
        }

        Task {
            await authViewModel.resetPassword(
                email: email.lowercased().trimmingCharacters(in: .whitespaces),
                code: code,
                newPassword: newPassword
            )

            // Show success and dismiss
            if authViewModel.errorMessage == nil {
                showSuccess = true
            }
        }
    }
}

// MARK: - Preview

#if DEBUG
struct ForgotPasswordView_Previews: PreviewProvider {
    static var previews: some View {
        ForgotPasswordView()
            .environmentObject(AuthViewModel())
    }
}
#endif
