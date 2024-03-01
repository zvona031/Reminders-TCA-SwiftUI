import ComposableArchitecture
import ReminderDetail
import XCTest
import Domain
import TestHelpers

@MainActor
final class ReminderDetailsTests: XCTestCase {
    func test_details_completeTapped_setToTrue() async {
        let reminder = Reminder.mock
        let store = TestStore(initialState: ReminderDetailFeature.State(reminder: reminder)) {
            ReminderDetailFeature()
        } withDependencies: {
            $0.date.now = .mock
        }

        await store.send(.view(.completeButtonTapped)) {
            $0.reminder.completedDate = .mock
        }

        await store.receive(\.delegate.onCompleteTapped, store.state.reminder)
    }

    func test_details_completeTapped_setToFalse() async {
        var reminder = Reminder.mock
        reminder.completedDate = .mock
        let store = TestStore(initialState: ReminderDetailFeature.State(reminder: reminder)) {
            ReminderDetailFeature()
        }

        await store.send(.view(.completeButtonTapped)) {
            $0.reminder.completedDate = nil
        }

        await store.receive(\.delegate.onCompleteTapped, store.state.reminder)
    }

}
