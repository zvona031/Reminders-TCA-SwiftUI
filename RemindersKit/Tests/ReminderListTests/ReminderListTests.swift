import ComposableArchitecture
import Domain
import RemindersList
import XCTest
import TestHelpers

@MainActor
final class ReminderListTests: XCTestCase {
    func test_remindersList_completeReminderTap() async {
        let reminder = Reminder.mock
        let store = TestStore(initialState: RemindersListFeature.State()) {
            RemindersListFeature()
        } withDependencies: {
            $0.remindersClient.load = { [reminder] }
            $0.date.now = .mock
        }

        store.exhaustivity = .off

        await store.send(.view(.onFirstAppear))

        await store.send(.view(.onCompleteTapped(reminder.id))) {
            $0.reminders[id: reminder.id]?.completedDate = .mock
        }

        await store.receive(\.delegate.onCompleteTapped)

        await store.send(.view(.onCompleteTapped(reminder.id))) {
            $0.reminders[id: reminder.id]?.completedDate = nil
        }

        await store.receive(\.delegate.onCompleteTapped)
    }

    func test_remindersList_deleteReminderTap() async {
        let reminder1 = Reminder(title: "Title 1", note: "Note 1")
        let reminder2 = Reminder(title: "Title 2", note: "Note 2")
        let store = TestStore(initialState: RemindersListFeature.State()) {
            RemindersListFeature()
        } withDependencies: {
            $0.remindersClient.load = { [reminder1, reminder2] }
        }

        store.exhaustivity = .off

        await store.send(.view(.onFirstAppear))

        await store.send(.view(.onDeleteTapped(IndexSet(integer: 0)))) {
            $0.reminders.remove(id: reminder1.id)
        }

        await store.receive(\.delegate.onDeleteTapped)
    }

    func test_remindersList_reminderTap() async {
        let reminder1 = Reminder(title: "Title 1", note: "Note 1")
        let reminder2 = Reminder(title: "Title 2", note: "Note 2")
        let store = TestStore(initialState: RemindersListFeature.State()) {
            RemindersListFeature()
        } withDependencies: {
            $0.remindersClient.load = { [reminder1, reminder2] }
        }

        store.exhaustivity = .off

        await store.send(.view(.onFirstAppear))

        await store.send(.view(.onReminderTapped(reminder2)))

        await store.receive(\.delegate.onReminderTapped, reminder2)
    }
}
