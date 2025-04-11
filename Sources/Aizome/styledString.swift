import Foundation

/// Parses a styled format string using the default style definitions.
/// - Parameter formatString: A string containing style markup tags.
/// - Returns: A styled `AttributedString`.
@MainActor func styledString(_ formatString: String) -> AttributedString {
    return styledString(formatString, styles: Aizome.defaultStyles)
}

/// Parses a styled format string using the given style definitions.
/// - Parameters:
///   - formatString: A string containing style markup tags.
///   - styles: A dictionary of style definitions to use.
/// - Returns: A styled `AttributedString`.
func styledString(_ formatString: String, styles: StringStyleDefinitions) -> AttributedString {
    let pr = Aizome.createParserRenderer()
    let parserSegments = pr.parser.parseToSegments(formatString)
    let renderSegments = pr.renderer.convertSegments(parsed: parserSegments, mode: .simpleConvert, styles: styles)
    return pr.renderer.renderAsLiteral(renderSegments, with: styles)
}
