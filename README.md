# Aizome

[![Release](https://img.shields.io/github/v/release/iseebi/aizome-swiftui)](https://github.com/iseebi/aizome-swiftui/releases/latest) <!--
[![Swift Compatibility](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fiseebi%2Faizome-swiftui%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/iseebi/aizome-swiftui)
[![Platform Compatibility](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fiseebi%2Faizome-swiftui%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/iseebi/aizome-swiftui)
-->[![License](https://img.shields.io/github/license/iseebi/aizome-swiftui)](https://github.com/iseebi/aizome-swiftui/blob/main/LICENSE)

See also: [aizome-compose(for Jetpack Compose in Android/Compose Multiplatform)](https://github.com/iseebi/aizome-compose)

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

Use custom tags like `<bold>`, `<red>`, or any tag name you've defined:

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

For performance reasons, we need to creating a StringStyleFormatter instance in advance and reusing it:

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

## Advanced Usage

### Using `AttributeContainerStringStyle`

If you want full control over the attributes applied to the styled text—beyond font and color—you can use `AttributeContainerStringStyle`.

This style type allows you to directly specify a `AttributeContainer`, enabling integration with underline, kerning, tracking, baseline offset, and more.

```swift
import Aizome
import SwiftUI

var container = AttributeContainer()
container.underlineStyle = .single
container.foregroundColor = .blue

let underlineStyle = AttributeContainerStringStyle(attributes: container)

Aizome.defineDefaultStyles([
    "underlineBlue": underlineStyle
])

styledString("<underlineBlue>Underlined & Blue</underlineBlue>")
```

This approach gives you the flexibility to apply any `AttributeScopes.SwiftUIAttributes` values—including advanced ones like:

- `.strikethroughStyle`
- `.tracking`
- ` .baselineOffset`
- `.fontWidth`
- `.fontDesign`

Use `AttributeContainerStringStyle` when you want precise control over how your styled segments are rendered.

## Copyright

see ./LICENSE

```
Aizome - Customizable Styled-String(AttributedString) Generator/Formatter
Copyright (c) 2025 Nobuhiro Ito
```
