import Foundation
@testable import Aizome

final class TestParserLogger: ParserLogger {
    var warnings: [ParserWarning] = []

    func warning(_ warning: ParserWarning) {
        warnings.append(warning)
    }

    func contains(_ expected: ParserWarning) -> Bool {
        warnings.contains(where: { $0 == expected })
    }
}

