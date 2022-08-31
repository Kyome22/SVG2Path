# SVG2Path

```swift
let text = // String of SVG

let svg2Path = SVG2Path()
let data = svg2Path.extractPath(text: text)

// data.width := CGFloat, width of viewBox
// data.height := CGFloat, height of viewBox 
// data.paths := [Path], Path of SwiftUI
```
