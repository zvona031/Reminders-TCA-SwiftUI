import ComposableArchitecture
import Domain

@Reducer
public struct ReminderDetailFeature {
    public init() {}

    @ObservableState
    public struct State: Equatable {
        public var reminder: Reminder

        public init(reminder: Reminder) {
            self.reminder = reminder
        }
    }

    public enum Action: ViewAction {
        public enum ViewAction {
            case completeButtonTapped
        }

        public enum Delegate {
            case onCompleteTapped(Reminder)
        }

        case view(ViewAction)
        case delegate(Delegate)
    }

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case let .view(viewAction):
                switch viewAction {
                case .completeButtonTapped:
                    state.reminder.isComplete.toggle()
                    return .send(.delegate(.onCompleteTapped(state.reminder)))
                }
            case .delegate:
                return .none
            }
        }
    }
}
