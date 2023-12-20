import ComposableArchitecture
import Foundation
import Domain

@Reducer
public struct RemindersListFeature {

    public init() {}

    @ObservableState
    public struct State {
        public var reminders: IdentifiedArrayOf<Reminder> = []

        public init(reminders: IdentifiedArrayOf<Reminder> = []) {
            self.reminders = reminders
        }
    }

    public enum Action: ViewAction {
        public enum ViewAction {
            case onReminderTapped(Reminder)
            case onCompleteTapped(Reminder.ID)
        }

        public enum Delegate {
            case onReminderTapped(Reminder)
        }

        case view(ViewAction)
        case delegate(Delegate)
    }

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case let .view(viewAction):
                switch viewAction {
                case let .onReminderTapped(reminder):
                    return .send(.delegate(.onReminderTapped(reminder)))
                case let .onCompleteTapped(id):
                    state.reminders[id: id]?.isComplete.toggle()
                    return .none
                }
            case .delegate:
                return .none
            }
        }

    }
}
