import Foundation

enum RenderSegment {
    case text(String, styles: [String])
    case placeholder(format: String, raw: String, index: Int, styles: [String])
    case rendered(AttributedString)
}

enum ConvertMode {
    case simpleConvert
    case preRender
}

protocol Renderer {
    func convertSegments(parsed: [ParserSegment], mode: ConvertMode, styles styleDefinitions: StringStyleDefinitions) -> [RenderSegment]
    func renderAsLiteral(_ segments: [RenderSegment], with definitions: StringStyleDefinitions) -> AttributedString
    func renderWithFormats(_ segments: [RenderSegment], arguments: [CVarArg], with definitions: StringStyleDefinitions) -> AttributedString
}

struct AttributedStringRenderer: Renderer {
    let logger: RendererLogger
    let rendererOperator: AttributedStringRenderOperator
    
    init(logger: RendererLogger) {
        self.logger = logger
        self.rendererOperator = AttributedStringRenderOperator(logger: logger)
    }
    
    func convertSegments(parsed: [ParserSegment], mode: ConvertMode, styles styleDefinitions: StringStyleDefinitions) -> [RenderSegment] {
        let segments = parsed.map { segment in
            switch segment {
            case .text(let text, let styles):
                if mode == .simpleConvert {
                    return RenderSegment.text(text, styles: styles)
                } else {
                    return .rendered(applyStyle(to: text, styles: styles, with: styleDefinitions))
                }
            case .placeholder(let format, let raw, let index, let styles):
                return .placeholder(format: format, raw: raw, index: index, styles: styles)
            }
        }
        
        if mode == .simpleConvert {
            return segments
        }
            
        return segments .reduce(into: []) { result, segment in
            // 今の項目と前の項目が rendered なら merge
            if case .rendered(let rendered) = segment, case .rendered(let lastRendered) = result.last {
                result[result.count - 1] = .rendered(rendererOperator.merge(lastRendered, rendered))
            } else {
                result.append(segment)
            }
        }
    }
    
    func renderAsLiteral(_ segments: [RenderSegment], with definitions: StringStyleDefinitions) -> AttributedString {
        return segments.reduce(into: AttributedString()) { result, segment in
            switch segment {
            case .text(let text, let styles):
                let attributedString = applyStyle(to: text, styles: styles, with: definitions)
                result.append(attributedString)
            case .placeholder(let format, _, _, let styles):
                let attributedString = applyStyle(to: format, styles: styles, with: definitions)
                result.append(attributedString)
            case .rendered(let rendered):
                result.append(rendered)
            }
        }
    }
    
    func renderWithFormats(_ segments: [RenderSegment], arguments: [CVarArg], with definitions: StringStyleDefinitions) -> AttributedString {
        return segments.reduce(into: AttributedString()) { result, segment in
            switch segment {
            case .text(let text, let styles):
                let attributedString = applyStyle(to: text, styles: styles, with: definitions)
                result.append(attributedString)
            case .placeholder(let format, let raw, let index, let styles):
                if index >= arguments.count {
                    // 引数が足りない場合は無視
                    logger.warning(.missingArgument(format: raw, index: index))
                    return
                }
                let arg = arguments[index]
                let formattedString = String(format: format, arg)
                let attributedString = applyStyle(to: formattedString, styles: styles, with: definitions)
                result.append(attributedString)
            case .rendered(let rendered):
                result.append(rendered)
            }
        }
    }

    private func applyStyle(to: String, styles: [String], with definitions: StringStyleDefinitions) -> AttributedString {
        var attributedString = rendererOperator.create(from: to)
        if let range = attributedString.range(of: to) {
            rendererOperator.apply(styles, in: range, with: definitions, to: &attributedString)
        }
        return attributedString
    }
}

