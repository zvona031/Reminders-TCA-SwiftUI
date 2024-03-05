import Foundation
import Dependencies
import Domain

struct FileRemindersClient {
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder
    private let url: URL
    @Dependency(\.dataManager) private var dataManager

    init(encoder: JSONEncoder, decoder: JSONDecoder, url: URL) {
        self.encoder = encoder
        self.decoder = decoder
        self.url = url
    }

    func save(_ reminders: [Reminder]) throws {
        let data = try encoder.encode(reminders)
        try dataManager.save(data: data, url: url)
    }

    func load() throws -> [Reminder] {
        let data = try dataManager.load(url: url)
        let reminders = try? decoder.decode([Reminder].self, from: data)
        return reminders ?? []
    }
}

struct CompletedRemindersClient {
    private let remindersClient: RemindersClient
}
