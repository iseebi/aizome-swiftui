import Testing
@testable import Aizome

struct SegmentParserTests {
    final class TestLogger: ParserLogger {
        var warnings: [ParserWarning] = []

        func warning(_ warning: ParserWarning) {
            warnings.append(warning)
        }

        func contains(_ expected: ParserWarning) -> Bool {
            warnings.contains(where: { $0 == expected })
        }
    }
    
    @Test
    func parsesSimpleText() {
        let logger = TestLogger()
        let segments = parseToSegments("Hello world", logger: logger)

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
        let logger = TestLogger()
        let segments = parseToSegments("<blue>Hello</blue>", logger: logger)

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
        let logger = TestLogger()
        let segments = parseToSegments("<blue><bold>Hello</bold></blue>", logger: logger)

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
        let logger = TestLogger()
        let segments = parseToSegments("<red><blue>123</blue>456<yellow>789</yellow></red>", logger: logger)

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
        let logger = TestLogger()
        _ = parseToSegments("Hello</blue>", logger: logger)

        #expect(logger.contains(.unopenedMarkup(tag: "blue", index: 5)))
    }

    @Test
    func warnsOnUnclosedTag() {
        let logger = TestLogger()
        _ = parseToSegments("<red>Hello", logger: logger)

        #expect(logger.contains(.unclosedMarkup(tag: "red", index: 10)))
    }

    @Test
    func warnsOnUnclosedInvalidTag() {
        let logger = TestLogger()
        _ = parseToSegments("<red hoge</red>", logger: logger)

        #expect(logger.contains(.unclosedTag(index: 0)))
    }

    @Test
    func ignoresEmptyTag() {
        let logger = TestLogger()
        let segments = parseToSegments("Hello<>world", logger: logger)

        #expect(segments.count == 2)
        #expect(logger.contains(.emptyTag(index: 5)))
    }
}
