import Foundation

struct IndexCounter {
    var nextImplicit: Int = 0
    var explicit: [Int] = []
    
    mutating func addExplicit(index: Int) -> Int {
        explicit.append(index)
        return index
    }
    
    mutating func nextImplicitIndex() -> Int {
        var index = nextImplicit

        while explicit.contains(index) {
            index += 1
        }

        nextImplicit = index + 1
        return index
    }
}

func parseParameterStrings(_ segments: [ParserSegment], logger: ParserLogger) -> [ParserSegment] {
    var result: [ParserSegment] = []
    var indexCounter = IndexCounter()

    for segment in segments {
        switch segment {
        case .text(let text, let styles):
            var i = text.startIndex
            while i < text.endIndex {
                // 次の % を探す (なかったら以後のテキストはプレーンテキスト)
                guard let percent = text[i...].firstIndex(of: "%") else {
                    appendTextSegment(String(text[i...]), styles: styles, to: &result)
                    break
                }

                // %までのプレーンテキストの追加
                if percent > i {
                    appendTextSegment(String(text[i..<percent]), styles: styles, to: &result)
                }

                let afterPercent = text.index(after: percent)

                // "%%" になるならエスケープ処理
                if afterPercent < text.endIndex, text[afterPercent] == "%" {
                    appendTextSegment("%", styles: styles, to: &result)
                    i = text.index(after: afterPercent)
                    continue
                }
                
                guard let (formatRange, formatText) = scanFormatSpecifier(in: text, from: percent) else {
                    // 不正な書式 → 単に % を残す
                    appendTextSegment("%", styles: styles, to: &result)
                    i = afterPercent
                    continue
                }

                // フォーマットの構文解析
                guard let (formatWithoutIndex, explicitIndex) = parseFormatString(formatText) else {
                    // 無効な書式 ここに空文字列があったこととする
                    // 例: %z
                    logger.warning(.unknownFormat(format: formatText))
                    i = formatRange.upperBound
                    continue
                }
                
                let resolvedIndex = if let explicitIndex = explicitIndex {
                    indexCounter.addExplicit(index: explicitIndex)
                } else {
                    indexCounter.nextImplicitIndex()
                }
                
                // 正しくパースできた場合、プレースホルダを追加
                result.append(.placeholder(format: formatWithoutIndex, index: resolvedIndex, styles: styles))
                i = formatRange.upperBound
            }
        case .placeholder:
            result.append(segment)
        }
    }

    return result
}

/// `%` から始まる1つの書式指定子をスキャンし、範囲と文字列を返す
/// この段階では型指定子が定義にないものも許可する
func scanFormatSpecifier(in text: String, from start: String.Index) -> (Range<String.Index>, String)? {
    var i = text.index(after: start)
    var sawConversion = false

    while i < text.endIndex {
        let char = text[i]
        if char.isMaybeTypeSpecifier {
            sawConversion = true
            i = text.index(after: i)
            break
        }
        i = text.index(after: i)
    }

    guard sawConversion else { return nil }

    let range = start..<i
    return (range, String(text[range]))
}

func parseFormatString(_ format: String) -> (format: String, index: Int?)? {
    guard format.first == "%" else { return nil }

    let scanner = Scanner(string: format)
    scanner.currentIndex = format.startIndex
    scanner.advance() // skip '%'

    let beforeIndex = scanner.currentIndex

    // 明示的な引数インデックス (%2$)
    var explicitIndex: Int? = nil
    if let number = scanner.scanInt(), scanner.scanString("$") != nil {
        explicitIndex = number - 1
    } else {
        // `$` がないなら巻き戻す（number を読み込んでしまっていたら）
        scanner.currentIndex = beforeIndex
    }

    // フラグ（`-+#0 `）
    let allowedFlags = CharacterSet(charactersIn: "-+#0 ")
    while let char = scanner.peek(), char.unicodeScalars.allSatisfy({ allowedFlags.contains($0) }) {
        scanner.advance()
    }

    // 幅
    _ = scanner.scanInt()

    // 精度
    if scanner.scanString(".") != nil {
        _ = scanner.scanInt()
    }

    // 型指定子（@, d, f, etc.）
    guard let conversion = scanner.scanCharacter(), conversion.isTypeSpecifier else {
        return nil // 無効な変換子
    }

    // 残りが何もないことを確認（`%dabc` のような不正を防ぐ）
    if scanner.currentIndex != scanner.string.endIndex {
        return nil
    }
    
    // 書式全体の range
    let formatEnd = scanner.currentIndex
    let scannedFormat = String(format[..<formatEnd]) // 例: "%2$04d"

    // `%2$04d` のうち、`%04d` 部分だけを format として返す
    let resultFormat: String
    if let _ = explicitIndex {
        // `%2$04d` → `%04d` に変換
        // 必ず "$" の直後から最後まで取り出す
        if let dollarIndex = scannedFormat.firstIndex(of: "$") {
            let afterDollar = scannedFormat.index(after: dollarIndex)
            resultFormat = "%" + scannedFormat[afterDollar...]
        } else {
            return nil // `$` がないのは不正（理論上起きない）
        }
    } else {
        // 暗黙インデックス → そのまま使う
        resultFormat = scannedFormat
    }
    
    return (resultFormat, explicitIndex)
}

extension Scanner {
    /// 現在位置の文字を1文字返す（消費しない）
    func peek() -> Character? {
        guard currentIndex < string.endIndex else { return nil }
        return string[currentIndex]
    }

    /// 現在位置の文字を1文字だけ消費する
    func advance() {
        guard currentIndex < string.endIndex else { return }
        currentIndex = string.index(after: currentIndex)
    }
}

let allowedSpecifiers: Set<Character> = [
    "@", "d", "i", "f", "e", "E", "g", "G", "x", "X", "o", "c", "s", "b", "h"
]

extension Character {
    var isMaybeTypeSpecifier: Bool {
        return isLetter || self == "@"
    }

    var isTypeSpecifier: Bool {
        return allowedSpecifiers.contains(self)
    }
}
