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

        let newReminder = Reminder(id: UUID(0), title: "", note: "", isComplete: false)
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
//
//    func test_editReminder() async {
//        let reminder = Reminder(id: UUID(0),title: "Title 1", note: "Note 1", isComplete: false)
//
//        let store = TestStore(
//            initialState: AllRemindersCoordinator.State(
//                remindersList: RemindersListFeature.State(
//                    reminders: [
//                        reminder
//                    ])
//            )
//        ) {
//            AllRemindersCoordinator()
//        } withDependencies: {
//            $0.uuid = .incrementing
//        }
//
//        store.exhaustivity = .off(showSkippedAssertions: true)
//
//        await store.send(.path(.push(id: 0, state: .detail(ReminderDetailFeature.State(reminder: reminder))))) { state in
//            state.path[id: 0] = .detail(ReminderDetailFeature.State(reminder: reminder))
//        }
//
//        await store.send(.view(.editButtonTapped(reminder))) { state in
//            state.destination = .editReminder(ReminderFormFeature.State(reminder: reminder))
//        }
//
//        var editReminder = reminder
//        editReminder.title = "Edit title"
//        editReminder.note = "Edit note"
//
//        await store.send(.destination(.presented(.editReminder(.binding(.set(\.reminder, editReminder)))))) { state in
//            state.destination?.editReminder
////            state.destination?[case: \.editReminder]?.reminder = editReminder
//        }
//
//    }
}
