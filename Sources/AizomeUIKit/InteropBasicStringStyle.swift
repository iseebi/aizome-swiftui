#if canImport(UIKit)
import SwiftUI
import UIKit
import Aizome

/// A `BasicStringStyle`-equivalent that applies attributes to both SwiftUI and UIKit scopes simultaneously,
/// allowing a single `AttributedString` to be used in both `SwiftUI.Text` and `UIKit.UILabel`.
public struct InteropBasicStringStyle: AizomeStringStyle {
    var swiftUIFont: Font? = nil
    var uiKitFont: UIFont? = nil
    var swiftUIColor: Color? = nil
    var uiKitColor: UIColor? = nil
    var underline: Bool = false
    var strikethrough: Bool = false

    public init(
        swiftUIFont: Font? = nil,
        uiKitFont: UIFont? = nil,
        swiftUIColor: Color? = nil,
        uiKitColor: UIColor? = nil,
        underline: Bool = false,
        strikethrough: Bool = false
    ) {
        self.swiftUIFont = swiftUIFont
        self.uiKitFont = uiKitFont
        self.swiftUIColor = swiftUIColor
        self.uiKitColor = uiKitColor
        self.underline = underline
        self.strikethrough = strikethrough
    }

    public func apply(to attributed: inout AttributedString, range: Range<AttributedString.Index>) {
        var container = AttributeContainer()
        if let swiftUIFont  { container.font = swiftUIFont }
        if let uiKitFont    { container.uiKit.font = uiKitFont }
        if let swiftUIColor { container.foregroundColor = swiftUIColor }
        if let uiKitColor   { container.uiKit.foregroundColor = uiKitColor }
        if underline {
            container.underlineStyle = .single
            container.uiKit.underlineStyle = .single
        }
        if strikethrough {
            container.strikethroughStyle = .single
            container.uiKit.strikethroughStyle = .single
        }
        attributed[range].mergeAttributes(container)
    }
}
#endif
