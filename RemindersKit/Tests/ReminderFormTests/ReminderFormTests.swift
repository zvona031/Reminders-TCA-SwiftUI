import ComposableArchitecture
import ReminderForm
import Domain
import XCTest
import TestHelpers

@MainActor
final class ReminderFormTests: XCTestCase {
    func test_form_changeTitle() async {
        let store = TestStore(initialState: ReminderFormFeature.State(reminder: .mock)) {
            ReminderFormFeature()
        }

        await store.send(.binding(.set(\.reminder.title, "Updated title"))) {
            $0.reminder.title = "Updated title"
        }
    }

    func test_form_changeNote() async {
        let store = TestStore(initialState: ReminderFormFeature.State(reminder: .mock)) {
            ReminderFormFeature()
        }

        await store.send(.binding(.set(\.reminder.note, "Updated note"))) {
            $0.reminder.note = "Updated note"
        }
    }

    func test_form_dateToggleOn() async {
        let store = TestStore(initialState: ReminderFormFeature.State(reminder: .mock)) {
            ReminderFormFeature()
        } withDependencies: {
            $0.date.now = .mock
        }

        await store.send(.view(.dateToggleTapped(true))) {
            $0.reminder.date = .mock
        }
    }

    func test_form_dateToggleOff() async {
        let reminder = Reminder(title: "Title", note: "Note", date: .mock)
        let store = TestStore(initialState: ReminderFormFeature.State(reminder: reminder)) {
            ReminderFormFeature()
        }

        await store.send(.view(.dateToggleTapped(false))) {
            $0.reminder.date = nil
        }
    }
}
