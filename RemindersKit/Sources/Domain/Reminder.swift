import Foundation

public struct Reminder: Identifiable, Equatable {
    public let id: UUID
    public var title: String
    public var note: String
    public var isComplete: Bool

    public init(id: UUID, title: String, note: String, isComplete: Bool = false) {
        self.id = id
        self.title = title
        self.note = note
        self.isComplete = isComplete
    }
}
