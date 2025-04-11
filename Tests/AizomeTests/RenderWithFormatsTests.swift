import Testing
import SwiftUICore
import Foundation
@testable import Aizome

struct RenderWithFormatsTests {
    let bold12Font = Font.system(size: 12, weight: .bold)
    
    lazy var styleDefinition: StringStyleDefinitions = [
        "bold": BasicStringStyle(font: bold12Font),
        "red": BasicStringStyle(color: .red),
        "blue": BasicStringStyle(color: .blue),
    ]
    
    @Test mutating func testFormattedPlaceholderWithStyle() throws {
        let segments: [RenderSegment] = [
            .text("Score: ", styles: ["bold"]),
            .placeholder(format: "%04d", raw: "%1$04d", index: 0, styles: ["red"])
        ]
        let arguments: [CVarArg] = [7]
        let expect: [StyleAssert] = [
            .init(substring: "Score: ", font: bold12Font),
            .init(substring: "0007", color: .red)
        ]
        try run(segments, arguments: arguments, with: styleDefinition, expect: expect)
    }
    
    @Test mutating func testRenderedSegmentIsAppendedAsIs() throws {
        let rendered = AttributedString("Fixed", attributes: attrContainer {
            $0.foregroundColor = .blue
        })
        let segments: [RenderSegment] = [
            .text("Output: ", styles: []),
            .rendered(rendered)
        ]
        let expect: [StyleAssert] = [
            .init(substring: "Fixed", color: .blue)
        ]
        try run(segments, arguments: [], with: styleDefinition, expect: expect)
    }
    
    @Test mutating func testMissingArgumentWarning() throws {
        let segments: [RenderSegment] = [
            .text("Name: ", styles: []),
            .placeholder(format: "%@", raw: "%1$@", index: 0, styles: [])
        ]
        let arguments: [CVarArg] = [] // 引数なし
        let expect: [StyleAssert] = [] // 出力には何も追加されない

        let warnings: [RendererWarning] = [
            .missingArgument(format: "%1$@", index: 0)
        ]
        
        try run(segments, arguments: arguments, with: styleDefinition, expect: expect, warnings: warnings)
    }
    
    @Test mutating func testUnknownStyleWarning() throws {
        let segments: [RenderSegment] = [
            .placeholder(format: "%@", raw: "%1$@", index: 0, styles: ["ghost"])
        ]
        let arguments: [CVarArg] = ["abc"]
        let expect: [StyleAssert] = [
            .init(substring: "abc")
        ]
        let warnings: [RendererWarning] = [
            .noStyle("ghost")
        ]
        
        try run(segments, arguments: arguments, with: styleDefinition, expect: expect, warnings: warnings)
    }
    
    @Test mutating func testMultiplePlaceholders() throws {
        let segments: [RenderSegment] = [
            .text("ID: ", styles: []),
            .placeholder(format: "%d", raw: "%1$d", index: 0, styles: ["red"]),
            .text(" Name: ", styles: []),
            .placeholder(format: "%@", raw: "%2$@", index: 1, styles: ["blue"]),
        ]
        let arguments: [CVarArg] = [123, "Alice"]
        let expect: [StyleAssert] = [
            .init(substring: "123", color: .red),
            .init(substring: "Alice", color: .blue),
        ]
        
        try run(segments, arguments: arguments, with: styleDefinition, expect: expect)
    }
    
    func run(
        _ segments: [RenderSegment],
        arguments: [CVarArg],
        with definitions: StringStyleDefinitions,
        expect: [StyleAssert],
        warnings: [RendererWarning] = []
    ) throws {
        let logger = TestRendererLogger()
        let renderer = AttributedStringRenderer(logger: logger)
        let rendered = renderer.renderWithFormats(segments, arguments: arguments, with: definitions)
        
        #expect(logger.warnings == warnings)

        for (_, assert) in expect.enumerated() {
            try assert.assert(in: rendered)
        }
    }
}
