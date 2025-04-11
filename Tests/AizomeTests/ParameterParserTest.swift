import Testing
@testable import Aizome

struct ParseParameterStringsTests {
    @Test
    func parsesSimplePlaceholder() throws {
        let input: [ParserSegment] = [
            .text("Hello %@!", styles: ["bold"]),
        ]
        let expect: [ParserSegment] = [
            .text("Hello ", styles: ["bold"]),
            .placeholder(format: "%@", index: 0, styles: ["bold"]),
            .text("!", styles: ["bold"]),
        ]
        try run(input: input, expect: expect)
    }
    
    @Test
    func parsesSimpleMultiplePlaceholder() throws {
        let input: [ParserSegment] = [
            .text("Hello %@! Your score is %d", styles: ["bold"]),
        ]
        let expect: [ParserSegment] = [
            .text("Hello ", styles: ["bold"]),
            .placeholder(format: "%@", index: 0, styles: ["bold"]),
            .text("! Your score is ", styles: ["bold"]),
            .placeholder(format: "%d", index: 1, styles: ["bold"]),
        ]
        try run(input: input, expect: expect)
    }

    @Test
    func parsesMultiplePlaceholdersWithExplicitIndexes() throws {
        let input: [ParserSegment] = [
            .text("A: %2$d, B: %1$@, C: %3$.2f", styles: [])
        ]
        let expect: [ParserSegment] = [
            .text("A: ", styles: []),
            .placeholder(format: "%d", index: 1, styles: []),
            .text(", B: ", styles: []),
            .placeholder(format: "%@", index: 0, styles: []),
            .text(", C: ", styles: []),
            .placeholder(format: "%.2f", index: 2, styles: []),
        ]
        try run(input: input, expect: expect)
    }
    
    @Test
    func parsesEscapedPercent() throws {
        let input: [ParserSegment] = [
            .text("Progress: 100%%", styles: ["italic"])
        ]
        let expect: [ParserSegment] = [
            .text("Progress: 100", styles: ["italic"]),
            .text("%", styles: ["italic"]),
        ]
        try run(input: input, expect: expect)
    }
    
    @Test
    func ignoresInvalidFormat() throws {
        let input: [ParserSegment] = [
            .text("Result: %z", styles: [])
        ]
        let expect: [ParserSegment] = [
            .text("Result: ", styles: [])
        ]
        let warnings: [ParserWarning] = [
            .unknownFormat(format: "%z"),
        ]
        try run(input: input, expect: expect, warnings: warnings)
    }
    
    @Test
    func parsesMixedExplicitAndImplicitIndexes() throws {
        let input: [ParserSegment] = [
            .text("%1$d %d %4$d %d %d", styles: [])
        ]
        let expect: [ParserSegment] = [
            .placeholder(format: "%d", index: 0, styles: []),
            .text(" ", styles: []),
            .placeholder(format: "%d", index: 1, styles: []),
            .text(" ", styles: []),
            .placeholder(format: "%d", index: 3, styles: []),
            .text(" ", styles: []),
            .placeholder(format: "%d", index: 2, styles: []),
            .text(" ", styles: []),
            .placeholder(format: "%d", index: 4, styles: []),
        ]
        try run(input: input, expect: expect)
    }
    
    func run(input: [ParserSegment], expect: [ParserSegment], warnings: [ParserWarning] = []) throws {
        let logger = TestParserLogger()
        let result = parseParameterStrings(input, logger: logger)
        try #require(result.count == expect.count)
        for (index, segment) in result.enumerated() {
            switch (segment, expect[index]) {
            case (.text(let text, let styles), .text(let expectedText, let expectedStyles)):
                #expect(text == expectedText)
                #expect(styles == expectedStyles)
            case (.placeholder(let format, let index, let styles), .placeholder(let expectedFormat, let expectedIndex, let expectedStyles)):
                #expect(format == expectedFormat)
                #expect(index == expectedIndex)
                #expect(styles == expectedStyles)
            default:
                Issue.record("Segment \(index) does not match")
            }
        }
        try #require(logger.warnings.count == warnings.count)
        for (index, warning) in logger.warnings.enumerated() {
            #expect(warning == warnings[index])
        }
    }
}
