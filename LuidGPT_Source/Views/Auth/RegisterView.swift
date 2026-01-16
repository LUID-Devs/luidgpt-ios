//
//  RegisterView.swift
//  LuidGPT
//
//  Registration screen with email/password signup
//

import SwiftUI

struct RegisterView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @Binding var showingRegister: Bool

    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var firstName = ""
    @State private var lastName = ""
    @FocusState private var focusedField: Field?

    enum Field {
        case firstName, lastName, email, password, confirmPassword
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Header
                headerSection
                    .padding(.top, 40)
                    .padding(.bottom, 32)

                // Registration form
                registrationFormSection
                    .padding(.horizontal, LGSpacing.lg)

                Spacer(minLength: 40)
            }
        }
        .background(LGColors.background)
    }

    // MARK: - Header Section

    private var headerSection: some View {
        VStack(spacing: 16) {
            // Back button
            HStack {
                Button(action: { showingRegister = false }) {
                    HStack(spacing: 8) {
                        Image(systemName: "chevron.left")
                        Text("Back")
                    }
                    .foregroundColor(LGColors.foregroundSecondary)
                }

                Spacer()
            }
            .padding(.horizontal, LGSpacing.lg)

            // Elegant black and white logo
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

                // Sparkles icon in white
                Image(systemName: "sparkles")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(LGColors.foreground)
            }
            .shadow(color: LGColors.glow, radius: 15, x: 0, y: 0)

            Text("Create your account")
                .font(LGFonts.h3)
                .foregroundColor(LGColors.foreground)

            Text("Start creating with 100+ AI models")
                .font(LGFonts.body)
                .foregroundColor(LGColors.foregroundSecondary)
        }
    }

    // MARK: - Registration Form Section

    private var registrationFormSection: some View {
        VStack(spacing: 20) {
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

            // Name fields
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("First Name")
                        .font(LGFonts.label)
                        .foregroundColor(LGColors.foreground)

                    LGTextField(
                        text: $firstName,
                        placeholder: "John"
                    )
                    .focused($focusedField, equals: .firstName)
                    .submitLabel(.next)
                    .onSubmit {
                        focusedField = .lastName
                    }
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("Last Name")
                        .font(LGFonts.label)
                        .foregroundColor(LGColors.foreground)

                    LGTextField(
                        text: $lastName,
                        placeholder: "Doe"
                    )
                    .focused($focusedField, equals: .lastName)
                    .submitLabel(.next)
                    .onSubmit {
                        focusedField = .email
                    }
                }
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
                Text("Password")
                    .font(LGFonts.label)
                    .foregroundColor(LGColors.foreground)

                LGTextField(
                    text: $password,
                    placeholder: "••••••••",
                    icon: "lock.fill",
                    isSecure: true
                )
                .focused($focusedField, equals: .password)
                .submitLabel(.next)
                .onSubmit {
                    focusedField = .confirmPassword
                }

                // Password strength indicator (grayscale)
                if !password.isEmpty {
                    HStack(spacing: 8) {
                        ForEach(0..<4, id: \.self) { index in
                            Rectangle()
                                .fill(passwordStrengthColor(index: index))
                                .frame(height: 4)
                                .cornerRadius(2)
                        }
                    }

                    Text(authViewModel.passwordStrengthDescription(password))
                        .font(LGFonts.caption)
                        .foregroundColor(passwordStrengthTextColor)
                }
            }

            // Confirm Password field
            VStack(alignment: .leading, spacing: 8) {
                Text("Confirm Password")
                    .font(LGFonts.label)
                    .foregroundColor(LGColors.foreground)

                LGTextField(
                    text: $confirmPassword,
                    placeholder: "••••••••",
                    icon: "lock.fill",
                    isError: !confirmPassword.isEmpty && password != confirmPassword,
                    errorMessage: password != confirmPassword ? "Passwords do not match" : nil,
                    isSecure: true
                )
                .focused($focusedField, equals: .confirmPassword)
                .submitLabel(.go)
                .onSubmit {
                    handleRegister()
                }
            }

            // Terms & Privacy
            Text("By creating an account, you agree to our Terms of Service and Privacy Policy")
                .font(LGFonts.caption)
                .foregroundColor(LGColors.foregroundTertiary)
                .multilineTextAlignment(.center)
                .padding(.top, 4)

            // Register button
            LGButton(
                "Create Account",
                style: .primary,
                isLoading: authViewModel.isLoading,
                fullWidth: true
            ) {
                handleRegister()
            }
            .padding(.top, 8)

            // Login link
            HStack(spacing: 4) {
                Text("Already have an account?")
                    .font(LGFonts.body)
                    .foregroundColor(LGColors.foregroundSecondary)

                Button(action: { showingRegister = false }) {
                    Text("Login")
                        .font(LGFonts.body.weight(.semibold))
                        .foregroundColor(LGColors.foreground)
                }
            }
            .padding(.top, 8)
        }
    }

    // MARK: - Password Strength Indicator (Grayscale)

    private func passwordStrengthColor(index: Int) -> Color {
        let strength = calculatePasswordStrength()

        if strength == 0 {
            return LGColors.neutral700
        }

        if index < strength {
            switch strength {
            case 1: return LGColors.neutral500  // Weak - Medium gray
            case 2: return LGColors.neutral400  // Fair - Medium-light gray
            case 3: return LGColors.neutral300  // Good - Light gray
            case 4: return LGColors.foreground  // Strong - White
            default: return LGColors.neutral700
            }
        }

        return LGColors.neutral700
    }

    private var passwordStrengthTextColor: Color {
        let strength = calculatePasswordStrength()
        switch strength {
        case 1: return LGColors.neutral500      // Weak - Medium gray
        case 2: return LGColors.neutral400      // Fair - Medium-light gray
        case 3, 4: return LGColors.foreground   // Good/Strong - White
        default: return LGColors.neutral500
        }
    }

    private func calculatePasswordStrength() -> Int {
        if password.isEmpty {
            return 0
        }

        var strength = 0
        if password.count >= 8 { strength += 1 }
        if password.range(of: "[A-Z]", options: .regularExpression) != nil { strength += 1 }
        if password.range(of: "[a-z]", options: .regularExpression) != nil { strength += 1 }
        if password.range(of: "[0-9]", options: .regularExpression) != nil { strength += 1 }

        // Map to 1-4 scale
        return min(strength, 4)
    }

    // MARK: - Actions

    private func handleRegister() {
        // Dismiss keyboard
        focusedField = nil

        // Validate inputs
        guard !firstName.isEmpty, !lastName.isEmpty, !email.isEmpty, !password.isEmpty else {
            return
        }

        guard password == confirmPassword else {
            authViewModel.errorMessage = "Passwords do not match"
            return
        }

        guard authViewModel.isValidEmail(email) else {
            authViewModel.errorMessage = "Please enter a valid email address"
            return
        }

        guard authViewModel.isValidPassword(password) else {
            authViewModel.errorMessage = "Password must be at least 8 characters with uppercase, lowercase, and numbers"
            return
        }

        Task {
            await authViewModel.register(
                email: email.lowercased().trimmingCharacters(in: .whitespaces),
                password: password,
                firstName: firstName.trimmingCharacters(in: .whitespaces),
                lastName: lastName.trimmingCharacters(in: .whitespaces)
            )
        }
    }
}

// MARK: - Preview

#if DEBUG
struct RegisterView_Previews: PreviewProvider {
    static var previews: some View {
        RegisterView(showingRegister: .constant(true))
            .environmentObject(AuthViewModel())
    }
}
#endif
