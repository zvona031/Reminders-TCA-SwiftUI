import Foundation
import Dependencies

public struct Reminder: Identifiable, Equatable, Codable {
    public let id: UUID
    public var title: String
    public var note: String
    public var date: Date?
    public var completedDate: Date?

    public init(
        id: UUID = UUID(),
        title: String,
        note: String,
        date: Date? = nil,
        completedDate: Date? = nil
    ) {
        self.id = id
        self.title = title
        self.note = note
        self.date = date
        self.completedDate = completedDate
    }
}

public extension Reminder {
    var isCompleted: Bool {
        completedDate != nil
    }
}

public extension Reminder {
    static let mock = Reminder(id: UUID(0), title: "", note: "")
    static let mock1 = Reminder(id: UUID(1), title: "Title 1", note: "Note 1")
}
