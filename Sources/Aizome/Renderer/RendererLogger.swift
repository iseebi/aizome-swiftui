import Foundation

enum RendererWarning: Equatable {
    case noStyle(String)
    case missingArgument(format: String, index: Int)
}

protocol RendererLogger {
    func warning(_ warning: RendererWarning)
}

struct RendererLoggerImpl: RendererLogger {
    
    let logger: Aizome.Logger
    
    init(logger: Aizome.Logger) {
        self.logger = logger
    }
    
    func warning(_ warning: RendererWarning) {
        switch warning {
        case .noStyle(let string):
            logger.warning("No style found for string: \(string)")
        case .missingArgument(let format, let index):
            logger.warning("Missing argument at index \(index) in format: \(format)")
        }
    }
}
