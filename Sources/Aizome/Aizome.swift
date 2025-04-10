import Foundation

/// Aizome provides global configuration for default string styles.
public struct Aizome {
     @MainActor
     private static var _defaultStyles: StringStyleDefinitions = [:]

    /// The default string styles used when no explicit style set is provided.
    @MainActor
    static var defaultStyles: StringStyleDefinitions {
        _defaultStyles
    }
    
    /// Defines or replaces the default string styles.
    /// - Parameter styles: A dictionary mapping style tags to their corresponding styles.
    @MainActor
    public static func defineDefaultStyles(_ styles: StringStyleDefinitions) {
        _defaultStyles = styles
    }
    
    private static let _loggerContainer = LoggerContainer()
    
    public static func setLogger(_ logger: any Logger) async {
        await _loggerContainer.setLogger(logger)
    }
    
    static func logWarning(_ message: String) async {
        await _loggerContainer.warning(message)
    }
}
