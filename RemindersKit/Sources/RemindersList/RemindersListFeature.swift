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
            case onDeleteTapped(IndexSet)
        }

        public enum Delegate {
            case onReminderTapped(Reminder)
            case onCompleteTapped(Reminder)
            case onDeleteTapped([Reminder.ID])
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
                    guard var reminder = state.reminders[id: id] else {
                        return .none
                    }
                    reminder.isComplete.toggle()
                    state.reminders[id: id] = reminder
                    return .send(.delegate(.onCompleteTapped(reminder)))
                case let .onDeleteTapped(indexSet):
                    let ids = indexSet.map { state.reminders.elements[$0].id }
                    state.reminders.remove(atOffsets: indexSet)
                    return .send(.delegate(.onDeleteTapped(ids)))
                }
            case .delegate:
                return .none
            }
        }

    }
}
