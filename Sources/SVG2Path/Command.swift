import Foundation

struct Command {
    let type: Character
    let points: [CGFloat]
    let relative: Bool

    init(type: Character, points: [CGFloat]) {
        self.type = type
        self.points = points
        self.relative = type.isLowercase
    }
}
