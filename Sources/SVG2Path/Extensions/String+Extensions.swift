import Foundation

typealias MatchResult = (leading: String, trailing: String, items: [String])

extension String {
    func replace(pattern: String, expect: String) -> String {
        return self.replacingOccurrences(of: pattern,
                                         with: expect,
                                         options: .regularExpression,
                                         range: self.range(of: self))
    }

    func match(pattern: String) -> MatchResult {
        let range = NSRange(location: 0, length: self.utf16.count)
        guard let regex = try? NSRegularExpression(pattern: pattern),
              let matched = regex.firstMatch(in: self, range: range)
        else { return ("", self, []) }
        let lowerIndex = self.index(self.startIndex, offsetBy: matched.range.lowerBound)
        let leading = String(self[self.startIndex ..< lowerIndex])
        let upperIndex = self.index(self.startIndex, offsetBy: matched.range.upperBound)
        let trailing = String(self[upperIndex ..< self.endIndex])
        let items = (0 ..< matched.numberOfRanges).compactMap { i -> String? in
            let r = matched.range(at: i)
            if r.location == NSNotFound { return nil }
            return NSString(string: self).substring(with: r)
        }
        return (leading, trailing, items)
    }

    func toFloat() -> Double {
        return NumberFormatter().number(from: self)?.doubleValue ?? 0
    }

    var trimmingWhitespaces: String {
        return self.trimmingCharacters(in: .whitespaces)
    }
}
