# Aizome

Aizome is a lightweight Swift library for rendering richly styled text in SwiftUI using a custom markup syntax. Define your own styles and apply them directly within strings, just like HTML—without the complexity.

## Installation

Swift Package Manager

```swift
let package = Package(
    dependencies: [
        .package(url: "https://github.com/iseebi/aizome-swiftui", .upToNextMajor(from: "0.1.0")),
    ],
    targets: [
        .target(
            name: "<your-target-name>",
            dependencies: ["Aizome"]),
    ]
)
```

## How to use

### 1. Define Your Styles

Before rendering styled text, define the styles you want to use:

```swift
import Aizome
import SwiftUI

Aizome.defineDefaultStyles([
    "bold": BasicStringStyle(font: .system(size: 16, weight: .bold)),
    "red": BasicStringStyle(color: .red),
    "highlight": BasicStringStyle(
        font: .system(size: 14),
        color: .white,
        backgroundColor: .blue
    )
])
```

### 2. Write Markup-Style Text

Use custom tags like <bold>, <red>, or any tag name you’ve defined:

```swift
let message = "<bold>Hello</bold>, <red>world</red>! Let's <highlight>shine</highlight>."
```

### 3. Display with styledString

Render the styled string in SwiftUI:

```swift
styledString(message)
```

This will parse your markup, apply the defined styles, and render the text with full SwiftUI support.

### 4. Format Strings with Parameters

You can use placeholders like `%@`, `%d`, and other String.format-style specifiers inside your styled text.

For performance reasons, we recommend creating a StringStyleFormatter instance in advance and reusing it:

```swift
let formatter = StringStyleFormatter(
    "<bold>%@</bold> has <red>%d</red> messages.",
    styles: [
        "bold": BasicStringStyle(font: .system(size: 16, weight: .bold)),
        "red": BasicStringStyle(color: .red)
    ]
)
```

Then use the format method to produce a styled string with your arguments:

```swift
formatter.format("iseebi", 5)
```

This allows you to keep formatting logic efficient and consistent throughout your app.

## Copyright

see ./LICENSE

```
Aizome - Customizable Styled-String(AttributedString) Generator/Formatter
Copyright (c) 2025 Nobuhiro Ito
```
