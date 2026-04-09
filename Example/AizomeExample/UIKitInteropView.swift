//
//  UIKitInteropView.swift
//  AizomeExample
//
//  Created by Nobuhiro Ito on 2026/04/10.
//

import SwiftUI
import UIKit
import Aizome
import AizomeUIKit

private struct UIKitLabel: UIViewRepresentable {
    let attributedString: AttributedString

    func makeUIView(context: Context) -> UILabel {
        let label = UILabel()
        label.numberOfLines = 0
        label.setContentHuggingPriority(.required, for: .vertical)
        label.setContentCompressionResistancePriority(.required, for: .vertical)
        return label
    }

    func updateUIView(_ uiView: UILabel, context: Context) {
        uiView.attributedText = NSAttributedString(attributedString)
    }

    func sizeThatFits(_ proposal: ProposedViewSize, uiView: UILabel, context: Context) -> CGSize? {
        let width = proposal.width ?? uiView.bounds.width
        return uiView.sizeThatFits(CGSize(width: width, height: .greatestFiniteMagnitude))
    }
}

struct UIKitInteropView: View {
    private let styles: StringStyleDefinitions = [
        "bold": InteropBasicStringStyle(
            swiftUIFont: .system(.body, weight: .bold),
            uiKitFont: .boldSystemFont(ofSize: 17)
        ),
        "red": InteropBasicStringStyle(
            swiftUIColor: .red,
            uiKitColor: .red
        ),
        "u": InteropBasicStringStyle(underline: true),
    ]

    var body: some View {
        let attributed = styledString(
            "This is <bold><red>bold red</red></bold> and <u>underlined</u> text.",
            styles: styles,
            ignoreDefaultStyles: true
        )

        VStack(alignment: .leading, spacing: 8) {
            Text("UIKit Interoperability")
                .font(.title2)
                .bold()

            Text("Same AttributedString rendered in SwiftUI and UIKit:")
                .font(.caption)
                .foregroundStyle(.secondary)

            Text("SwiftUI Text")
                .font(.caption2)
                .foregroundStyle(.secondary)
            Text(attributed)

            Text("UIKit UILabel")
                .font(.caption2)
                .foregroundStyle(.secondary)
            UIKitLabel(attributedString: attributed)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

#Preview {
    UIKitInteropView()
        .padding()
}
