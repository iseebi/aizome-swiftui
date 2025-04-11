import Foundation

func parseToSegments(_ string: String, logger: ParserLogger) -> [ParserSegment] {
    var segments: [ParserSegment] = []
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

func containsInvalidTagCharacters(_ tag: Substring) -> Bool {
    tag.contains(" ") || tag.contains("\n") || tag.contains("\"")
}
