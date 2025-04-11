import Foundation

enum ParserWarning: Equatable {
    case unclosedTag(index: Int)
    case unopenedMarkup(tag: String, index: Int)
    case unclosedMarkup(tag: String, index: Int)
    case emptyTag(index: Int)
    
    case unknownFormat(format: String)
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
        case .unknownFormat(format: let format):
            logger.warning("unknown format: \(format)")
        }
    }
}
