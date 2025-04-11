/**
 * Copyright 2025 Nobuhiro Ito
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import Foundation

/// Aizome provides global configuration for default string styles.
public struct Aizome {
     @MainActor
     private static var _defaultStyles: StringStyleDefinitions = [:]

    /// The default string styles used when no explicit style set is provided.
    @MainActor
    static var defaultStyles: StringStyleDefinitions {
        _defaultStyles
    }
    
    /// Defines or replaces the default string styles.
    /// - Parameter styles: A dictionary mapping style tags to their corresponding styles.
    @MainActor
    public static func defineDefaultStyles(_ styles: StringStyleDefinitions) {
        _defaultStyles = styles
    }
    
    private static let _loggerContainer = LoggerContainer()
    
    public static func setLogger(_ logger: any Logger) async {
        await _loggerContainer.setLogger(logger)
    }
    
    static func logWarning(_ message: String) async {
        await _loggerContainer.warning(message)
    }
    
    static func createParserRenderer() -> (parser: Parser, renderer: AttributedStringRenderer) {
        let logger = StaticLogger()
        let parser = Parser(logger: ParserLoggerImpl(logger: logger))
        let renderer = AttributedStringRenderer(logger: RendererLoggerImpl(logger: StaticLogger()))
        return (parser, renderer)
    }
}
