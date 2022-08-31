import CoreGraphics

extension CGPoint {
    func output(_ n: Int = 4) -> String {
        assert(n > 0, "n must be greater than 0.")
        return String(format: "CGPoint(x: %.\(n)f, y: %.\(n)f)", x, y)
    }
}
