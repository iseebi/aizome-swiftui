import Testing
import SwiftUICore
@testable import Aizome

struct AizomeTests {
    let definitions: StringStyleDefinitions = [
        "red": BasicStringStyle(color: .red),
        "blue": BasicStringStyle(color: .blue),
        "bold12": BasicStringStyle(font: .system(size: 12, weight: .bold)),
        "normal12": BasicStringStyle(font: .system(size: 12)),
        "normal14": BasicStringStyle(font: .system(size: 14))
    ]

    @Test func testStyle_blueAndBold() throws {
        let result = styledString(formatString: "<blue>Hello</blue> <bold12>World</bold12>", styles: definitions)
        try assertStyle(result, substring: "Hello", expectedColor: .blue)
        try assertStyle(result, substring: "World", expectedFont: .system(size: 12, weight: .bold))
    }

    @Test func testStyle_nestedBlueBold() throws {
        let result = styledString(formatString: "<blue><bold12>Hello</bold12></blue> <bold12>World</bold12>", styles: definitions)
        try assertStyle(result, substring: "Hello", expectedFont: .system(size: 12, weight: .bold), expectedColor: .blue)
        try assertStyle(result, substring: "World", expectedFont: .system(size: 12, weight: .bold))
    }

    @Test func testStyle_redAndBold() throws {
        let result = styledString(formatString: "<red><bold12>Hello</bold12></red> <bold12>World</bold12>", styles: definitions)
        try assertStyle(result, substring: "Hello", expectedFont: .system(size: 12, weight: .bold), expectedColor: .red)
        try assertStyle(result, substring: "World", expectedFont: .system(size: 12, weight: .bold))
    }

    @Test func testStyle_nestedNormalInBold() throws {
        let result = styledString(formatString: "<red><bold12>Hello world <normal14>Aizome</normal14></bold12></red>", styles: definitions)
        try assertStyle(result, substring: "Hello world ", expectedFont: .system(size: 12, weight: .bold), expectedColor: .red)
        try assertStyle(result, substring: "Aizome", expectedFont: .system(size: 14), expectedColor: .red)
    }

    @Test func testStyle_unknownInnerTag() throws {
        let result = styledString(formatString: "<blue><bold12><unknown>Hello</unknown></bold12></blue> <bold12>World</bold12>", styles: definitions)
        try assertStyle(result, substring: "Hello", expectedFont: .system(size: 12, weight: .bold), expectedColor: .blue)
        try assertStyle(result, substring: "World", expectedFont: .system(size: 12, weight: .bold))
    }
}
