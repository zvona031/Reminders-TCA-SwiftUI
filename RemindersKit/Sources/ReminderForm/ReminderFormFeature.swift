import ComposableArchitecture
import Domain

@Reducer
public struct ReminderFormFeature {

    public init() {}

    @ObservableState
    public struct State: Equatable {
        public var reminder: Reminder

        public init(reminder: Reminder) {
            self.reminder = reminder
        }
    }

    public enum Action: BindableAction {
        case binding(BindingAction<State>)
    }

    public var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            return .none
        }
    }
}
