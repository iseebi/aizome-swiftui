import Testing
import Foundation
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

struct StyleAssert {
    let substring: String
    let font: Font?
    let color: Color? 
    
    init(substring: String, font: Font? = nil, color: Color? = nil) {
        self.substring = substring
        self.font = font
        self.color = color
    }
    
    func assert(in string: AttributedString) throws {
        try assertStyle(string, substring: substring, expectedFont: font, expectedColor: color)
    }
}
