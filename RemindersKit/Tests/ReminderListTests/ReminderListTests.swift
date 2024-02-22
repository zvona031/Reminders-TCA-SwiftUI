import ComposableArchitecture
import Domain
import RemindersList
import XCTest

@MainActor
final class ReminderListTests: XCTestCase {
    func test_remindersList_completeReminderTap() async {
        let reminder = Reminder(title: "Title", note: "Note", isComplete: false)
        let store = TestStore(
            initialState: RemindersListFeature.State(
                reminders: [
                    reminder
                ]
            )
        ) {
            RemindersListFeature()
        }

        await store.send(.view(.onCompleteTapped(reminder.id))) {
            $0.reminders[id: reminder.id]?.isComplete = true
        }

        await store.receive(\.delegate.onCompleteTapped)

        await store.send(.view(.onCompleteTapped(reminder.id))) {
            $0.reminders[id: reminder.id]?.isComplete = false
        }

        await store.receive(\.delegate.onCompleteTapped)
    }

    func test_remindersList_deleteReminderTap() async {
        let reminder1 = Reminder(title: "Title 1", note: "Note 1")
        let reminder2 = Reminder(title: "Title 2", note: "Note 2")
        let store = TestStore(
            initialState: RemindersListFeature.State(
                reminders: [
                    reminder1,
                    reminder2
                ]
            )
        ) {
            RemindersListFeature()
        }

        await store.send(.view(.onDeleteTapped(IndexSet(integer: 0)))) {
            $0.reminders.remove(id: reminder1.id)
        }

        await store.receive(\.delegate.onDeleteTapped)
    }
}
