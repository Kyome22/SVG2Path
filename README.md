# SVG2Path

Convert SVG to Path of SwiftUI

## Usage

```swift
let text = // String of SVG

let svg2Path = SVG2Path()
let data = svg2Path.extractPath(text: text)

// data.width := CGFloat, width of viewBox
// data.height := CGFloat, height of viewBox
// data.paths := [Path], Path of SwiftUI

data.paths.forEach { path in
    Swift.print(path.codeString()) // Output code of SwiftUI Path
}
```

## Example

```svg
<svg viewBox="0 0 280 40">
  <path d="M10.7223,33.32578s-8.33087-6.22693-1.9602-11.12744,7.46966-7.31466,6.61569-10.5361
    c-1.65447-6.24117,4.63253-8.781,7.93746-5.35877,3.31674,3.43446-.9272,6.70584,.88346,10.01426
    c3.18866,5.82627,5.14207,4.25976,8.08584,8.16665,3.01216,3.99765,1.33227,11.86664-8.4825,10.60925
    c-7.01454-.89865-3.80205-11.03237-3.80205-11.03237"/>
</svg>
```

↓↓ `Path.codeString()` ↓↓

```swift
path.move(to: CGPoint(x: 10.7223, y: 33.3258))
path.addCurve(to: CGPoint(x: 8.7621, y: 22.1983),
              control1: CGPoint(x: 10.7223, y: 33.3258),
              control2: CGPoint(x: 2.3914, y: 27.0989))
path.addCurve(to: CGPoint(x: 15.3778, y: 11.6622),
              control1: CGPoint(x: 15.1328, y: 17.2978),
              control2: CGPoint(x: 16.2318, y: 14.8837))
path.addCurve(to: CGPoint(x: 23.3152, y: 6.3035),
              control1: CGPoint(x: 13.7233, y: 5.4211),
              control2: CGPoint(x: 20.0103, y: 2.8812))
path.addCurve(to: CGPoint(x: 24.1987, y: 16.3177),
              control1: CGPoint(x: 26.6320, y: 9.7379),
              control2: CGPoint(x: 22.3880, y: 13.0093))
path.addCurve(to: CGPoint(x: 32.2845, y: 24.4844),
              control1: CGPoint(x: 27.3874, y: 22.1440),
              control2: CGPoint(x: 29.3408, y: 20.5775))
path.addCurve(to: CGPoint(x: 23.8020, y: 35.0936),
              control1: CGPoint(x: 35.2967, y: 28.4820),
              control2: CGPoint(x: 33.6168, y: 36.3510))
path.addCurve(to: CGPoint(x: 20.0000, y: 24.0613),
              control1: CGPoint(x: 16.7875, y: 34.1950),
              control2: CGPoint(x: 20.0000, y: 24.0613))
```
