import Foundation
import SwiftUICore

/// A simple implementation of `StringStyle` using basic font, color, and underline options.
struct BasicStringStyle: StringStyle {
    var font: Font? = nil
    var color: Color? = nil
    var underline: Bool = false
    
    func apply(to attributed: inout AttributedString, range: Range<AttributedString.Index>) {
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
