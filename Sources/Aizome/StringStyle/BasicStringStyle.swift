import Foundation
import SwiftUI

/// A simple implementation of `StringStyle` using basic font, color, and underline options.
public struct BasicStringStyle: AizomeStringStyle {
    var font: Font? = nil
    var color: Color? = nil
    var underline: Bool = false
    
    public init(font: Font? = nil, color: Color? = nil, underline: Bool = false) {
        self.font = font
        self.color = color
        self.underline = underline
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
    }
}
