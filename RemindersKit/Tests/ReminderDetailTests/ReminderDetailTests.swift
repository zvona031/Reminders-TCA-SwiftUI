import ComposableArchitecture
import ReminderDetail
import XCTest
import Domain

@MainActor
final class ReminderFormTests: XCTestCase {
    func test_details_completeTapped() async {
        let reminder = Reminder.mock
        let store = TestStore(initialState: ReminderDetailFeature.State(reminder: reminder)) {
            ReminderDetailFeature()
        }

        await store.send(.view(.completeButtonTapped)) {
            $0.reminder.isComplete.toggle()
        }

        await store.receive(\.delegate.onCompleteTapped, store.state.reminder)
    }
}
