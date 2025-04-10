import Foundation

/// A `StringStyle` implementation that applies an entire `AttributeContainer`.
struct AttributeContainerStringStyle: StringStyle {
    let attributes: AttributeContainer
    
    public init(attributes: AttributeContainer) {
        self.attributes = attributes
    }
    
    func apply(to attributed: inout AttributedString, range: Range<AttributedString.Index>) {
        attributed[range].mergeAttributes(attributes)
    }
}
