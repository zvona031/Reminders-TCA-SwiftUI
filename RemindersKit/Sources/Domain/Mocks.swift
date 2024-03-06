import Foundation

public extension Date {
    static let mock = Date(timeIntervalSinceReferenceDate: 1_234_567_890)
}

public extension Reminder {
    static let mock = Reminder(id: UUID(0), title: "", note: "")
    static let mock1 = Reminder(id: UUID(1), title: "Title 1", note: "Note 1")
}
