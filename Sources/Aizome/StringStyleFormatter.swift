import Foundation

/// A reusable formatter for parsing and rendering styled format strings.
public struct StringStyleFormatter {
    let parser: Parser
    let renderer: AttributedStringRenderer
    
    let parserSegments: [ParserSegment]
    let renderSegments: [RenderSegment]
    
    let definitions: StringStyleDefinitions
    
    /// Initializes the formatter with a format string and default styles.
     /// - Parameter formatString: A string containing style markup tags.
    @MainActor
    public init(formatString: String) {
        let pr = Aizome.createParserRenderer()
        self.parser = pr.parser
        self.renderer = pr.renderer
        
        self.definitions = Aizome.defaultStyles
        self.parserSegments = parser.parseToSegments(formatString)
        self.renderSegments = renderer.convertSegments(parsed: self.parserSegments, mode: .preRender, styles: self.definitions)
    }
    
    /// Initializes the formatter with a format string and custom styles.
    /// - Parameters:
    ///   - formatString: A string containing style markup tags.
    ///   - styles: A dictionary of style definitions to apply.
    public init(formatString: String, styles: StringStyleDefinitions) {
        let pr = Aizome.createParserRenderer()
        self.parser = pr.parser
        self.renderer = pr.renderer
        
        self.definitions = styles
        self.parserSegments = parser.parseToSegments(formatString)
        self.renderSegments = renderer.convertSegments(parsed: self.parserSegments, mode: .preRender, styles: self.definitions)
    }
    
    /// Formats the string by replacing placeholders and applying styles.
    /// - Parameter args: Arguments to replace placeholders (e.g., `%@`).
    /// - Returns: A styled `AttributedString`.
    public func format(_ args: CVarArg...) -> AttributedString {
        self.renderer.renderWithFormats(self.renderSegments, arguments: args, with: self.definitions)
    }
}
