import Foundation

extension Aizome {
    public protocol Logger: Sendable {
        func warning(_ message: String)
    }
    
    struct DefaultLogger : Logger {
        func warning(_ message: String) {
            // no operation
        }
    }
    
    struct StaticLogger: Aizome.Logger {
        func warning(_ message: String) {
            Task {
                await Aizome.logWarning(message)
            }
        }
    }

    actor LoggerContainer {
        private var _logger: Logger = DefaultLogger()
        
        func setLogger(_ logger: any Logger) {
            self._logger = logger
        }
        
        func warning(_ message: String) {
            _logger.warning(message)
        }
    }
}
