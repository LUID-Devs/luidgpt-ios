//
//  LGTextField.swift
//  LuidGPT
//
//  Text field and text area components matching web inputs
//

import SwiftUI

/// Text field style
enum LGTextFieldStyle {
    case standard
    case password
    case search
}

/// LuidGPT Text Field
struct LGTextField: View {
    let placeholder: String
    let icon: String?
    let style: LGTextFieldStyle
    @Binding var text: String
    @FocusState private var isFocused: Bool

    var isError: Bool = false
    var errorMessage: String? = nil
    var onSubmit: (() -> Void)? = nil
    var isSecure: Bool = false
    var keyboardType: UIKeyboardType = .default
    var autocapitalization: TextInputAutocapitalization = .sentences

    init(
        text: Binding<String>,
        placeholder: String,
        icon: String? = nil,
        style: LGTextFieldStyle = .standard,
        isError: Bool = false,
        errorMessage: String? = nil,
        onSubmit: (() -> Void)? = nil,
        isSecure: Bool = false,
        keyboardType: UIKeyboardType = .default,
        autocapitalization: TextInputAutocapitalization = .sentences
    ) {
        self._text = text
        self.placeholder = placeholder
        self.icon = icon
        self.style = style
        self.isError = isError
        self.errorMessage = errorMessage
        self.onSubmit = onSubmit
        self.isSecure = isSecure
        self.keyboardType = keyboardType
        self.autocapitalization = autocapitalization
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 12) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: 16))
                        .foregroundColor(iconColor)
                }

                if isSecure || style == .password {
                    SecureField(placeholder, text: $text)
                        .focused($isFocused)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .keyboardType(keyboardType)
                        .onSubmit {
                            onSubmit?()
                        }
                } else {
                    TextField(placeholder, text: $text)
                        .focused($isFocused)
                        .textInputAutocapitalization(autocapitalization)
                        .autocorrectionDisabled(style == .search)
                        .keyboardType(keyboardType)
                        .onSubmit {
                            onSubmit?()
                        }
                }
            }
            .font(LGFonts.body)
            .foregroundColor(LGColors.foreground)
            .padding(.horizontal, LGSpacing.md)
            .padding(.vertical, 12)
            .background(backgroundColor)
            .cornerRadius(LGSpacing.buttonRadius)
            .overlay(
                RoundedRectangle(cornerRadius: LGSpacing.buttonRadius)
                    .stroke(borderColor, lineWidth: borderWidth)
            )
            .animation(.easeInOut(duration: 0.2), value: isFocused)

            if let errorMessage = errorMessage, isError {
                HStack(spacing: 4) {
                    Image(systemName: "exclamationmark.circle.fill")
                        .font(.system(size: 12))
                    Text(errorMessage)
                        .font(LGFonts.caption)
                }
                .foregroundColor(LGColors.errorText)
            }
        }
    }

    private var backgroundColor: Color {
        if isError {
            return LGColors.errorBg
        }
        return isFocused ? LGColors.background : LGColors.neutral50
    }

    private var borderColor: Color {
        if isError {
            return LGColors.error
        } else if isFocused {
            return LGColors.foreground
        } else {
            return LGColors.neutral300
        }
    }

    private var borderWidth: CGFloat {
        isFocused ? 2 : 1
    }

    private var iconColor: Color {
        if isError {
            return LGColors.error
        }
        return isFocused ? LGColors.foreground : LGColors.neutral500
    }
}

/// LuidGPT Text Area (Multi-line)
struct LGTextArea: View {
    let placeholder: String
    @Binding var text: String
    let minHeight: CGFloat
    @FocusState private var isFocused: Bool

    var isError: Bool = false
    var errorMessage: String? = nil

    init(
        placeholder: String,
        text: Binding<String>,
        minHeight: CGFloat = 100,
        isError: Bool = false,
        errorMessage: String? = nil
    ) {
        self.placeholder = placeholder
        self._text = text
        self.minHeight = minHeight
        self.isError = isError
        self.errorMessage = errorMessage
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            ZStack(alignment: .topLeading) {
                // Placeholder
                if text.isEmpty {
                    Text(placeholder)
                        .font(LGFonts.body)
                        .foregroundColor(LGColors.neutral500)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                }

                // Text Editor
                TextEditor(text: $text)
                    .font(LGFonts.body)
                    .foregroundColor(LGColors.foreground)
                    .scrollContentBackground(.hidden)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .focused($isFocused)
            }
            .frame(minHeight: minHeight)
            .background(backgroundColor)
            .cornerRadius(LGSpacing.buttonRadius)
            .overlay(
                RoundedRectangle(cornerRadius: LGSpacing.buttonRadius)
                    .stroke(borderColor, lineWidth: borderWidth)
            )
            .animation(.easeInOut(duration: 0.2), value: isFocused)

            if let errorMessage = errorMessage, isError {
                HStack(spacing: 4) {
                    Image(systemName: "exclamationmark.circle.fill")
                        .font(.system(size: 12))
                    Text(errorMessage)
                        .font(LGFonts.caption)
                }
                .foregroundColor(LGColors.errorText)
            }
        }
    }

    private var backgroundColor: Color {
        if isError {
            return LGColors.errorBg
        }
        return isFocused ? LGColors.background : LGColors.neutral50
    }

    private var borderColor: Color {
        if isError {
            return LGColors.error
        } else if isFocused {
            return LGColors.foreground
        } else {
            return LGColors.neutral300
        }
    }

    private var borderWidth: CGFloat {
        isFocused ? 2 : 1
    }
}

/// Minimal text field variant with underline style
struct LGTextFieldUnderlined: View {
    let placeholder: String
    @Binding var text: String
    @FocusState private var isFocused: Bool

    var label: String? = nil
    var isError: Bool = false
    var errorMessage: String? = nil

    init(
        text: Binding<String>,
        placeholder: String,
        label: String? = nil,
        isError: Bool = false,
        errorMessage: String? = nil
    ) {
        self._text = text
        self.placeholder = placeholder
        self.label = label
        self.isError = isError
        self.errorMessage = errorMessage
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let label = label {
                Text(label)
                    .font(LGFonts.caption)
                    .foregroundColor(LGColors.neutral600)
            }

            TextField(placeholder, text: $text)
                .font(LGFonts.body)
                .foregroundColor(LGColors.foreground)
                .focused($isFocused)
                .padding(.vertical, 8)

            Rectangle()
                .fill(underlineColor)
                .frame(height: underlineHeight)
                .animation(.easeInOut(duration: 0.2), value: isFocused)

            if let errorMessage = errorMessage, isError {
                HStack(spacing: 4) {
                    Image(systemName: "exclamationmark.circle.fill")
                        .font(.system(size: 12))
                    Text(errorMessage)
                        .font(LGFonts.caption)
                }
                .foregroundColor(LGColors.errorText)
            }
        }
    }

    private var underlineColor: Color {
        if isError {
            return LGColors.error
        } else if isFocused {
            return LGColors.foreground
        } else {
            return LGColors.neutral300
        }
    }

    private var underlineHeight: CGFloat {
        isFocused ? 2 : 1
    }
}

// MARK: - Preview

struct LGTextField_Previews: PreviewProvider {
    static var previews: some View {
        ScrollView {
            VStack(spacing: 24) {
                Text("Standard Text Fields")
                    .font(LGFonts.h4)
                    .foregroundColor(LGColors.foreground)

                LGTextField(
                    text: .constant(""),
                    placeholder: "Email",
                    icon: "envelope"
                )

                LGTextField(
                    text: .constant(""),
                    placeholder: "Password",
                    icon: "lock",
                    style: .password
                )

                LGTextField(
                    text: .constant(""),
                    placeholder: "Search models...",
                    icon: "magnifyingglass",
                    style: .search
                )

                LGTextField(
                    text: .constant("invalid@email"),
                    placeholder: "Email",
                    icon: "envelope",
                    isError: true,
                    errorMessage: "Please enter a valid email"
                )

                Divider().background(LGColors.neutral300)

                Text("Text Areas")
                    .font(LGFonts.h4)
                    .foregroundColor(LGColors.foreground)

                LGTextArea(
                    placeholder: "Enter your prompt...",
                    text: .constant(""),
                    minHeight: 120
                )

                LGTextArea(
                    placeholder: "Enter your prompt...",
                    text: .constant(""),
                    isError: true,
                    errorMessage: "Prompt is required"
                )

                Divider().background(LGColors.neutral300)

                Text("Underlined Style")
                    .font(LGFonts.h4)
                    .foregroundColor(LGColors.foreground)

                LGTextFieldUnderlined(
                    text: .constant(""),
                    placeholder: "Enter name",
                    label: "Full Name"
                )

                LGTextFieldUnderlined(
                    text: .constant("invalid"),
                    placeholder: "Enter email",
                    label: "Email Address",
                    isError: true,
                    errorMessage: "Invalid email format"
                )
            }
            .padding()
        }
        .background(LGColors.background)
        .preferredColorScheme(.light)
    }
}
