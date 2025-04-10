import Testing
import SwiftUICore
@testable import Aizome

func assertStyle(
    _ string: AttributedString,
    substring: String,
    expectedFont: Font? = nil,
    expectedColor: Color? = nil
) throws {
    let range = try #require(string.range(of: substring), "Substring '\(substring)' not found")
    let run = try #require(string.runs.first { $0.range == range }, "No run found for substring '\(substring)'")
    
    if let expectedFont {
        #expect(run.font == expectedFont)
    }

    if let expectedColor {
        #expect(run.foregroundColor == expectedColor)
    }
}

@Test func styledStringTest() async throws {
    struct testCase {
        let formatString: String
        let assert: (AttributedString) throws -> ()
    }
    
    let definitions: StringStyleDefinitions = [
        "red": BasicStringStyle(color: .blue),
        "blue": BasicStringStyle(color: .blue),
        "bold12": BasicStringStyle(font: .system(size: 12, weight: .bold)),
        "normal12": BasicStringStyle(font: .system(size: 12)),
        "normal14": BasicStringStyle(font: .system(size: 14))
    ]
    
    let cases = [
        testCase(formatString: "<blue>Hello</blue> <bold12>World</bold12>", assert: { str in
            try assertStyle(str, substring: "Hello", expectedColor: .blue)
            try assertStyle(str, substring: "World", expectedFont: .system(size: 12, weight: .bold))
        }),
        testCase(formatString: "<blue><bold12>Hello</bold12></blue> <bold12>World</bold12>", assert: { str in
            try assertStyle(str, substring: "Hello", expectedFont: .system(size: 12, weight: .bold), expectedColor: .blue)
            try assertStyle(str, substring: "World", expectedFont: .system(size: 12, weight: .bold))
        }),
        testCase(formatString: "<red><bold12>Hello</bold12></red> <bold12>World</bold12>", assert: { str in
            try assertStyle(str, substring: "Hello", expectedFont: .system(size: 12, weight: .bold), expectedColor: .red)
            try assertStyle(str, substring: "World", expectedFont: .system(size: 12, weight: .bold))
        }),
        testCase(formatString: "<red><bold12>Hello world <normal14>Aizome</normal14></bold12></red>", assert: { str in
            try assertStyle(str, substring: "Hello world ", expectedFont: .system(size: 12, weight: .bold), expectedColor: .blue)
            try assertStyle(str, substring: "Aizome", expectedFont: .system(size: 14), expectedColor: .blue)
        }),
        testCase(formatString: "<blue><bold12><unknown>Hello</unknown></bold12></blue> <bold12>World</bold12>", assert: { str in
            try assertStyle(str, substring: "Hello", expectedFont: .system(size: 12, weight: .bold), expectedColor: .blue)
            try assertStyle(str, substring: "World", expectedFont: .system(size: 12, weight: .bold))
        }),
    ]
    
    for c in cases {
        let result = styledString(formatString: c.formatString, styles: definitions)
        try c.assert(result)
    }
}
