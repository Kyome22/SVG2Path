import SwiftUI

public typealias SVGPathData = (width: CGFloat, height: CGFloat, paths: [Path])

public final class SVG2Path {
    private struct TagAndPath {
        let tag: String
        let path: Path?

        init(tag: String, path: Path? = nil) {
            self.tag = tag
            self.path = path
        }
    }

    private let whiteList: [String] = [
        "<svg",
        "</svg",
        "<g",
        "</g",
        "<path",
        "<rect",
        "<circle",
        "<ellipse",
        "<line",
        "<polyline",
        "<polygon"
    ]

    // MARK: - Call Graphics Element
    private var path: Path!
    private var preP: CGPoint = .zero
    private var preCP: CGPoint? = nil

    public init() {}

    private func callClose() {
        path.closeSubpath()
        preP = .zero
        preCP = nil
    }

    private func callPoint(pX: CGFloat, pY: CGFloat, relative: Bool) -> CGPoint {
        return relative ? CGPoint(x: preP.x + pX, y: preP.y + pY) : CGPoint(x: pX, y: pY)
    }

    private func callMove(pX: CGFloat, pY: CGFloat, relative: Bool) {
        let p = callPoint(pX: pX, pY: pY, relative: relative)
        path.move(to: p)
        preP = p
        preCP = nil
    }

    private func callLine(pX: CGFloat, pY: CGFloat, relative: Bool) {
        let p = callPoint(pX: pX, pY: pY, relative: relative)
        path.addLine(to: p)
        preP = p
        preCP = nil
    }

    private func callH(pX: CGFloat, relative: Bool) {
        let pY = relative ? 0 : preP.y
        callLine(pX: pX, pY: pY, relative: relative)
    }

    private func callV(pY: CGFloat, relative: Bool) {
        let pX = relative ? 0 : preP.x
        callLine(pX: pX, pY: pY, relative: relative)
    }

    private func callCurve(
        pX: CGFloat,
        pY: CGFloat,
        c1X: CGFloat,
        c1Y: CGFloat,
        c2X: CGFloat,
        c2Y: CGFloat,
        relative: Bool
    ) {
        let p = callPoint(pX: pX, pY: pY, relative: relative)
        let c1 = callPoint(pX: c1X, pY: c1Y, relative: relative)
        let c2 = callPoint(pX: c2X, pY: c2Y, relative: relative)
        path.addCurve(to: p, control1: c1, control2: c2)
        preP = p
        preCP = c2
    }

    private func callS(
        pX: CGFloat,
        pY: CGFloat,
        c2X: CGFloat,
        c2Y: CGFloat,
        relative: Bool
    ) {
        var c1 = CGPoint(x: preP.x, y: preP.y)
        if let preCP = preCP {
            c1 = CGPoint(x: 2 * preP.x - preCP.x, y: 2 * preP.y - preCP.y)
        }
        let p = callPoint(pX: pX, pY: pY, relative: relative)
        let c2 = callPoint(pX: c2X, pY: c2Y, relative: relative)
        path.addCurve(to: p, control1: c1, control2: c2)
        preP = p
        preCP = c2
    }

    private func callQ(
        pX: CGFloat,
        pY: CGFloat,
        c1X: CGFloat,
        c1Y: CGFloat,
        relative: Bool
    ) {
        callCurve(pX: pX, pY: pY, c1X: c1X, c1Y: c1Y, c2X: c1X, c2Y: c1Y, relative: relative)
    }

    private func callT(pX: CGFloat, pY: CGFloat, relative: Bool) {
        var c1 = CGPoint(x: preP.x, y: preP.y)
        if let preCP = preCP {
            c1 = CGPoint(x: 2 * preP.x - preCP.x, y: 2 * preP.y - preCP.y)
        }
        let p = callPoint(pX: pX, pY: pY, relative: relative)
        path.addCurve(to: p, control1: c1, control2: c1)
        preP = p
        preCP = c1
    }

    private func callCommand(_ command: Command) {
        switch command.type.uppercased() {
        case "M": callMove(pX: command.points[0], pY: command.points[1],
                           relative: command.relative)
        case "Z": callClose()
        case "L": callLine(pX: command.points[0], pY: command.points[1],
                           relative: command.relative)
        case "H": callH(pX: command.points[0],
                        relative: command.relative)
        case "V": callV(pY: command.points[0],
                        relative: command.relative)
        case "C": callCurve(pX: command.points[4], pY: command.points[5],
                            c1X: command.points[0], c1Y: command.points[1],
                            c2X: command.points[2], c2Y: command.points[3],
                            relative: command.relative)
        case "S": callS(pX: command.points[2], pY: command.points[3],
                        c2X: command.points[0], c2Y: command.points[1],
                        relative: command.relative)
        case "Q": callQ(pX: command.points[2], pY: command.points[3],
                        c1X: command.points[0], c1Y: command.points[1],
                        relative: command.relative)
        case "T": callT(pX: command.points[0], pY: command.points[1],
                        relative: command.relative)
        default: break
        }
    }

    // MARK: - Convenient Getter
    private func getFloats(text: String) -> [CGFloat] {
        var code = text
        var floats = [CGFloat]()
        repeat {
            let d = code.match(pattern: #",?\s?(-?\d*\.?\d*)"#)
            if d.items.isEmpty {
                code = ""
            } else {
                code = d.trailing.trimmingWhitespaces
                floats.append(d.items[1].toFloat())
            }
        } while !code.isEmpty
        return floats
    }

    private func getPoints(text: String) -> [CGPoint] {
        return getFloats(text: text)
            .chunked(by: 2)
            .compactMap { v -> CGPoint? in
                guard v.count == 2 else { return nil }
                return CGPoint(x: v[0], y: v[1])
            }
    }

    // MARK: - Graphics Element Getter
    private func getPath(text: String) -> Path {
        preP = .zero
        preCP = .zero
        path = Path()
        var code = text
        repeat {
            let d = code.match(pattern: #"[a-zA-Z](,?\s?-?\d*\.?\d*)+"#)
            if var item = d.items.first {
                code = d.trailing
                let type = item.removeFirst()
                let chunk: Int
                switch type.uppercased() {
                case "Z":           chunk = 0
                case "H", "V":      chunk = 1
                case "M", "L", "T": chunk = 2
                case "S", "Q":      chunk = 4
                case "C":           chunk = 6
                default:            chunk = -1
                }
                if chunk < 0 { continue }
                getFloats(text: item).chunked(by: chunk).forEach { values in
                    callCommand(Command(type: type, points: values))
                }
            } else {
                code = ""
            }
        } while !code.isEmpty
        return path
    }

    private func getRect(
        x: CGFloat,
        y: CGFloat,
        width: CGFloat,
        height: CGFloat,
        rx: CGFloat,
        ry: CGFloat
    ) -> Path {
        let rect = CGRect(x: x, y: y, width: width, height: height)
        if rx == 0, ry == 0 {
            return Path(rect)
        } else {
            let size = CGSize(width: rx, height: ry)
            return Path(roundedRect: rect, cornerSize: size)
        }
    }

    private func getCircle(cx: CGFloat, cy: CGFloat, r: CGFloat) -> Path {
        return Path(ellipseIn: CGRect(x: cx - r, y: cy - r, width: 2 * r, height: 2 * r))
    }

    private func getEllipse(cx: CGFloat, cy: CGFloat, rx: CGFloat, ry: CGFloat) -> Path {
        return Path(ellipseIn: CGRect(x: cx - rx, y: cy - ry, width: 2 * rx, height: 2 * ry))
    }

    private func getLine(x1: CGFloat, y1: CGFloat, x2: CGFloat, y2: CGFloat) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: x1, y: y1))
        path.addLine(to: CGPoint(x: x2, y: y2))
        return path
    }

    private func getPolyline(points: [CGPoint]) -> Path {
        var path = Path()
        path.addLines(points)
        return path
    }

    private func getPolygon(points: [CGPoint]) -> Path {
        var path = Path()
        path.addLines(points)
        path.closeSubpath()
        return path
    }

    private func getTransform(text: String) -> CGAffineTransform? {
        let items = text.match(pattern: #"transform="([^"]+)""#).items
        if items.isEmpty { return nil }
        var code = items[1]
        var transforms = [CGAffineTransform]()
        repeat {
            // matrix
            var d = code.match(pattern: #"^\s?matrix\(([^)]+)\)"#)
            if !d.items.isEmpty {
                code = d.trailing
                let v = getFloats(text: d.items[1])
                if v.count == 6 {
                    let t = CGAffineTransform(a: v[0], b: v[1],
                                              c: v[2], d: v[3],
                                              tx: v[4], ty: v[5])
                    transforms.insert(t, at: 0)
                }
                continue
            }
            // translate
            d = code.match(pattern: #"^\s?translate\(([^)]+)\)"#)
            if !d.items.isEmpty {
                code = d.trailing
                let v = getFloats(text: d.items[1])
                if v.count == 2 {
                    transforms.insert(CGAffineTransform(translationX: v[0], y: v[1]), at: 0)
                }
                continue
            }
            // scale
            d = code.match(pattern: #"^\s?scale\(([^)]+)\)"#)
            if !d.items.isEmpty {
                code = d.trailing
                let v = getFloats(text: d.items[1])
                if v.count >= 1 {
                    let sy = (v.count == 2) ? v[1] : v[0]
                    transforms.insert(CGAffineTransform(scaleX: v[0], y: sy), at: 0)
                }
                continue
            }
            // rotate
            d = code.match(pattern: #"^\s?rotate\(([^)]+)\)"#)
            if !d.items.isEmpty {
                code = d.trailing
                let v = getFloats(text: d.items[1])
                if v.count == 1 {
                    let angle = v[0] * Double.pi / 180.0
                    transforms.insert(CGAffineTransform(rotationAngle: angle), at: 0)
                } else if v.count == 3 {
                    let angle = v[0] * Double.pi / 180.0
                    transforms.insert(CGAffineTransform(translationX: v[1], y: v[2]), at: 0)
                    transforms.insert(CGAffineTransform(rotationAngle: angle), at: 0)
                    transforms.insert(CGAffineTransform(translationX: -v[1], y: -v[2]), at: 0)
                }
                continue
            }
        } while !code.isEmpty
        if transforms.isEmpty {
            return nil
        }
        var transform = transforms.removeFirst()
        transforms.forEach { at in
            transform = transform.concatenating(at)
        }
        return transform
    }

    // MARK: - Extract Graphic Element from SVG
    private func extractPath(tag: String) -> Path? {
        let d = tag.match(pattern: #"\sd="([^"]+)""#)
        if d.items.isEmpty { return nil }
        let dText = d.items[1].replacingOccurrences(of: " ", with: "")
        var path = getPath(text: dText)
        if let transform = getTransform(text: tag) {
            path = path.applying(transform)
        }
        return path
    }

    private func extractRect(tag: String) -> Path? {
        let patterns: [String] = [
            #"x="(.+?)""#,
            #"y="(.+?)""#,
            #"width="(.+?)""#,
            #"height="(.+?)""#,
            #"rx="(.+?)""#,
            #"ry="(.+?)""#
        ]
        let v = patterns.map { pattern -> CGFloat in
            let d = tag.match(pattern: pattern)
            return d.items.isEmpty ? 0 : d.items[1].toFloat()
        }
        if v[2] == 0 || v[3] == 0 { return nil }
        var path = getRect(x: v[0], y: v[1], width: v[2], height: v[3], rx: v[4], ry: v[5])
        if let transform = getTransform(text: tag) {
            path = path.applying(transform)
        }
        return path
    }

    private func extractCircle(tag: String) -> Path? {
        let patterns: [String] = [
            #"cx="(.+?)""#,
            #"cy="(.+?)""#,
            #"r="(.+?)""#
        ]
        let v = patterns.map { pattern -> CGFloat in
            let d = tag.match(pattern: pattern)
            return d.items.isEmpty ? 0 : d.items[1].toFloat()
        }
        if v[2] == 0 { return nil }
        var path = getCircle(cx: v[0], cy: v[1], r: v[2])
        if let transform = getTransform(text: tag) {
            path = path.applying(transform)
        }
        return path
    }

    private func extractEllipse(tag: String) -> Path? {
        let patterns: [String] = [
            #"cx="(.+?)""#,
            #"cy="(.+?)""#,
            #"rx="(.+?)""#,
            #"ry="(.+?)""#
        ]
        let v = patterns.map { pattern -> CGFloat in
            let d = tag.match(pattern: pattern)
            return d.items.isEmpty ? 0 : d.items[1].toFloat()
        }
        if v[2] == 0 || v[3] == 0 { return nil }
        var path = getEllipse(cx: v[0], cy: v[1], rx: v[2], ry: v[3])
        if let transform = getTransform(text: tag) {
            path = path.applying(transform)
        }
        return path
    }

    private func extractLine(tag: String) -> Path? {
        let patterns: [String] = [
            #"x1="(.+?)""#,
            #"y1="(.+?)""#,
            #"x2="(.+?)""#,
            #"y2="(.+?)""#
        ]
        let v = patterns.map { pattern -> CGFloat in
            let d = tag.match(pattern: pattern)
            return d.items.isEmpty ? 0 : d.items[1].toFloat()
        }
        if v[0] == 0, v[1] == 0, v[2] == 0, v[3] == 0 { return nil }
        var path = getLine(x1: v[0], y1: v[1], x2: v[2], y2: v[3])
        if let transform = getTransform(text: tag) {
            path = path.applying(transform)
        }
        return path
    }

    private func extractPolyline(tag: String) -> Path? {
        let d = tag.match(pattern: #"\spoints="([^"]+)""#)
        if d.items.isEmpty { return nil }
        let v = getPoints(text: d.items[1])
        guard v.count >= 2 else { return nil }
        var path = getPolyline(points: v)
        if let transform = getTransform(text: tag) {
            path = path.applying(transform)
        }
        return path
    }

    private func extractPolygon(tag: String) -> Path? {
        let d = tag.match(pattern: #"\spoints="([^"]+)""#)
        if d.items.isEmpty { return nil }
        let v = getPoints(text: d.items[1])
        guard v.count >= 2 else { return nil }
        var path = getPolygon(points: v)
        if let transform = getTransform(text: tag) {
            path = path.applying(transform)
        }
        return path
    }

    // MARK: - Parsing SVG
    private func extractFigure(text: String) -> (trailing: String, items: [String]) {
        var code = text
        var d: MatchResult
        var array = [String]()
        repeat {
            d = code.match(pattern: #"^<[^>]*?/>"#)
            if !d.items.isEmpty {
                array.append(d.items[0])
                code = d.trailing
            }
        } while !d.items.isEmpty
        return (code, array)
    }

    private func extractGroup(text: String) -> [String] {
        var array = [String]()
        let d = text.match(pattern: #"^<g[^>]*?>"#)
        if d.items.isEmpty { // head is not <g>
            let m = extractFigure(text: d.trailing)
            array.append(contentsOf: m.items)
            let e = m.trailing.match(pattern: #"^</g>"#)
            if e.items.isEmpty { // head is not </g>
                let code = e.trailing
                if !code.isEmpty, code.hasPrefix("<"), code.contains("/>") {
                    array.append(contentsOf: extractGroup(text: code))
                }
            } else { // head is </g>
                array.append(e.items[0])
                array.append(contentsOf: extractGroup(text: e.trailing))
            }
        } else { // head is <g>
            array.append(d.items[0])
            array.append(contentsOf: extractGroup(text: d.trailing))
        }
        return array
    }

    private func extractSVG(text: String) -> (width: CGFloat, height: CGFloat, tags: [String])? {
        let code = text.replacingOccurrences(of: "\n", with: "")
            .replace(pattern: #">\s*?<"#, expect: "><")
            .trimmingWhitespaces
            .replace(pattern: #">"#, expect: ">\n")
            .components(separatedBy: .newlines)
            .filter({ str in
                return whiteList.contains(where: { str.hasPrefix($0) })
            })
            .joined()
        let d = code.match(pattern: #"<svg([^>]*?)>(.*)</svg>"#)
        if d.items.isEmpty { return nil }
        let e = d.items[1].match(pattern: #"viewBox="([^"]+)""#)
        if e.items.isEmpty { return nil }
        let v = getFloats(text: e.items[1])
        guard v.count == 4 else { return nil }
        let tags = extractGroup(text: d.items[2])
        return (v[2], v[3], tags)
    }

    public func extractPath(text: String) -> SVGPathData? {
        guard let svg = extractSVG(text: text) else { return nil }
        let isParity = svg.tags.reduce(0) { partialResult, tag in
            let u: Int = tag.hasPrefix("<g") ? 1 : (tag.hasPrefix("</g") ? -1 : 0)
            return partialResult + u
        } == 0
        guard isParity else { return nil }
        var array = svg.tags.map { tag -> TagAndPath in
            if tag.hasPrefix("<path"), let path = extractPath(tag: tag) {
                return TagAndPath(tag: tag, path: path)
            }
            if tag.hasPrefix("<rect"), let path = extractRect(tag: tag) {
                return TagAndPath(tag: tag, path: path)
            }
            if tag.hasPrefix("<circle"), let path = extractCircle(tag: tag) {
                return TagAndPath(tag: tag, path: path)
            }
            if tag.hasPrefix("<ellipse"), let path = extractEllipse(tag: tag) {
                return TagAndPath(tag: tag, path: path)
            }
            if tag.hasPrefix("<line"), let path = extractLine(tag: tag) {
                return TagAndPath(tag: tag, path: path)
            }
            if tag.hasPrefix("<polyline"), let path = extractPolyline(tag: tag) {
                return TagAndPath(tag: tag, path: path)
            }
            if tag.hasPrefix("<polygon"), let path = extractPolygon(tag: tag) {
                return TagAndPath(tag: tag, path: path)
            }
            return TagAndPath(tag: tag)
        }
        repeat {
            var s: Int = 0
            var e: Int = 0
            for i in (0 ..< array.count) {
                if array[i].tag.hasPrefix("<g") {
                    s = i
                } else if array[i].tag.hasPrefix("</g") {
                    e = i
                }
                guard e > 0 else { continue }
                let groupTag = array.remove(at: s)
                var path = (s ..< e).map({ _ in array.remove(at: s) })
                    .compactMap({ $0.path })
                    .reduce(into: Path(), { partialResult, path in
                        partialResult.addPath(path)
                    })
                if let transform = getTransform(text: groupTag.tag) {
                    path = path.applying(transform)
                }
                array.insert(TagAndPath(tag: "grouped-path", path: path), at: s)
                break
            }
        } while array.contains(where: { $0.tag.hasPrefix("<g") })
        let paths = array.compactMap { $0.path }
        return (svg.width, svg.height, paths)
    }
}
