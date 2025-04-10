import Foundation

/// Aizome provides global configuration for default string styles.
public struct Aizome {
    /// The default string styles used when no explicit style set is provided.
    @MainActor
    static var defaultStyles: StringStyleDefinitions {
        _defaultStyles
    }
   
    @MainActor
    private static var _defaultStyles: StringStyleDefinitions = [:]
    
    /// Defines or replaces the default string styles.
    /// - Parameter styles: A dictionary mapping style tags to their corresponding styles.
    @MainActor
    public static func defineDefaultStyles(_ styles: StringStyleDefinitions) {
        _defaultStyles = styles
    }
}
