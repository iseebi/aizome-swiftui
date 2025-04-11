//
//  ContentView.swift
//  AizomeExample
//
//  Created by Nobuhiro Ito on 2025/04/10.
//

import SwiftUI
import Aizome

struct ContentView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Formatted Styled Text")
                .font(.title2)
                .bold()

            Text(formattedExample)
                .font(.body)
                .multilineTextAlignment(.leading)

            Text("Sample with Placeholders")
                .font(.title2)
                .bold()

            Text(parameterizedExample)
                .font(.body)
                .multilineTextAlignment(.leading)
        }
        .padding()
    }
    
    private var formattedExample: AttributedString {
        let format = "This is <red>red</red> and <bold>bold</bold> text with &lt;escaped&gt; HTML."
        return StringStyleFormatter(formatString: format).render()
    }

    private var parameterizedExample: AttributedString {
        let format = "User: <bold>%@</bold>, Score: <red>%03d</red>"
        return StringStyleFormatter(formatString: format).format("Alice", 7)
    }
}

#Preview {
    ContentView()
}
