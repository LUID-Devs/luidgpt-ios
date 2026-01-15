//
//  DynamicFormView.swift
//  LuidGPT
//
//  Dynamic form generator for model execution based on input schema
//

import SwiftUI
import PhotosUI

struct DynamicFormView: View {
    let schema: InputSchema?
    let modelCredits: Int
    let modelName: String
    let isLoading: Bool
    let error: String?
    let userCredits: Int
    let onSubmit: ([String: Any]) -> Void

    @State private var inputValues: [String: Any] = [:]
    @State private var validationErrors: [String: String] = [:]
    @State private var selectedImages: [String: UIImage] = [:]
    @State private var showImagePicker = false
    @State private var currentImageField: String?

    var body: some View {
        VStack(alignment: .leading, spacing: LGSpacing.lg) {
            // Header
            headerSection

            if let schema = schema {
                // Form fields
                ScrollView {
                    VStack(spacing: LGSpacing.md) {
                        ForEach(sortedProperties(schema), id: \.key) { key, property in
                            formField(key: key, property: property, required: schema.required.contains(key))
                        }
                    }
                }
                .frame(maxHeight: 500)

                // Error display
                if let error = error {
                    errorBanner(error)
                }

                // Submit button
                submitButton

            } else {
                // No schema available
                Text("Model schema not available")
                    .font(LGFonts.small)
                    .foregroundColor(LGColors.neutral600)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(LGSpacing.xl)
            }
        }
        .padding(LGSpacing.lg)
        .background(Color.white)
        .cornerRadius(12)
        .sheet(isPresented: $showImagePicker) {
            if let fieldKey = currentImageField {
                ImagePicker(image: Binding(
                    get: { selectedImages[fieldKey] },
                    set: { newImage in
                        if let image = newImage {
                            selectedImages[fieldKey] = image
                            inputValues[fieldKey] = convertImageToBase64(image)
                        }
                    }
                ))
            }
        }
    }

    // MARK: - Header Section

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Generate with \(modelName)")
                    .font(LGFonts.h4)
                    .foregroundColor(.black)

                Spacer()

                // Credit cost badge
                HStack(spacing: 4) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 12))
                    Text("\(modelCredits)")
                        .font(.system(size: 14, weight: .bold))
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(LGColors.VideoGeneration.main.opacity(0.2))
                .foregroundColor(LGColors.VideoGeneration.main)
                .cornerRadius(8)
            }

            Text("Fill out the parameters below to generate your output")
                .font(LGFonts.small)
                .foregroundColor(LGColors.neutral600)
        }
    }

    // MARK: - Form Fields

    @ViewBuilder
    private func formField(key: String, property: InputProperty, required: Bool) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            // Field label
            HStack(spacing: 4) {
                Text(property.title ?? key.capitalized)
                    .font(LGFonts.small.weight(.semibold))
                    .foregroundColor(.black)

                if required {
                    Text("*")
                        .foregroundColor(LGColors.errorText)
                }
            }

            // Field description
            if let description = property.description {
                Text(description)
                    .font(.system(size: 11))
                    .foregroundColor(LGColors.neutral600)
            }

            // Input control based on type
            inputControl(key: key, property: property)

            // Validation error
            if let error = validationErrors[key] {
                Text(error)
                    .font(.system(size: 11))
                    .foregroundColor(LGColors.errorText)
            }
        }
        .padding(LGSpacing.md)
        .background(LGColors.neutral100)
        .cornerRadius(10)
    }

    @ViewBuilder
    private func inputControl(key: String, property: InputProperty) -> some View {
        let type = property.type?.lowercased() ?? ""

        if property.enumValues != nil {
            // Enum/Select picker
            enumPicker(key: key, property: property)
        } else if type == "boolean" {
            // Toggle
            booleanToggle(key: key, property: property)
        } else if type == "integer" || type == "number" {
            // Number input
            numberInput(key: key, property: property)
        } else if property.format == "uri" || property.format == "data-url" {
            // Image upload
            imageInput(key: key, property: property)
        } else if type == "string" {
            // Text input
            textInput(key: key, property: property)
        } else {
            // Fallback to text input
            textInput(key: key, property: property)
        }
    }

    // MARK: - Input Controls

    private func textInput(key: String, property: InputProperty) -> some View {
        let binding = Binding<String>(
            get: { (inputValues[key] as? String) ?? (property.defaultValue?.value as? String) ?? "" },
            set: { inputValues[key] = $0 }
        )

        return Group {
            if let description = property.description, description.count > 100 {
                // Multi-line for long descriptions
                TextEditor(text: binding)
                    .frame(minHeight: 100)
                    .padding(8)
                    .background(LGColors.neutral100)
                    .cornerRadius(8)
                    .foregroundColor(.black)
            } else {
                TextField("Enter \(property.title ?? key)", text: binding)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(4)
            }
        }
    }

    private func numberInput(key: String, property: InputProperty) -> some View {
        let defaultValue = property.defaultValue?.value as? Double ?? property.minimum ?? 0
        let binding = Binding<Double>(
            get: { (inputValues[key] as? Double) ?? defaultValue },
            set: { inputValues[key] = $0 }
        )

        return VStack(alignment: .leading, spacing: 8) {
            if let min = property.minimum, let max = property.maximum {
                // Slider for bounded numbers
                HStack {
                    Text("\(Int(binding.wrappedValue))")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.black)
                        .frame(width: 50)

                    Slider(value: binding, in: min...max, step: 1)
                        .accentColor(LGColors.VideoGeneration.main)

                    Text("\(Int(max))")
                        .font(.system(size: 12))
                        .foregroundColor(LGColors.neutral600)
                }
            } else {
                // Text field for unbounded numbers
                TextField("Enter number", value: binding, format: .number)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.decimalPad)
                    .padding(4)
            }
        }
    }

    private func booleanToggle(key: String, property: InputProperty) -> some View {
        let defaultValue = property.defaultValue?.value as? Bool ?? false
        let binding = Binding<Bool>(
            get: { (inputValues[key] as? Bool) ?? defaultValue },
            set: { inputValues[key] = $0 }
        )

        return Toggle(isOn: binding) {
            EmptyView()
        }
        .tint(LGColors.VideoGeneration.main)
    }

    private func enumPicker(key: String, property: InputProperty) -> some View {
        let options = property.enumValues ?? []
        let defaultValue = property.defaultValue?.value as? String ?? options.first ?? ""
        let binding = Binding<String>(
            get: { (inputValues[key] as? String) ?? defaultValue },
            set: { inputValues[key] = $0 }
        )

        return Picker("", selection: binding) {
            ForEach(options, id: \.self) { option in
                Text(option.capitalized)
                    .tag(option)
            }
        }
        .pickerStyle(.menu)
        .padding(4)
    }

    private func imageInput(key: String, property: InputProperty) -> some View {
        VStack(spacing: 8) {
            if let image = selectedImages[key] {
                // Show selected image
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxHeight: 200)
                    .cornerRadius(8)

                Button("Change Image") {
                    currentImageField = key
                    showImagePicker = true
                }
                .font(LGFonts.small)
                .foregroundColor(LGColors.VideoGeneration.main)
            } else {
                // Upload button
                Button(action: {
                    currentImageField = key
                    showImagePicker = true
                }) {
                    VStack(spacing: 8) {
                        Image(systemName: "photo.on.rectangle.angled")
                            .font(.system(size: 32))
                            .foregroundColor(LGColors.neutral400)

                        Text("Upload Image")
                            .font(LGFonts.small)
                            .foregroundColor(.black)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(LGSpacing.lg)
                    .background(LGColors.neutral100)
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(style: StrokeStyle(lineWidth: 2, dash: [5]))
                            .foregroundColor(LGColors.neutral600)
                    )
                }
            }
        }
    }

    // MARK: - Submit Button

    private var submitButton: some View {
        let hasEnoughCredits = userCredits >= modelCredits
        let canSubmit = !isLoading && hasEnoughCredits && areRequiredFieldsFilled

        return VStack(spacing: 8) {
            if !hasEnoughCredits {
                HStack(spacing: 8) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(LGColors.warningText)
                    Text("Insufficient credits")
                        .font(LGFonts.small)
                        .foregroundColor(LGColors.warningText)
                }
                .padding(.vertical, 8)
            }

            Button(action: handleSubmit) {
                HStack(spacing: 8) {
                    if isLoading {
                        ProgressView()
                            .scaleEffect(0.8)
                            .tint(.white)
                    } else {
                        Image(systemName: "sparkles")
                        Text("Generate")
                        Text("(\(modelCredits) credits)")
                            .font(LGFonts.small)
                    }
                }
                .font(LGFonts.body.weight(.semibold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(
                    canSubmit
                        ? LGColors.VideoGeneration.main
                        : LGColors.neutral600
                )
                .cornerRadius(10)
            }
            .disabled(!canSubmit)
        }
    }

    private func errorBanner(_ error: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: "xmark.circle.fill")
                .foregroundColor(LGColors.errorText)
            Text(error)
                .font(LGFonts.small)
                .foregroundColor(LGColors.errorText)
        }
        .padding(LGSpacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(LGColors.errorText.opacity(0.1))
        .cornerRadius(8)
    }

    // MARK: - Helper Methods

    private func sortedProperties(_ schema: InputSchema) -> [(key: String, value: InputProperty)] {
        // Sort: required fields first, then alphabetically
        schema.properties.sorted { first, second in
            let firstRequired = schema.required.contains(first.key)
            let secondRequired = schema.required.contains(second.key)

            if firstRequired != secondRequired {
                return firstRequired
            }
            return first.key < second.key
        }
    }

    private var areRequiredFieldsFilled: Bool {
        guard let schema = schema else { return false }

        for requiredKey in schema.required {
            let value = inputValues[requiredKey]

            if value == nil {
                // Check if there's a default value
                if let property = schema.properties[requiredKey],
                   property.defaultValue != nil {
                    continue
                }
                return false
            }

            // Check if string is not empty
            if let stringValue = value as? String, stringValue.isEmpty {
                return false
            }
        }

        return true
    }

    private func handleSubmit() {
        validationErrors.removeAll()

        guard let schema = schema else { return }

        // Build final input dictionary
        var finalInput: [String: Any] = [:]

        for (key, property) in schema.properties {
            if let value = inputValues[key] {
                // Unwrap ALL values to ensure they're JSON-serializable
                if let primitiveValue = extractPrimitiveValue(from: value) {
                    finalInput[key] = primitiveValue
                }
            } else if let defaultValue = property.defaultValue {
                // Properly unwrap AnyCodable to get the actual primitive value
                let unwrappedValue = extractPrimitiveValue(from: defaultValue.value)
                if let primitiveValue = unwrappedValue {
                    finalInput[key] = primitiveValue
                }
            }
        }

        // Validate required fields
        for requiredKey in schema.required {
            if finalInput[requiredKey] == nil {
                validationErrors[requiredKey] = "This field is required"
            }
        }

        // If no validation errors, serialize to JSON and back to ensure all values are JSON-safe
        if validationErrors.isEmpty {
            // Convert to JSON Data and back to strip out any non-JSON-serializable types
            do {
                let jsonData = try JSONSerialization.data(withJSONObject: finalInput, options: [])
                if let cleanedInput = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any] {
                    onSubmit(cleanedInput)
                } else {
                    print("❌ Failed to deserialize JSON back to dictionary")
                    validationErrors["_general"] = "Failed to prepare input data"
                }
            } catch {
                print("❌ JSON serialization error: \(error)")
                validationErrors["_general"] = "Invalid input data: \(error.localizedDescription)"
            }
        }
    }

    /// Extract primitive JSON-serializable value from Any
    private func extractPrimitiveValue(from value: Any) -> Any? {
        // Handle NSNumber and numeric types
        if let numberValue = value as? NSNumber {
            // Check if it's a Bool first (NSNumber can also be Bool)
            if CFBooleanGetTypeID() == CFGetTypeID(numberValue as CFTypeRef) {
                return numberValue.boolValue
            }
            // Return as Double for all other numbers (most compatible JSON type)
            return numberValue.doubleValue
        }

        // Handle basic Swift types
        if let stringValue = value as? String {
            return stringValue
        } else if let intValue = value as? Int {
            return intValue
        } else if let doubleValue = value as? Double {
            return doubleValue
        } else if let floatValue = value as? Float {
            return Double(floatValue)
        } else if let boolValue = value as? Bool {
            return boolValue
        } else if let int64Value = value as? Int64 {
            return Int(int64Value)
        } else if let int32Value = value as? Int32 {
            return Int(int32Value)
        } else if let arrayValue = value as? [Any] {
            return arrayValue.compactMap { extractPrimitiveValue(from: $0) }
        } else if let dictValue = value as? [String: Any] {
            return dictValue.compactMapValues { extractPrimitiveValue(from: $0) }
        }

        // If none of the above, return nil (unsupported type)
        return nil
    }

    private func convertImageToBase64(_ image: UIImage) -> String {
        // Resize image if needed (max 2048px)
        let maxDimension: CGFloat = 2048
        var newImage = image

        if image.size.width > maxDimension || image.size.height > maxDimension {
            let ratio = min(maxDimension / image.size.width, maxDimension / image.size.height)
            let newSize = CGSize(width: image.size.width * ratio, height: image.size.height * ratio)

            UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
            image.draw(in: CGRect(origin: .zero, size: newSize))
            newImage = UIGraphicsGetImageFromCurrentImageContext() ?? image
            UIGraphicsEndImageContext()
        }

        // Convert to JPEG with compression
        let imageData = newImage.jpegData(compressionQuality: 0.8) ?? Data()
        return "data:image/jpeg;base64," + imageData.base64EncodedString()
    }
}

// MARK: - Image Picker

struct ImagePicker: UIViewControllerRepresentable {
    @Environment(\.dismiss) private var dismiss
    @Binding var image: UIImage?

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = .photoLibrary
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePicker

        init(_ parent: ImagePicker) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let uiImage = info[.originalImage] as? UIImage {
                parent.image = uiImage
            }
            parent.dismiss()
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.dismiss()
        }
    }
}

// MARK: - Preview

#if DEBUG
struct DynamicFormView_Previews: PreviewProvider {
    static var previews: some View {
        DynamicFormView(
            schema: InputSchema(
                type: "object",
                properties: [
                    "prompt": InputProperty(
                        type: "string",
                        title: "Prompt",
                        description: "Describe what you want to generate",
                        defaultValue: nil,
                        enumValues: nil,
                        minimum: nil,
                        maximum: nil,
                        format: nil
                    ),
                    "width": InputProperty(
                        type: "integer",
                        title: "Width",
                        description: "Output width in pixels",
                        defaultValue: AnyCodable(1024),
                        enumValues: nil,
                        minimum: 256,
                        maximum: 2048,
                        format: nil
                    ),
                    "num_outputs": InputProperty(
                        type: "integer",
                        title: "Number of Outputs",
                        description: "How many images to generate",
                        defaultValue: AnyCodable(1),
                        enumValues: nil,
                        minimum: 1,
                        maximum: 4,
                        format: nil
                    ),
                    "style": InputProperty(
                        type: "string",
                        title: "Style",
                        description: "Choose a style preset",
                        defaultValue: AnyCodable("cinematic"),
                        enumValues: ["cinematic", "photorealistic", "artistic", "anime"],
                        minimum: nil,
                        maximum: nil,
                        format: nil
                    )
                ],
                required: ["prompt"]
            ),
            modelCredits: 2,
            modelName: "FLUX 1.1 Pro",
            isLoading: false,
            error: nil,
            userCredits: 10,
            onSubmit: { input in
                print("Submitted: \(input)")
            }
        )
        .padding()
        .background(Color.black)
        .preferredColorScheme(.dark)
    }
}
#endif
