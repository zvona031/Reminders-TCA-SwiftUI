import Foundation
import Dependencies

public struct Reminder: Identifiable, Equatable, Codable {
    public let id: UUID
    public var title: String
    public var note: String
    public var date: Date?
    public var isComplete: Bool

    public init(
        id: UUID = UUID(),
        title: String,
        note: String,
        date: Date? = nil,
        isComplete: Bool = false
    ) {
        self.id = id
        self.title = title
        self.note = note
        self.date = date
        self.isComplete = isComplete
    }
}

public extension Reminder {
    static let mock = Reminder(id: UUID(0), title: "", note: "")
    static let mock1 = Reminder(id: UUID(1), title: "Title 1", note: "Note 1")
}
