import Foundation


enum ParserSegment {
    case text(String, styles: [String])
    case placeholder(format: String, raw: String, index: Int, styles: [String])
}

struct Parser {
    let logger: ParserLogger
    
    init(logger: ParserLogger) {
        self.logger = logger
    }
    
    func parseFormatString(_ string: String) -> [ParserSegment] {
        // セグメントに分割する
        let segments = parseToSegments(string)
        
        // セグメント内のプレースホルダ文字列を処理してセグメント分割を更に進める
        let parameterizedSegments = parseParameterStrings(segments)
        
        return parameterizedSegments
    }

    func appendTextSegment(_ string: String, styles: [String], to segments: inout [ParserSegment]) {
        guard !string.isEmpty else { return }
        segments.append(.text(string, styles: styles))
    }
}

