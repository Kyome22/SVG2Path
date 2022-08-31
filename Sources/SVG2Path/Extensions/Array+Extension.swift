extension Array {
    func chunked(by chunkSize: Int) -> [[Element]] {
        guard chunkSize > 0 else { return [[]] }
        return stride(from: 0, to: self.count, by: chunkSize).map { i in
            Array(self[i ..< Swift.min(i + chunkSize, self.count)])
        }
    }
}
