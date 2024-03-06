import ComposableArchitecture
import Domain
import Dependencies

@Reducer
public struct ReminderFormFeature {
    public init() {}

    @ObservableState
    public struct State: Equatable {
        public var reminder: Reminder

        public init(reminder: Reminder) {
            self.reminder = reminder
        }

        public var isAddDisabled: Bool {
            reminder.title.isEmpty
        }
    }

    public enum Action: BindableAction, ViewAction {
        case binding(BindingAction<State>)
        case view(View)

        public enum View {
            case dateToggleTapped(Bool)
        }
    }

    @Dependency(\.date) var date

    public var body: some ReducerOf<Self> {
        BindingReducer()
            .onChange(of: \.reminder.earlyReminderType) { _, newValue in
                Reduce { state, _ in
                    if let reminderTrigger = newValue.predefined {
                        state.reminder.earlyReminderTrigger = reminderTrigger
                    } else if newValue.is(\.custom) {
                        state.reminder.earlyReminderTrigger = .defaultValue
                    } else {
                        state.reminder.earlyReminderTrigger = nil
                    }
                    return .none
                }
            }
        Reduce { state, action in
            switch action {
            case .view(let viewAction):
                switch viewAction {
                case .dateToggleTapped(let isOn):
                    state.reminder.date = isOn ? date() : nil
                    state.reminder.earlyReminderType = .none
                    state.reminder.earlyReminderTrigger = nil
                    return .none
                }
            case .binding:
                return .none
            }
        }
    }
}
