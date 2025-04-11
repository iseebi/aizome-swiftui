import Testing
import SwiftUICore
import Foundation
@testable import Aizome

struct RenderAsLiteralTests {
    let bold12Font = Font.system(size: 12, weight: .bold)
    
    lazy var styleDefinition: StringStyleDefinitions = [
        "bold": BasicStringStyle(font: bold12Font),
        "red": BasicStringStyle(color: .red),
        "blue": BasicStringStyle(color: .blue),
    ]

    @Test mutating func testSimpleTexts() throws {
        let input: [RenderSegment] = [
            .text("Hello", styles: ["bold"]),
            .text(" ", styles: []),
            .text("World", styles: ["red"])
        ]
        let expect: [StyleAssert] = [
            .init(substring: "Hello", font: bold12Font),
            .init(substring: "World", color: .red)
        ]
        
        try run(input, with: styleDefinition, expect: expect)
    }
    
    @Test mutating func testSimplePredendered() throws {
        let input: [RenderSegment] = [
            .text("Hello", styles: ["bold"]),
            .text(" ", styles: []),
            .rendered(AttributedString("World", attributes: attrContainer {
                $0.foregroundColor = .red
            }))
        ]
        let expect: [StyleAssert] = [
            .init(substring: "Hello", font: bold12Font),
            .init(substring: "World", color: .red)
        ]
        
        try run(input, with: styleDefinition, expect: expect)
    }
    
    @Test mutating func testPlaceholderWithStyle() throws {
        let input: [RenderSegment] = [
            .placeholder(format: "%d", raw: "%1$d", index: 0, styles: ["red"]),
        ]
        let expect: [StyleAssert] = [
            .init(substring: "%1$d", color: .red)
        ]
        try run(input, with: styleDefinition, expect: expect)
    }
    
    @Test mutating func testPlaceholderWithoutStyle() throws {
        let input: [RenderSegment] = [
            .placeholder(format: "%@", raw: "%2$@", index: 1, styles: [])
        ]
        let expect: [StyleAssert] = [
            .init(substring: "%2$@")
        ]
        try run(input, with: styleDefinition, expect: expect)
    }
    
    @Test mutating func testTextAndPlaceholderMixed() throws {
        let input: [RenderSegment] = [
            .text("ID: ", styles: ["blue"]),
            .placeholder(format: "%04d", raw: "%1$04d", index: 0, styles: ["bold"]),
        ]
        let expect: [StyleAssert] = [
            .init(substring: "ID: ", color: .blue),
            .init(substring: "%1$04d", font: bold12Font),
        ]
        try run(input, with: styleDefinition, expect: expect)
    }
    
    @Test mutating func testWarningOnUnknownStyle() throws {
        let input: [RenderSegment] = [
            .text("Oops", styles: ["ghost-style"]),
            .placeholder(format: "%@", raw: "%1$@", index: 0, styles: ["ghost-style"]),
        ]
        let expect: [StyleAssert] = [
            .init(substring: "Oops%1$@"),
        ]
        let warnings: [RendererWarning] = [
            .noStyle("ghost-style"),
            .noStyle("ghost-style")
        ]
        try run(input, with: styleDefinition, expect: expect, warnings: warnings)
    }
    
    @Test mutating func testOnlyRenderedSegments() throws {
        let input: [RenderSegment] = [
            .rendered(AttributedString("Done", attributes: attrContainer {
                $0.foregroundColor = .blue
            }))
        ]
        let expect: [StyleAssert] = [
            .init(substring: "Done", color: .blue)
        ]
        try run(input, with: styleDefinition, expect: expect)
    }
    
    func run(_ segments: [RenderSegment], with definitions: StringStyleDefinitions, expect: [StyleAssert], warnings: [RendererWarning] = []) throws {
        let logger = TestRendererLogger()
        let renderer = AttributedStringRenderer(logger: logger)
        let rendered = renderer.renderAsLiteral(segments, with: definitions)
        
        #expect(logger.warnings == warnings)

        // Check the rendered output
        for (_, assert) in expect.enumerated() {
            try assert.assert(in: rendered)
        }
    }
}
