import Testing
import Foundation
import SwiftUICore
@testable import Aizome

enum ExpectRenderSegment {
    case text(String, styles: [String])
    case placeholder(format: String, raw: String, index: Int, styles: [String])
    case rendered([StyleAssert])
    
    func assert(_ segment: RenderSegment) throws {
        switch (segment, self) {
        case (.text(let text, let styles), .text(let expectText, let expectStyles)):
            #expect(text == expectText)
            #expect(styles == expectStyles)
        case (.placeholder(let format, let raw, let index, let styles), .placeholder(let expectFormat, let expectRaw, let expectIndex, let expectStyles)):
            #expect(format == expectFormat)
            #expect(raw == expectRaw)
            #expect(index == expectIndex)
            #expect(styles == expectStyles)
        case (.rendered(let actual), .rendered(let asserts)):
            for assert in asserts {
                try assert.assert(in: actual)
            }
        default:
            Issue.record("Unexpected segment type")
        }
    }
}

