import Foundation

protocol ParserLogger {
    func warning(_ warning: ParserWarning)
}

struct ParserLoggerImpl: ParserLogger {
    let logger: Aizome.Logger

    func warning(_ warning: ParserWarning) {
        switch warning {
        case .unclosedTag(let index):
            logger.warning("unclosed tag at index: \(index)")
        case .unopenedMarkup(let tag, let index):
            logger.warning("unopened markup \(tag) at index: \(index)")
        case .unclosedMarkup(let tag, let index):
            logger.warning("unclosed markup \(tag) at index: \(index)")
        case .emptyTag(let index):
            logger.warning("empty tag at index: \(index)")
        case .unknownFormat(format: let format):
            logger.warning("unknown format: \(format)")
        }
    }
}

enum ParserSegment {
    case text(String, styles: [String])
    case placeholder(format: String, index: Int, styles: [String])
}

enum ParserWarning: Equatable {
    case unclosedTag(index: Int)
    case unopenedMarkup(tag: String, index: Int)
    case unclosedMarkup(tag: String, index: Int)
    case emptyTag(index: Int)
    
    case unknownFormat(format: String)
}

func parseFormatString(_ string: String, logger: Aizome.Logger) -> [ParserSegment] {
    let parserLogger = ParserLoggerImpl(logger: logger)
    
    // セグメントに分割する
    let segments = parseToSegments(string, logger: parserLogger)
    
    // セグメント内のプレースホルダ文字列を処理してセグメント分割を更に進める
    let parameterizedSegments = parseParameterStrings(segments, logger: parserLogger)
    
    return parameterizedSegments
}

func appendTextSegment(_ string: String, styles: [String], to segments: inout [ParserSegment]) {
    guard !string.isEmpty else { return }
    segments.append(.text(string, styles: styles))
}
