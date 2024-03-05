import Foundation

public struct ReminderTrigger: Codable, Hashable {
    public var time: UInt
    public var unit: TimeUnit

    public init(time: UInt, unit: TimeUnit) {
        self.time = time
        self.unit = unit
    }
}

extension ReminderTrigger {
    public static let defaultValue = ReminderTrigger(time: 1, unit: .hour)
}
