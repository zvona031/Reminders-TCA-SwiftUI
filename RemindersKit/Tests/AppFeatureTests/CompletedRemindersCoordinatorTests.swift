import ComposableArchitecture
import AppFeature
import XCTest
import ReminderForm
import RemindersList
import ReminderDetail
import Domain

@MainActor
final class CompletedRemindersCoordinatorTests: XCTestCase {
    func test_edit_save() async {
        var reminder = Reminder.mock
        reminder.completedDate = .mock

        let store = TestStore(
            initialState: CompletedRemindersCoordinator.State(
                path: StackState([
                    .detail(ReminderDetailFeature.State(reminder: reminder))
                ])
            )
        ) {
            CompletedRemindersCoordinator()
        } withDependencies: {
            $0.remindersClient.load = { [reminder]}
        }

        store.exhaustivity = .off

        await store.send(.remindersList(.view(.onFirstAppear)))

        await store.send(.view(.editButtonTapped(reminder))) { state in
            state.destination = .editReminder(ReminderFormFeature.State(reminder: reminder))
        }

        var editReminder = reminder
        editReminder.title = "Edit title"
        editReminder.note = "Edit note"

        await store.send(.destination(.presented(.editReminder(.binding(.set(\.reminder, editReminder)))))) { state in
            state.destination?.modify(\.editReminder) { $0.reminder = editReminder }
        }

        await store.send(.view(.saveEditReminderTapped(editReminder))) { state in
            state.path[id: 0]?.modify(\.detail) { $0.reminder = editReminder }
            state.remindersList.reminders[id: editReminder.id] = editReminder
            state.destination = nil
        }

        await store.receive(\.delegate.onReminderChanged)
    }

    func test_edit_cancel() async {
        let reminder = Reminder.mock

        let store = TestStore(
            initialState: CompletedRemindersCoordinator.State(
                destination: .editReminder(ReminderFormFeature.State(reminder: reminder)),
                path: StackState([
                    .detail(ReminderDetailFeature.State(reminder: reminder))
                ]),
                remindersList: RemindersListFeature.State()
            )
        ) {
            CompletedRemindersCoordinator()
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

    func test_remindersList_reminderTapped() async {
        let reminder = Reminder.mock

        let store = TestStore(
            initialState: CompletedRemindersCoordinator.State(
                remindersList: RemindersListFeature.State()
            )
        ) {
            CompletedRemindersCoordinator()
        }

        await store.send(.remindersList(.delegate(.onReminderTapped(reminder)))) {
            $0.path[id: 0] = .detail(ReminderDetailFeature.State(reminder: reminder))
        }
    }

    func test_remindersList_deleteReminder() async {
        let reminder = Reminder.mock

        let store = TestStore(
            initialState: CompletedRemindersCoordinator.State()
        ) {
            CompletedRemindersCoordinator()
        }

        await store.send(.remindersList(.delegate(.onDeleteTapped([reminder.id]))))

        await store.receive(\.delegate.onDeleteTapped, [reminder.id])
    }

    func test_remindersList_completeTapped() async {
        var reminder = Reminder.mock
        reminder.completedDate = .mock

        let store = TestStore(
            initialState: CompletedRemindersCoordinator.State()
        ) {
            CompletedRemindersCoordinator()
        } withDependencies: {
            $0.remindersClient.load = { [reminder] }
            $0.date.now = .mock
        }

        store.exhaustivity = .off

        await store.send(.remindersList(.view(.onFirstAppear)))

        await store.send(.remindersList(.delegate(.onCompleteTapped(reminder)))) {
            $0.remindersList.reminders = []
        }

        await store.receive(\.delegate.onCompleteTapped)
    }

    func test_details_completeTapped() async {
        var reminder = Reminder.mock
        reminder.completedDate = .mock

        let store = TestStore(
            initialState: CompletedRemindersCoordinator.State(
                path: StackState([
                    .detail(ReminderDetailFeature.State(reminder: reminder))
                ])
            )
        ) {
            CompletedRemindersCoordinator()
        } withDependencies: {
            $0.remindersClient.load = { [reminder] }
            $0.date.now = .mock
        }

        store.exhaustivity = .off(showSkippedAssertions: true)

        await store.send(.remindersList(.view(.onFirstAppear)))

        await store.send(.path(.element(id: 0, action: .detail(.view(.completeButtonTapped))))) { state in
            state.path[id: 0, case: \.detail]?.reminder.completedDate = nil
        }

        await store.receive(\.path[id: 0].detail.delegate.onCompleteTapped) {
            $0.remindersList.reminders = []
        }

        await store.receive(\.delegate.onCompleteTapped)

        await store.send(.path(.element(id: 0, action: .detail(.view(.completeButtonTapped))))) { state in
            state.path[id: 0, case: \.detail]?.reminder.completedDate = .mock
        }

        await store.receive(\.path[id: 0].detail.delegate.onCompleteTapped) {
            $0.remindersList.reminders = [reminder]
        }

        await store.receive(\.delegate.onCompleteTapped)
    }
}
