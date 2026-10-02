import SwiftUI

/// Text field styled for Veira forms.
public struct VeiraTextField: View {
    public enum Kind: Sendable {
        case text
        case email
        case password
        case number
    }

    private let title: String
    private let placeholder: String
    private let kind: Kind
    private let errorMessage: String?
    @Binding private var text: String
    @FocusState private var isFocused: Bool

    @Environment(\.veiraTheme) private var theme

    public init(
        _ title: String,
        text: Binding<String>,
        placeholder: String = "",
        kind: Kind = .text,
        errorMessage: String? = nil
    ) {
        self.title = title
        self._text = text
        self.placeholder = placeholder
        self.kind = kind
        self.errorMessage = errorMessage
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: VeiraSpacing.xs.value) {
            Text(title)
                .veiraFont(.labelMedium, typography: theme.typography)
                .foregroundStyle(theme.colors.textSecondary)

            Group {
                switch kind {
                case .password:
                    SecureField(placeholder, text: $text)
                case .email:
                    TextField(placeholder, text: $text)
                        #if os(iOS)
                        .textContentType(.emailAddress)
                        .keyboardType(.emailAddress)
                        .textInputAutocapitalization(.never)
                        #endif
                        .autocorrectionDisabled()
                case .number:
                    TextField(placeholder, text: $text)
                        #if os(iOS)
                        .keyboardType(.decimalPad)
                        #endif
                case .text:
                    TextField(placeholder, text: $text)
                }
            }
            .veiraFont(.bodyLarge, typography: theme.typography)
            .foregroundStyle(theme.colors.textPrimary)
            .padding(.horizontal, VeiraSpacing.md.value)
            .frame(height: 56)
            .background(theme.colors.surface)
            .clipShape(RoundedRectangle(cornerRadius: VeiraRadius.md.value, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: VeiraRadius.md.value, style: .continuous)
                    .strokeBorder(borderColor, lineWidth: isFocused || errorMessage != nil ? 1.5 : 1)
            }
            .focused($isFocused)
            .accessibilityLabel(title)
            .accessibilityValue(text.isEmpty ? placeholder : text)

            if let errorMessage {
                Text(errorMessage)
                    .veiraFont(.caption, typography: theme.typography)
                    .foregroundStyle(theme.colors.danger)
                    .accessibilityLabel("Error: \(errorMessage)")
            }
        }
    }

    private var borderColor: Color {
        if errorMessage != nil { return theme.colors.danger }
        if isFocused { return theme.colors.accent }
        return theme.colors.border
    }
}
