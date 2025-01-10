import SwiftUI

struct TagAndPath {
    let tag: String
    let path: Path?

    init(tag: String, path: Path? = nil) {
        self.tag = tag
        self.path = path
    }
}
