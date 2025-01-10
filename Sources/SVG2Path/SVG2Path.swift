import SwiftUI

public typealias SVGPathData = (size: CGSize, paths: [Path])

public struct SVG2Path {
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

    public init() {}

    // MARK: - Call Graphics Element
    private func callClose(_ state: inout State) {
        state.path.closeSubpath()
        state.preCP = .zero
        state.preCP = nil
    }

    private func callPoint(_ state: State, pX: CGFloat, pY: CGFloat, relative: Bool) -> CGPoint {
        if relative {
            CGPoint(x: state.preP.x + pX, y: state.preP.y + pY)
        } else {
            CGPoint(x: pX, y: pY)
        }
    }

    private func callMove(_ state: inout State, pX: CGFloat, pY: CGFloat, relative: Bool) {
        let p = callPoint(state, pX: pX, pY: pY, relative: relative)
        state.path.move(to: p)
        state.preP = p
        state.preCP = nil
    }

    private func callLine(_ state: inout State, pX: CGFloat, pY: CGFloat, relative: Bool) {
        let p = callPoint(state, pX: pX, pY: pY, relative: relative)
        state.path.addLine(to: p)
        state.preP = p
        state.preCP = nil
    }

    private func callH(_ state: inout State, pX: CGFloat, relative: Bool) {
        let pY = relative ? .zero : state.preP.y
        callLine(&state, pX: pX, pY: pY, relative: relative)
    }

    private func callV(_ state: inout State, pY: CGFloat, relative: Bool) {
        let pX = relative ? .zero : state.preP.x
        callLine(&state, pX: pX, pY: pY, relative: relative)
    }

    private func callCurve(
        _ state: inout State,
        pX: CGFloat,
        pY: CGFloat,
        c1X: CGFloat,
        c1Y: CGFloat,
        c2X: CGFloat,
        c2Y: CGFloat,
        relative: Bool
    ) {
        let p = callPoint(state, pX: pX, pY: pY, relative: relative)
        let c1 = callPoint(state, pX: c1X, pY: c1Y, relative: relative)
        let c2 = callPoint(state, pX: c2X, pY: c2Y, relative: relative)
        state.path.addCurve(to: p, control1: c1, control2: c2)
        state.preP = p
        state.preCP = c2
    }

    private func callS(
        _ state: inout State,
        pX: CGFloat,
        pY: CGFloat,
        c2X: CGFloat,
        c2Y: CGFloat,
        relative: Bool
    ) {
        var c1 = CGPoint(x: state.preP.x, y: state.preP.y)
        if let preCP = state.preCP {
            c1 = CGPoint(x: 2 * state.preP.x - preCP.x, y: 2 * state.preP.y - preCP.y)
        }
        let p = callPoint(state, pX: pX, pY: pY, relative: relative)
        let c2 = callPoint(state, pX: c2X, pY: c2Y, relative: relative)
        state.path.addCurve(to: p, control1: c1, control2: c2)
        state.preP = p
        state.preCP = c2
    }

    private func callQ(
        _ state: inout State,
        pX: CGFloat,
        pY: CGFloat,
        c1X: CGFloat,
        c1Y: CGFloat,
        relative: Bool
    ) {
        callCurve(&state, pX: pX, pY: pY, c1X: c1X, c1Y: c1Y, c2X: c1X, c2Y: c1Y, relative: relative)
    }

    private func callT(_ state: inout State, pX: CGFloat, pY: CGFloat, relative: Bool) {
        var c1 = CGPoint(x: state.preP.x, y: state.preP.y)
        if let preCP = state.preCP {
            c1 = CGPoint(x: 2 * state.preP.x - preCP.x, y: 2 * state.preP.y - preCP.y)
        }
        let p = callPoint(state, pX: pX, pY: pY, relative: relative)
        state.path.addCurve(to: p, control1: c1, control2: c1)
        state.preP = p
        state.preCP = c1
    }

    private func callCommand(_ state: inout State, with command: Command) {
        switch command.type.uppercased() {
        case "M":
            callMove(
                &state,
                pX: command.points[0],
                pY: command.points[1],
                relative: command.relative
            )
        case "Z":
            callClose(&state)
        case "L":
            callLine(
                &state,
                pX: command.points[0],
                pY: command.points[1],
                relative: command.relative
            )
        case "H":
            callH(
                &state,
                pX: command.points[0],
                relative: command.relative
            )
        case "V":
            callV(
                &state,
                pY: command.points[0],
                relative: command.relative
            )
        case "C":
            callCurve(
                &state,
                pX: command.points[4],
                pY: command.points[5],
                c1X: command.points[0],
                c1Y: command.points[1],
                c2X: command.points[2],
                c2Y: command.points[3],
                relative: command.relative
            )
        case "S":
            callS(
                &state,
                pX: command.points[2],
                pY: command.points[3],
                c2X: command.points[0],
                c2Y: command.points[1],
                relative: command.relative
            )
        case "Q":
            callQ(
                &state,
                pX: command.points[2],
                pY: command.points[3],
                c1X: command.points[0],
                c1Y: command.points[1],
                relative: command.relative
            )
        case "T":
            callT(
                &state,
                pX: command.points[0],
                pY: command.points[1],
                relative: command.relative
            )
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
        getFloats(text: text)
            .chunked(by: 2)
            .compactMap { v -> CGPoint? in
                guard v.count == 2 else { return nil }
                return CGPoint(x: v[0], y: v[1])
            }
    }

    // MARK: - Graphics Element Getter
    private func getPath(text: String) -> Path {
        var state = State()
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
                if chunk < .zero { continue }
                getFloats(text: item).chunked(by: chunk).forEach { values in
                    callCommand(&state, with: Command(type: type, points: values))
                }
            } else {
                code = ""
            }
        } while !code.isEmpty
        return state.path
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
        if rx == .zero, ry == .zero {
            return Path(rect)
        } else {
            let size = CGSize(width: rx, height: ry)
            return Path(roundedRect: rect, cornerSize: size)
        }
    }

    private func getCircle(cx: CGFloat, cy: CGFloat, r: CGFloat) -> Path {
        Path(ellipseIn: CGRect(x: cx - r, y: cy - r, width: 2 * r, height: 2 * r))
    }

    private func getEllipse(cx: CGFloat, cy: CGFloat, rx: CGFloat, ry: CGFloat) -> Path {
        Path(ellipseIn: CGRect(x: cx - rx, y: cy - ry, width: 2 * rx, height: 2 * ry))
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
        guard !items.isEmpty else { return nil }
        var code = items[1]
        var transforms = [CGAffineTransform]()
        repeat {
            // matrix
            var d = code.match(pattern: #"^\s?matrix\(([^)]+)\)"#)
            if !d.items.isEmpty {
                code = d.trailing
                let v = getFloats(text: d.items[1])
                if v.count == 6 {
                    transforms.insert(CGAffineTransform(a: v[0], b: v[1], c: v[2], d: v[3], tx: v[4], ty: v[5]), at: 0)
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
        guard !transforms.isEmpty else { return nil }
        let transform = transforms.removeFirst()
        return transforms.reduce(into: transform) { $0 = $0.concatenating($1) }
    }

    // MARK: - Extract Graphic Element from SVG
    private func extractPath(tag: String) -> Path? {
        let d = tag.match(pattern: #"\sd="([^"]+)""#)
        guard !d.items.isEmpty else { return nil }
        let dText = d.items[1]
            .replacingOccurrences(of: #" +([a-zA-Z])"#, with: "$1", options: .regularExpression)
            .replacingOccurrences(of: " ", with: ",")
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
            return d.items.isEmpty ? .zero : d.items[1].toFloat()
        }
        guard v[2] != .zero && v[3] != .zero else { return nil }
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
            return d.items.isEmpty ? .zero : d.items[1].toFloat()
        }
        guard v[2] != .zero else { return nil }
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
            return d.items.isEmpty ? .zero : d.items[1].toFloat()
        }
        guard v[2] != .zero && v[3] != .zero else { return nil }
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
            return d.items.isEmpty ? .zero : d.items[1].toFloat()
        }
        guard v[0] != v[2] || v[1] != v[3] else { return nil }
        var path = getLine(x1: v[0], y1: v[1], x2: v[2], y2: v[3])
        if let transform = getTransform(text: tag) {
            path = path.applying(transform)
        }
        return path
    }

    private func extractPolyline(tag: String) -> Path? {
        let d = tag.match(pattern: #"\spoints="([^"]+)""#)
        guard !d.items.isEmpty else { return nil }
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
            .filter { str in whiteList.contains { str.hasPrefix($0) } }
            .joined()
        let d = code.match(pattern: #"<svg([^>]*?)>(.*)</svg>"#)
        guard !d.items.isEmpty else { return nil }
        let e = d.items[1].match(pattern: #"viewBox="([^"]+)""#)
        guard !e.items.isEmpty else { return nil }
        let v = getFloats(text: e.items[1])
        guard v.count == 4 else { return nil }
        let tags = extractGroup(text: d.items[2])
        return (v[2], v[3], tags)
    }

    public func extractPath(text: String) -> SVGPathData? {
        guard let svg = extractSVG(text: text) else { return nil }
        let isParity = svg.tags.reduce(into: Int.zero) { partialResult, tag in
            partialResult += tag.hasPrefix("<g") ? 1 : (tag.hasPrefix("</g") ? -1 : 0)
        } == .zero
        guard isParity else { return nil }
        var array = svg.tags.map { tag -> TagAndPath in
            if tag.hasPrefix("<path"), let path = extractPath(tag: tag) {
                TagAndPath(tag: tag, path: path)
            } else if tag.hasPrefix("<rect"), let path = extractRect(tag: tag) {
                TagAndPath(tag: tag, path: path)
            } else if tag.hasPrefix("<circle"), let path = extractCircle(tag: tag) {
                TagAndPath(tag: tag, path: path)
            } else if tag.hasPrefix("<ellipse"), let path = extractEllipse(tag: tag) {
                TagAndPath(tag: tag, path: path)
            } else if tag.hasPrefix("<line"), let path = extractLine(tag: tag) {
                TagAndPath(tag: tag, path: path)
            } else if tag.hasPrefix("<polyline"), let path = extractPolyline(tag: tag) {
                TagAndPath(tag: tag, path: path)
            } else if tag.hasPrefix("<polygon"), let path = extractPolygon(tag: tag) {
                TagAndPath(tag: tag, path: path)
            } else {
                TagAndPath(tag: tag)
            }
        }
        repeat {
            var s = Int.zero
            var e = Int.zero
            for i in (.zero ..< array.count) {
                if array[i].tag.hasPrefix("<g") {
                    s = i
                } else if array[i].tag.hasPrefix("</g") {
                    e = i
                }
                guard e > .zero else { continue }
                let groupTag = array.remove(at: s)
                var path = (s ..< e)
                    .map { _ in array.remove(at: s) }
                    .compactMap(\.path)
                    .reduce(into: Path()) { partialResult, path in
                        partialResult.addPath(path)
                    }
                if let transform = getTransform(text: groupTag.tag) {
                    path = path.applying(transform)
                }
                array.insert(TagAndPath(tag: "grouped-path", path: path), at: s)
                break
            }
        } while array.contains { $0.tag.hasPrefix("<g") }
        let size = CGSize(width: svg.width, height: svg.height)
        let paths = array.compactMap(\.path)
        return (size, paths)
    }
}
