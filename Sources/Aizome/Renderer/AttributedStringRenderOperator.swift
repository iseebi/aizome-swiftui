import Foundation

struct AttributedStringRenderOperator {
    let logger: RendererLogger
    
    init(logger: RendererLogger) {
        self.logger = logger
    }
    
    func create(from string: String) -> AttributedString {
        return AttributedString(string)
    }
    
    func apply(_ styles: [String], in range: Range<AttributedString.Index>, with styleDefinitions: StringStyleDefinitions, to str: inout AttributedString) {
        for style in styles {
            if let styleDefinition = styleDefinitions[style] {
                styleDefinition.apply(to: &str, range: range)
            } else {
                logger.warning(.noStyle(style))
            }
        }
    }
    
    func merge(_ one: AttributedString, _ two: AttributedString) -> AttributedString {
        var merged = one
        merged.append(two)
        return merged
    }
}
