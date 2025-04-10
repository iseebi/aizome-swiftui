import Foundation

/// Parses a styled format string using the default style definitions.
/// - Parameter formatString: A string containing style markup tags.
/// - Returns: A styled `AttributedString`.
@MainActor func styledString(formatString: String) -> AttributedString {
    return styledString(formatString: formatString, styles: Aizome.defaultStyles)
}

/// Parses a styled format string using the given style definitions.
/// - Parameters:
///   - formatString: A string containing style markup tags.
///   - styles: A dictionary of style definitions to use.
/// - Returns: A styled `AttributedString`.
func styledString(formatString: String, styles: StringStyleDefinitions) -> AttributedString {
    // TODO: Implement
    return AttributedString("")
}
