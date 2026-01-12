//
//  VerifyEmailView.swift
//  LuidGPT
//
//  Email verification screen with 6-digit code input
//

import SwiftUI

struct VerifyEmailView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    let email: String

    @State private var code = ""
    @State private var resendCountdown = 0
    @FocusState private var isCodeFocused: Bool

    private let codeLength = 6
    private let resendDelay = 60

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Header
                headerSection
                    .padding(.top, 60)
                    .padding(.bottom, 48)

                // Verification form
                verificationFormSection
                    .padding(.horizontal, LGSpacing.lg)

                Spacer(minLength: 40)
            }
        }
        .background(LGColors.background)
        .onAppear {
            startResendCountdown()
        }
    }

    // MARK: - Header Section

    private var headerSection: some View {
        VStack(spacing: 16) {
            // Email icon
            ZStack {
                Circle()
                    .fill(LGColors.VideoGeneration.main.opacity(0.2))
                    .frame(width: 80, height: 80)

                Image(systemName: "envelope.fill")
                    .font(.system(size: 36))
                    .foregroundColor(LGColors.VideoGeneration.main)
            }

            Text("Verify your email")
                .font(LGFonts.h2)
                .foregroundColor(LGColors.foreground)

            VStack(spacing: 8) {
                Text("We sent a verification code to")
                    .font(LGFonts.body)
                    .foregroundColor(LGColors.neutral400)

                Text(email)
                    .font(LGFonts.body.weight(.semibold))
                    .foregroundColor(LGColors.foreground)
            }
        }
    }

    // MARK: - Verification Form Section

    private var verificationFormSection: some View {
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

            // 6-digit code input
            VStack(alignment: .leading, spacing: 12) {
                Text("Verification Code")
                    .font(LGFonts.label)
                    .foregroundColor(LGColors.foreground)

                HStack(spacing: 12) {
                    ForEach(0..<codeLength, id: \.self) { index in
                        DigitBox(
                            digit: getDigit(at: index),
                            isFocused: isCodeFocused && index == code.count
                        )
                    }
                }

                // Hidden text field for keyboard input
                TextField("", text: $code)
                    .keyboardType(.numberPad)
                    .focused($isCodeFocused)
                    .opacity(0)
                    .frame(height: 1)
                    .onChange(of: code) { newValue in
                        // Limit to 6 digits
                        if newValue.count > codeLength {
                            code = String(newValue.prefix(codeLength))
                        }
                        // Auto-submit when 6 digits entered
                        if code.count == codeLength {
                            handleVerify()
                        }
                    }

                // Tap to focus hint
                if !isCodeFocused {
                    Button(action: { isCodeFocused = true }) {
                        HStack(spacing: 8) {
                            Image(systemName: "keyboard")
                                .font(.system(size: 14))
                            Text("Tap to enter code")
                                .font(LGFonts.small)
                        }
                        .foregroundColor(LGColors.neutral500)
                    }
                }
            }

            // Verify button
            LGButton(
                "Verify Email",
                style: .primary,
                isLoading: authViewModel.isLoading,
                isDisabled: code.count != codeLength,
                fullWidth: true
            ) {
                handleVerify()
            }
            .padding(.top, 8)

            // Resend code
            VStack(spacing: 12) {
                if resendCountdown > 0 {
                    Text("Resend code in \(resendCountdown)s")
                        .font(LGFonts.body)
                        .foregroundColor(LGColors.neutral500)
                } else {
                    Button(action: handleResendCode) {
                        HStack(spacing: 8) {
                            Image(systemName: "arrow.clockwise")
                            Text("Resend verification code")
                        }
                        .font(LGFonts.body)
                        .foregroundColor(LGColors.VideoGeneration.main)
                    }
                }

                // Wrong email?
                Button(action: {
                    authViewModel.pendingVerificationEmail = nil
                }) {
                    Text("Wrong email? Go back")
                        .font(LGFonts.small)
                        .foregroundColor(LGColors.neutral500)
                }
            }
            .padding(.top, 16)
        }
        .onAppear {
            // Auto-focus code field
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                isCodeFocused = true
            }
        }
    }

    // MARK: - Helper Methods

    private func getDigit(at index: Int) -> String {
        guard index < code.count else { return "" }
        let digitIndex = code.index(code.startIndex, offsetBy: index)
        return String(code[digitIndex])
    }

    private func startResendCountdown() {
        resendCountdown = resendDelay
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            if resendCountdown > 0 {
                resendCountdown -= 1
            } else {
                timer.invalidate()
            }
        }
    }

    // MARK: - Actions

    private func handleVerify() {
        guard code.count == codeLength else { return }

        isCodeFocused = false

        Task {
            await authViewModel.verifyEmail(email: email, code: code)
        }
    }

    private func handleResendCode() {
        code = ""
        startResendCountdown()

        Task {
            await authViewModel.resendVerificationCode(email: email)
        }
    }
}

// MARK: - Digit Box Component

struct DigitBox: View {
    let digit: String
    let isFocused: Bool

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(LGColors.neutral800)
                .frame(width: 50, height: 60)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(
                            isFocused ? LGColors.VideoGeneration.main : LGColors.neutral700,
                            lineWidth: isFocused ? 2 : 1
                        )
                )

            Text(digit)
                .font(.system(size: 28, weight: .semibold))
                .foregroundColor(LGColors.foreground)
        }
    }
}

// MARK: - Preview

#if DEBUG
struct VerifyEmailView_Previews: PreviewProvider {
    static var previews: some View {
        VerifyEmailView(email: "test@example.com")
            .environmentObject(AuthViewModel())
    }
}
#endif
