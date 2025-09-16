import Foundation
import SwiftUI

/// A simple implementation of `StringStyle` using basic font, color, underline, and strikethrough options.
public struct BasicStringStyle: AizomeStringStyle {
    var font: Font? = nil
    var color: Color? = nil
    var underline: Bool = false
    var strikethrough: Bool = false
    
    public init(font: Font? = nil, color: Color? = nil, underline: Bool = false, strikethrough: Bool = false) {
        self.font = font
        self.color = color
        self.underline = underline
        self.strikethrough = strikethrough
    }
    
    public func apply(to attributed: inout AttributedString, range: Range<AttributedString.Index>) {
        if let font {
            attributed[range].font = font
        }
        if let color {
            attributed[range].foregroundColor = color
        }
        if underline {
            attributed[range].underlineStyle = .single
        }
        if strikethrough {
            attributed[range].strikethroughStyle = .single
        }
    }
}
