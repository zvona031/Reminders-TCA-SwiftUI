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

        XCTAssertTrue(store.state.isAddDisabled)

        await store.send(.binding(.set(\.reminder.title, "Updated title"))) {
            $0.reminder.title = "Updated title"
        }

        XCTAssertFalse(store.state.isAddDisabled)
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

    func test_form_earlyReminderTypeSet_predefined() async {
        let reminder = Reminder(title: "Title", note: "Note", date: .mock)
        let store = TestStore(initialState: ReminderFormFeature.State(reminder: reminder)) {
            ReminderFormFeature()
        }

        await store.send(.binding(.set(\.reminder.earlyReminderType, .predefined(.defaultValue)))) {
            $0.reminder.earlyReminderType = .predefined(.defaultValue)
            $0.reminder.earlyReminderTrigger = .defaultValue
        }
    }

    func test_form_earlyReminderTypeSet_custom() async {
        let reminder = Reminder(title: "Title", note: "Note", date: .mock)
        let store = TestStore(initialState: ReminderFormFeature.State(reminder: reminder)) {
            ReminderFormFeature()
        }

        await store.send(.binding(.set(\.reminder.earlyReminderType, .custom))) {
            $0.reminder.earlyReminderType = .custom
            $0.reminder.earlyReminderTrigger = .defaultValue
        }
    }

    func test_form_earlyReminderTypeSet_none() async {
        let reminder = Reminder(title: "Title", note: "Note", date: .mock, earlyReminderTrigger: .defaultValue)
        let store = TestStore(initialState: ReminderFormFeature.State(reminder: reminder)) {
            ReminderFormFeature()
        }

        await store.send(.binding(.set(\.reminder.earlyReminderType, .none))) {
            $0.reminder.earlyReminderType = .none
            $0.reminder.earlyReminderTrigger = nil
        }
    }
}
