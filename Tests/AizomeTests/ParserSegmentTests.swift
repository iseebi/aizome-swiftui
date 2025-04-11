import Testing
@testable import Aizome

struct ParserSegmentTests {
    @Test
    func parsesSimpleText() {
        let logger = TestParserLogger()
        let parser = Parser(logger: logger)
        let segments = parser.parseToSegments("Hello world")

        #expect(segments.count == 1)
        guard case .text(let value, let styles) = segments[0] else {
            Issue.record("First segment is not .text")
            return
        }

        #expect(value == "Hello world")
        #expect(styles.isEmpty)
        #expect(logger.warnings.isEmpty)
    }

    @Test
    func parsesSingleTag() {
        let logger = TestParserLogger()
        let parser = Parser(logger: logger)
        let segments = parser.parseToSegments("<blue>Hello</blue>")

        #expect(segments.count == 1)
        guard case .text(let value, let styles) = segments[0] else {
            Issue.record("Expected .text segment")
            return
        }

        #expect(value == "Hello")
        #expect(styles == ["blue"])
    }

    @Test
    func parsesNestedTags() {
        let logger = TestParserLogger()
        let parser = Parser(logger: logger)
        let segments = parser.parseToSegments("<blue><bold>Hello</bold></blue>")

        #expect(segments.count == 1)
        guard case .text(let value, let styles) = segments[0] else {
            Issue.record("Expected .text segment")
            return
        }

        #expect(value == "Hello")
        #expect(styles == ["blue", "bold"])
    }
    
    @Test
    func parsesComplexNestedTags() {
        let logger = TestParserLogger()
        let parser = Parser(logger: logger)
        let segments = parser.parseToSegments("<red><blue>123</blue>456<yellow>789</yellow></red>")

        #expect(segments.count == 3)

        guard case .text(let t0, let s0) = segments[0] else {
            Issue.record("Segment 0 is not .text")
            return
        }
        #expect(t0 == "123")
        #expect(s0 == ["red", "blue"])

        guard case .text(let t1, let s1) = segments[1] else {
            Issue.record("Segment 1 is not .text")
            return
        }
        #expect(t1 == "456")
        #expect(s1 == ["red"])

        guard case .text(let t2, let s2) = segments[2] else {
            Issue.record("Segment 2 is not .text")
            return
        }
        #expect(t2 == "789")
        #expect(s2 == ["red", "yellow"])

        #expect(logger.warnings.isEmpty)
    }

    @Test
    func warnsOnUnopenedClosingTag() {
        let logger = TestParserLogger()
        let parser = Parser(logger: logger)
        _ = parser.parseToSegments("Hello</blue>")

        #expect(logger.contains(.unopenedMarkup(tag: "blue", index: 5)))
    }

    @Test
    func warnsOnUnclosedTag() {
        let logger = TestParserLogger()
        let parser = Parser(logger: logger)
        _ = parser.parseToSegments("<red>Hello")

        #expect(logger.contains(.unclosedMarkup(tag: "red", index: 10)))
    }

    @Test
    func warnsOnUnclosedInvalidTag() {
        let logger = TestParserLogger()
        let parser = Parser(logger: logger)
        _ = parser.parseToSegments("<red hoge</red>")

        #expect(logger.contains(.unclosedTag(index: 0)))
    }

    @Test
    func ignoresEmptyTag() {
        let logger = TestParserLogger()
        let parser = Parser(logger: logger)
        let segments = parser.parseToSegments("Hello<>world")

        #expect(segments.count == 2)
        #expect(logger.contains(.emptyTag(index: 5)))
    }
}
