import ComposableArchitecture
import ReminderForm
import Domain
import XCTest


@MainActor
final class ReminderFormTests: XCTestCase {
    func test_form_changeTitle() async {
        let reminder = Reminder(title: "Title", note: "Note")
        let store = TestStore(
            initialState: ReminderFormFeature.State(reminder: reminder)) {
                ReminderFormFeature()
            }

        await store.send(.binding(.set(\.reminder.title, "Updated title"))) {
            $0.reminder.title = "Updated title"
        }
    }

    func test_form_changeNote() async {
        let reminder = Reminder(title: "Title", note: "Note")
        let store = TestStore(
            initialState: ReminderFormFeature.State(reminder: reminder)) {
                ReminderFormFeature()
            }

        await store.send(.binding(.set(\.reminder.note, "Updated note"))) {
            $0.reminder.note = "Updated note"
        }
    }
}
