import Foundation
import SwiftUICore

public extension StringStyle {
    /// Creates a basic style using optional font, color, and underline options.
    /// - Parameters:
    ///   - font: The font to apply.
    ///   - color: The foreground color to apply.
    ///   - underline: Whether to apply a single underline style.
    public static func basicStyle(font: Font? = nil, color: Color? = nil, underline: Bool = false) -> StringStyle {
        return BasicStringStyle(font: font, color: color, underline: underline)
    }
    
    /// Creates a style based on a given attribute container.
    /// - Parameter attributes: An `AttributeContainer` to apply.
    public static func attributeContainerStyle(_ attributes: AttributeContainer) -> StringStyle {
        return AttributeContainerStringStyle(attributes: attributes)
    }
}
