//
//  ContentView.swift
//  AizomeExample
//
//  Created by Nobuhiro Ito on 2025/04/10.
//

import SwiftUI
import Aizome

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
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
