import Foundation

public enum TimeUnit: String, Codable, CaseIterable {
    case minute
    case hour
    case day
    case week
    case month
}

public extension TimeUnit {
    static let range: ClosedRange<UInt> = 1...200
}
