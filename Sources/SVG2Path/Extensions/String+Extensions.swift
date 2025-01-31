import Foundation

typealias MatchResult = (leading: String, trailing: String, items: [String])

extension String {
    func replace(pattern: String, expect: String) -> String {
        replacingOccurrences(of: pattern, with: expect, options: .regularExpression, range: range(of: self))
    }

    func match(pattern: String) -> MatchResult {
        let range = NSRange(location: 0, length: utf16.count)
        guard let regex = try? NSRegularExpression(pattern: pattern),
              let matched = regex.firstMatch(in: self, range: range) else {
            return ("", self, [])
        }
        let lowerIndex = index(startIndex, offsetBy: matched.range.lowerBound)
        let leading = String(self[startIndex ..< lowerIndex])
        let upperIndex = index(startIndex, offsetBy: matched.range.upperBound)
        let trailing = String(self[upperIndex ..< endIndex])
        let items = (0 ..< matched.numberOfRanges).compactMap { i -> String? in
            let r = matched.range(at: i)
            guard r.location != NSNotFound else { return nil }
            return NSString(string: self).substring(with: r)
        }
        return (leading, trailing, items)
    }

    func toFloat() -> Double {
        NumberFormatter().number(from: self)?.doubleValue ?? 0
    }

    var trimmingWhitespaces: String {
        trimmingCharacters(in: .whitespaces)
    }
}
