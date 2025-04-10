import Foundation

struct ParsedSegments {
    // 分割されたセグメント
    let segments: [Segment]
    
    // プレースホルダの定義されている位置
    let placeholderIndexes: [Int]
}

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
        }
    }
}

enum Segment {
    case text(String, styles: [String])
    case placeholder(format: String, index: Int, styles: [String])
}

enum ParserWarning: Equatable {
    case unclosedTag(index: Int)
    case unopenedMarkup(tag: String, index: Int)
    case unclosedMarkup(tag: String, index: Int)
    case emptyTag(index: Int)
}

func parseFormatString(_ string: String, logger: Aizome.Logger) -> ParsedSegments {
    let parserLogger = ParserLoggerImpl(logger: logger)
    
    // セグメントに分割する
    let segments = parseToSegments(string, logger: parserLogger)
    
    // セグメント内のプレースホルダ文字列を処理してセグメント分割を更に進める
    let parameterizedSegments = parseParameterStrings(segments, logger: parserLogger)
    
    return parameterizedSegments
}

func parseToSegments(_ string: String, logger: ParserLogger) -> [Segment] {
    var segments: [Segment] = []
    var styleStack: [String] = []
    
    var i = string.startIndex
    
    while i < string.endIndex {
        // 次の < を探す
        guard let startTagRange = string.range(of: "<", options: .caseInsensitive, range: i..<string.endIndex) else {
            // 見つからなかった場合は、そこから文末までが現在のtextとなる
            segments.append(.text(String(string[i...]), styles: styleStack))
            break
        }
        
        // 次の > を探す
        guard let endTagRange = string.range(of: ">", options: .caseInsensitive, range: startTagRange.upperBound..<string.endIndex) else {
            // 見つからなかった場合はunclosed tag、startTagRangeの1文字だけをセグメントとして積む
            logger.warning(.unclosedTag(index: string.distance(from: string.startIndex, to: startTagRange.lowerBound)))
            appendTextSegment(String(string[startTagRange.lowerBound...]), styles: styleStack, to: &segments)
            i = startTagRange.upperBound
            continue
        }
        
        // タグの文字列を得る
        let tagString = string[startTagRange.lowerBound..<endTagRange.upperBound]
        
        // タグに含まれてはいけない文字がある場合はunclosed tagとみなす
        if containsInvalidTagCharacters(tagString) {
            logger.warning(.unclosedTag(index: string.distance(from: string.startIndex, to: startTagRange.lowerBound)))
            appendTextSegment(String(string[startTagRange.lowerBound...]), styles: styleStack, to: &segments)
            i = endTagRange.upperBound
            continue
        }
        
        // タグまでの文字列をセグメントに追加する
        let textRange = i..<startTagRange.lowerBound
        if textRange.lowerBound < textRange.upperBound {
            appendTextSegment(String(string[textRange]), styles: styleStack, to: &segments)
        }
        
        // 空タグではないか
        if tagString == "<>" || tagString == "</>" {
            // 空タグの場合、スタイルスタックをそのままにして次の文字列を探す
            logger.warning(.emptyTag(index: string.distance(from: string.startIndex, to: startTagRange.lowerBound)))
            i = endTagRange.upperBound
            continue
        }

        // 閉じタグかどうか
        if tagString.hasPrefix("</") {
            // 閉じタグの場合、スタイルスタックからポップする
            let tag = String(tagString.dropFirst(2).dropLast())
            
            if let index = styleStack.firstIndex(of: tag) {
                // 閉じタグの関係が正しくない場合(対応するタグが先にある場合)、index が末尾にならない。
                // 見つかった位置までの要素をポップし、すべて unmatched として警告する
                if index != styleStack.count - 1 {
                    let unmatched = styleStack[index + 1..<styleStack.count]
                    styleStack.removeSubrange(index + 1..<styleStack.count)
                    for unmatchedTag in unmatched {
                        logger.warning(.unclosedMarkup(tag: unmatchedTag, index: string.distance(from: string.startIndex, to: startTagRange.lowerBound)))
                    }
                }
                // スタイルスタックからポップする
                styleStack.removeLast()
            } else {
                // スタイルスタックに存在しない場合は、警告を出す
                logger.warning(.unopenedMarkup(tag: tag, index: string.distance(from: string.startIndex, to: startTagRange.lowerBound)))
            }
        } else {
            // 開始タグの場合、スタイルスタックにプッシュする
            let tag = String(tagString.dropFirst().dropLast())
            styleStack.append(tag)
        }
        
        // インデックスを進める
        i = endTagRange.upperBound
    }
    
    // 残ったスタイルスタックの要素をすべて unmatched として警告する
    for unmatchedTag in styleStack {
        logger.warning(.unclosedMarkup(tag: unmatchedTag, index: string.distance(from: string.startIndex, to: string.endIndex)))
    }
    
    // セグメントを返す
    return segments
}

func parseParameterStrings(_ segments: [Segment], logger: ParserLogger) -> ParsedSegments {
    // TODO: Implement
    return ParsedSegments(segments: segments, placeholderIndexes: [])
}

func containsInvalidTagCharacters(_ tag: Substring) -> Bool {
    tag.contains(" ") || tag.contains("\n") || tag.contains("\"")
}

func appendTextSegment(_ string: String, styles: [String], to segments: inout [Segment]) {
    guard !string.isEmpty else { return }
    segments.append(.text(string, styles: styles))
}
