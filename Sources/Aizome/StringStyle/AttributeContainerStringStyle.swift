import Foundation

/// A `StringStyle` implementation that applies an entire `AttributeContainer`.
public struct AttributeContainerStringStyle: AizomeStringStyle {
    let attributes: AttributeContainer
    
    public init(attributes: AttributeContainer) {
        self.attributes = attributes
    }
    
    public func apply(to attributed: inout AttributedString, range: Range<AttributedString.Index>) {
        attributed[range].mergeAttributes(attributes)
    }
}
