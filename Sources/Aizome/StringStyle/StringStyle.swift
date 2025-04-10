import Foundation

/// A protocol that defines how to apply style to a specified range of an `AttributedString`.
public protocol StringStyle {
    /// Applies the style to a given range of an AttributedString.
    /// - Parameters:
    ///   - attributed: The mutable attributed string to which the style will be applied.
    ///   - range: The range within the string where the style should be applied.
    func apply(to attributed: inout AttributedString, range: Range<AttributedString.Index>)
}

public typealias StringStyleDefinitions = [String: StringStyle]
