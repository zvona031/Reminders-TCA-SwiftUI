import DependenciesMacros
import Dependencies
import Domain
import Foundation

@DependencyClient
public struct RemindersClient {
    public var load: () throws -> [Reminder]
    public var save: ([Reminder]) throws -> Void
}

extension RemindersClient: DependencyKey {
    public static var liveValue: RemindersClient {
        let fileRemindersClient = FileRemindersClient(encoder: JSONEncoder(), decoder: JSONDecoder(), url: .reminders)
        return RemindersClient(
            load: fileRemindersClient.load,
            save: fileRemindersClient.save
        )
    }

    public static var completedRemindersValue: RemindersClient {
        let client: RemindersClient = .liveValue

        return RemindersClient(load: {
            try client.load().filter { $0.isComplete }
        }, save: client.save)
    }
}

extension DependencyValues {
    public var remindersClient: RemindersClient {
        get { self[RemindersClient.self] }
        set { self[RemindersClient.self] = newValue}
    }
}

private extension URL {
    static let reminders = Self.documentsDirectory.appending(component: "reminders.json")
}
