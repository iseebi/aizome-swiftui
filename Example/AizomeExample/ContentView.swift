//
//  ContentView.swift
//  AizomeExample
//
//  Created by Nobuhiro Ito on 2025/04/10.
//

import SwiftUI
import Aizome

struct UnderlinedStringStyle: AizomeStringStyle {
    func apply(to attributed: inout AttributedString, range: Range<AttributedString.Index>) {
        attributed[range].underlineStyle = .single
    }
}

struct ContentView: View {
    let parameterizedStyleFormatter = StringStyleFormatter(formatString: "User: <bold>%@</bold>, Score: <red>%03d</red>")
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Formatted Styled Text")
                .font(.title2)
                .bold()

            Text(styledString("This is <red>red</red> and <bold>bold</bold> text with &lt;escaped&gt; HTML."))
                .font(.body)
                .multilineTextAlignment(.leading)

            Text("Sample with Placeholders")
                .font(.title2)
                .bold()

            Text(parameterizedStyleFormatter.format("Alice", 7))
                .font(.body)
                .multilineTextAlignment(.leading)
            
            Text("Custom StringStyle")
                .font(.title2)
                .bold()

            Text(styledString("This text is <u>underlined</u>. This text is <blue><u>underlined and blue</u></blue>.", styles: [
                "u": UnderlinedStringStyle(),
            ]))
                .font(.body)
                .multilineTextAlignment(.leading)
            
            Text(styledString(
                "<strikethrough>Cancelled text.</strikethrough>",
                styles: [
                    "strikethrough": BasicStringStyle(strikethrough: true)
                ]
            ))
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
