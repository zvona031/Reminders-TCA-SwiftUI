import ComposableArchitecture
import AppFeature
import XCTest
import ReminderForm
import RemindersList
import ReminderDetail
import Domain

@MainActor
final class AllRemindersCoordinatorTests: XCTestCase {
    func test_addNewReminder() async {
        let store = TestStore(initialState: AllRemindersCoordinator.State()) {
            AllRemindersCoordinator()
        } withDependencies: {
            $0.uuid = .incrementing
        }

        let newReminder = Reminder.mock
        await store.send(.view(.addButtonTapped)) { state in
            state.destination = .addReminder(ReminderFormFeature.State(reminder: newReminder))
        }

        store.exhaustivity = .off
        var editedNewReminder = newReminder
        editedNewReminder.title = "New reminder title"
        editedNewReminder.note = "New reminder note"

        await store.send(.destination(.presented(.addReminder(.binding(.set(\.reminder, editedNewReminder))))))

        await store.send(.view(.saveAddReminderTapped)) { state in
            state.remindersList.reminders = [editedNewReminder]
            state.destination = nil
        }
    }

    func test_cancelAddReminder() async {
        let newReminder = Reminder.mock

        let store = TestStore(initialState: AllRemindersCoordinator.State(destination: .addReminder(ReminderFormFeature.State(reminder: newReminder)))) {
            AllRemindersCoordinator()
        } withDependencies: {
            $0.uuid = .incrementing
        }

        store.exhaustivity = .off

        var editedNewReminder = newReminder
        editedNewReminder.title = "New reminder title"
        editedNewReminder.note = "New reminder note"

        await store.send(.destination(.presented(.addReminder(.binding(.set(\.reminder, editedNewReminder))))))

        await store.send(.view(.cancelAddReminderTapped)) {
            $0.destination = nil
        }
    }

    func test_reminderTapped() async {
        let reminder = Reminder.mock

        let store = TestStore(
            initialState: AllRemindersCoordinator.State(
                remindersList: RemindersListFeature.State()
            )
        ) {
            AllRemindersCoordinator()
        } withDependencies: {
            $0.uuid = .incrementing
            $0.remindersClient.load = { [reminder] }
        }

        await store.send(.remindersList(.delegate(.onReminderTapped(reminder)))) {
            $0.path[id: 0] = .detail(ReminderDetailFeature.State(reminder: reminder))
        }
    }

    func test_editReminder() async {
        let reminder = Reminder.mock

        let store = TestStore(
            initialState: AllRemindersCoordinator.State(
                path: StackState([
                    .detail(ReminderDetailFeature.State(reminder: reminder))
                ]),
                remindersList: RemindersListFeature.State()
            )
        ) {
            AllRemindersCoordinator()
        } withDependencies: {
            $0.uuid = .incrementing
            $0.remindersClient.load = { [reminder] }
        }

        store.exhaustivity = .off

        await store.send(.view(.editButtonTapped(reminder))) { state in
            state.destination = .editReminder(ReminderFormFeature.State(reminder: reminder))
        }

        var editReminder = reminder
        editReminder.title = "Edit title"
        editReminder.note = "Edit note"

        await store.send(.destination(.presented(.editReminder(.binding(.set(\.reminder, editReminder)))))) { state in
            state.destination?.modify(\.editReminder) { $0.reminder = editReminder }
        }

        await store.send(.view(.saveEditReminderTapped)) { state in
            guard let editedReminder = state.destination?[case: \.editReminder]?.reminder else {
                return
            }

            state.path[id: 0]?.modify(\.detail) { $0.reminder = editedReminder }
            state.remindersList.reminders[id: editedReminder.id] = editedReminder
            state.destination = nil
        }
    }

    func test_cancelEditReminder() async {
        let reminder = Reminder.mock

        let store = TestStore(
            initialState: AllRemindersCoordinator.State(
                destination: .editReminder(ReminderFormFeature.State(reminder: reminder)),
                path: StackState([
                    .detail(ReminderDetailFeature.State(reminder: reminder))
                ]),
                remindersList: RemindersListFeature.State()
            )
        ) {
            AllRemindersCoordinator()
        } withDependencies: {
            $0.uuid = .incrementing
            $0.remindersClient.load = { [reminder] }
        }

        store.exhaustivity = .off

        var editReminder = reminder
        editReminder.title = "Edit title"
        editReminder.note = "Edit note"

        await store.send(.destination(.presented(.editReminder(.binding(.set(\.reminder, editReminder)))))) { state in
            state.destination?.modify(\.editReminder) { $0.reminder = editReminder }
        }

        await store.send(.view(.cancelEditReminderTapped)) {
            $0.destination = nil
        }
    }
}
