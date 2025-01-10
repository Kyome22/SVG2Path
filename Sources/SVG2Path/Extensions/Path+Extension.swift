import SwiftUI

public extension Path {
    func codeString(n: Int = 4) -> String {
        var texts = [String]()
        cgPath.applyWithBlock { element in
            switch element.pointee.type {
            case CGPathElementType.moveToPoint:
                texts.append("path.move(to: \(element.pointee.points[0].output(n)))")
            case CGPathElementType.addLineToPoint:
                texts.append("path.addLine(to: \(element.pointee.points[0].output(n)))")
            case CGPathElementType.addCurveToPoint:
                texts.append("path.addCurve(to: \(element.pointee.points[2].output(n)),")
                texts.append("              control1: \(element.pointee.points[0].output(n)),")
                texts.append("              control2: \(element.pointee.points[1].output(n)))")
            case CGPathElementType.addQuadCurveToPoint:
                texts.append("path.addCurve(to: \(element.pointee.points[1].output(n)),")
                texts.append("              control1: \(element.pointee.points[0].output(n)),")
                texts.append("              control2: \(element.pointee.points[0].output(n)))")
            case CGPathElementType.closeSubpath:
                texts.append("path.closeSubpath()")
            @unknown default:
                fatalError()
            }
        }
        return texts.joined(separator: "\n")
    }
}
