#if canImport(UIKit)
import Testing
import SwiftUI
import UIKit
import Aizome
@testable import AizomeUIKit

private func swiftUIFont(_ run: AttributedString.Runs.Run) -> Font? {
    run.font
}

private func swiftUIColor(_ run: AttributedString.Runs.Run) -> Color? {
    run.foregroundColor
}

private func uiKitFont(_ run: AttributedString.Runs.Run) -> UIFont? {
    run[AttributeScopes.UIKitAttributes.FontAttribute.self]
}

private func uiKitColor(_ run: AttributedString.Runs.Run) -> UIColor? {
    run[AttributeScopes.UIKitAttributes.ForegroundColorAttribute.self]
}

private func uiKitUnderline(_ run: AttributedString.Runs.Run) -> NSUnderlineStyle? {
    run[AttributeScopes.UIKitAttributes.UnderlineStyleAttribute.self]
}

private func uiKitStrikethrough(_ run: AttributedString.Runs.Run) -> NSUnderlineStyle? {
    run[AttributeScopes.UIKitAttributes.StrikethroughStyleAttribute.self]
}

private func run(of substring: String, in string: AttributedString) throws -> AttributedString.Runs.Run {
    let range = try #require(string.range(of: substring), "Substring '\(substring)' not found")
    return try #require(string.runs.first { $0.range == range }, "No run found for substring '\(substring)'")
}

struct InteropBasicStringStyleTests {

    // MARK: - SwiftUIスコープ

    @MainActor @Test func swiftUIScope_color() throws {
        let result = styledString(
            "<red>Hello</red>",
            styles: ["red": InteropBasicStringStyle(swiftUIColor: .red)],
            ignoreDefaultStyles: true
        )
        let r = try run(of: "Hello", in: result)
        #expect(swiftUIColor(r) == .red)
    }

    @MainActor @Test func swiftUIScope_font() throws {
        let font = Font.system(size: 12, weight: .bold)
        let result = styledString(
            "<bold>Hello</bold>",
            styles: ["bold": InteropBasicStringStyle(swiftUIFont: font)],
            ignoreDefaultStyles: true
        )
        let r = try run(of: "Hello", in: result)
        #expect(swiftUIFont(r) == font)
    }

    // MARK: - UIKitスコープ

    @MainActor @Test func uiKitScope_color() throws {
        let result = styledString(
            "<red>Hello</red>",
            styles: ["red": InteropBasicStringStyle(uiKitColor: .red)],
            ignoreDefaultStyles: true
        )
        let r = try run(of: "Hello", in: result)
        #expect(uiKitColor(r) == .red)
    }

    @MainActor @Test func uiKitScope_font() throws {
        let font = UIFont.boldSystemFont(ofSize: 12)
        let result = styledString(
            "<bold>Hello</bold>",
            styles: ["bold": InteropBasicStringStyle(uiKitFont: font)],
            ignoreDefaultStyles: true
        )
        let r = try run(of: "Hello", in: result)
        #expect(uiKitFont(r) == font)
    }

    // MARK: - 両スコープの同居

    @MainActor @Test func bothScopes_colorCoexist() throws {
        let result = styledString(
            "<c>Hello</c>",
            styles: ["c": InteropBasicStringStyle(swiftUIColor: .blue, uiKitColor: .green)],
            ignoreDefaultStyles: true
        )
        let r = try run(of: "Hello", in: result)
        #expect(swiftUIColor(r) == .blue)
        #expect(uiKitColor(r) == .green)
    }

    @MainActor @Test func bothScopes_fontCoexist() throws {
        let swiftFont = Font.system(size: 12, weight: .bold)
        let uiFont = UIFont.boldSystemFont(ofSize: 14)
        let result = styledString(
            "<f>Hello</f>",
            styles: ["f": InteropBasicStringStyle(swiftUIFont: swiftFont, uiKitFont: uiFont)],
            ignoreDefaultStyles: true
        )
        let r = try run(of: "Hello", in: result)
        #expect(swiftUIFont(r) == swiftFont)
        #expect(uiKitFont(r) == uiFont)
    }

    // MARK: - underline / strikethrough

    @MainActor @Test func underline_bothScopes() throws {
        let result = styledString(
            "<u>Hello</u>",
            styles: ["u": InteropBasicStringStyle(underline: true)],
            ignoreDefaultStyles: true
        )
        let r = try run(of: "Hello", in: result)
        #expect(r.underlineStyle == .single)
        #expect(uiKitUnderline(r) == .single)
    }

    @MainActor @Test func strikethrough_bothScopes() throws {
        let result = styledString(
            "<s>Hello</s>",
            styles: ["s": InteropBasicStringStyle(strikethrough: true)],
            ignoreDefaultStyles: true
        )
        let r = try run(of: "Hello", in: result)
        #expect(r.strikethroughStyle == .single)
        #expect(uiKitStrikethrough(r) == .single)
    }
}
#endif
