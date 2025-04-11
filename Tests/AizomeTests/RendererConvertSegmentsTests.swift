import Testing
import SwiftUICore
import Foundation
@testable import Aizome

func mergeAttributedStrings(_ strings: [AttributedString]) -> AttributedString {
    var result = AttributedString()
    for string in strings {
        result.append(string)
    }
    return result
}

struct RendererConvertSegmentsTests {
    let bold12Font = Font.system(size: 12, weight: .bold)
    
    lazy var styleDefinition: StringStyleDefinitions = [
        "bold": BasicStringStyle(font: bold12Font),
        "red": BasicStringStyle(color: .red),
        "blue": BasicStringStyle(color: .blue),
    ]
    
    @Test mutating func simpleConvertCreatesCorrectSegments() throws {
        let input: [ParserSegment] = [
            .text("Hello", styles: ["bold"]),
            .placeholder(format: "%d", raw: "%1$d", index: 0, styles: ["italic"]),
            .text("World", styles: [])
        ]
        let expect: [ExpectRenderSegment] = [
            .text("Hello", styles: ["bold"]),
            .placeholder(format: "%d", raw: "%1$d", index: 0, styles: ["italic"]),
            .text("World", styles: [])
        ]
        try run(mode: .simpleConvert, styles: styleDefinition, input: input, expect: expect)
    }
    
    @Test mutating func preRenderMergesAndAppliesStyles() throws {
        let input: [ParserSegment] = [
            .text("Hello", styles: ["bold", "red"]),
            .text(" ", styles: []),
            .text("World", styles: ["blue"]),
        ]

        let expect: [ExpectRenderSegment] = [
            .rendered([
                .init(substring: "Hello", font: bold12Font),
                .init(substring: "World", color: .blue),
            ]),
        ]

        try run(mode: .preRender, styles: styleDefinition, input: input, expect: expect)
    }
    
    @Test mutating func preRenderMergeDifferentStyles() throws {
        let input: [ParserSegment] = [
            .text("Red", styles: ["red"]),
            .text("Blue", styles: ["blue"]),
        ]

        let expect: [ExpectRenderSegment] = [
            .rendered([
                .init(substring: "Red", color: .red),
                .init(substring: "Blue", color: .blue)
            ]),
        ]

        try run(mode: .preRender, styles: styleDefinition, input: input, expect: expect)
    }
    
    @Test mutating func preRenderAppliesMultipleStyles() throws {
        let input: [ParserSegment] = [
            .text("Important", styles: ["bold", "red"]),
        ]

        let expect: [ExpectRenderSegment] = [
            .rendered([.init(substring: "Important", font: bold12Font, color: .red)])
        ]

        try run(mode: .preRender, styles: styleDefinition, input: input, expect: expect)
    }
    
    @Test mutating func preRenderEmptyStringStillProducesRenderedSegment() throws {
        let input: [ParserSegment] = [
            .text("", styles: ["bold"]),
        ]

        let expect: [ExpectRenderSegment] = [
            .rendered([]) // 空でも .rendered として出力される
        ]

        try run(mode: .preRender, styles: styleDefinition, input: input, expect: expect)
    }
    
    @Test mutating func preRenderKeepsPlaceholderSeparate() throws {
        let input: [ParserSegment] = [
            .text("User ID: ", styles: ["bold"]),
            .placeholder(format: "%04d", raw: "%1$04d", index: 0, styles: ["red"]),
        ]

        let expect: [ExpectRenderSegment] = [
            .rendered([.init(substring: "User ID: ", font: bold12Font)]),
            .placeholder(format: "%04d", raw: "%1$04d", index: 0, styles: ["red"]),
        ]

        try run(mode: .preRender, styles: styleDefinition, input: input, expect: expect)
    }
    
    @Test mutating func preRenderWarnsWhenStyleIsMissing() throws {
        let input: [ParserSegment] = [
            .text("Hello", styles: ["nonexistent-style"]),
        ]

        let expect: [ExpectRenderSegment] = [
            .rendered([.init(substring: "Hello")]) // スタイルがないが、文字列は出力される
        ]

        try run(
            mode: .preRender,
            styles: styleDefinition,
            input: input,
            expect: expect,
            warnings: [.noStyle("nonexistent-style")]
        )
    }
    
    func run(mode: ConvertMode, styles styleDefinitions: StringStyleDefinitions, input: [ParserSegment], expect: [ExpectRenderSegment], warnings: [RendererWarning] = []) throws {
        let logger = TestRendererLogger()
        let renderer = AttributedStringRenderer(logger: logger)
        let result = renderer.convertSegments(parsed: input, mode: mode, styles: styleDefinitions)
        
        #expect(result.count == expect.count)
        
        for (i, segment) in result.enumerated() {
            try expect[i].assert(segment)
        }
        
        #expect(logger.warnings == warnings)
    }
}
