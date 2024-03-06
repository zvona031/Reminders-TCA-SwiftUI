import ComposableArchitecture
import RemindersList
import ReminderDetail
import ReminderForm
import Domain
import Dependencies

public enum Tab {
    case allReminders
    case completedReminders
}

@Reducer
public struct AppFeature {
    public init() {}

    @ObservableState
    public struct State {
        var selectedTab: Tab = .allReminders
        var allReminders = AllRemindersCoordinator.State()
        var completedReminders = CompletedRemindersCoordinator.State()

        public init(
            selectedTab: Tab = .allReminders,
            allReminders: AllRemindersCoordinator.State = AllRemindersCoordinator.State(),
            completedReminders: CompletedRemindersCoordinator.State = CompletedRemindersCoordinator.State()
        ) {
            self.selectedTab = selectedTab
            self.allReminders = allReminders
            self.completedReminders = completedReminders
        }
    }

    public enum Action: ViewAction, BindableAction {
        public enum ViewAction {}

        case allReminders(AllRemindersCoordinator.Action)
        case completedReminders(CompletedRemindersCoordinator.Action)
        case view(ViewAction)
        case binding(BindingAction<State>)
    }

    @Dependency(\.remindersClient.save) var saveReminders

    public var body: some ReducerOf<Self> {
        BindingReducer()
        Scope(
          state: \.allReminders,
          action: \.allReminders
        ) {
            AllRemindersCoordinator()
        }
        .onChange(of: \.allReminders.remindersList.reminders) { _, _ in
            persistRemindersReducer()
        }

        Scope(
          state: \.completedReminders,
          action: \.completedReminders
        ) {
          CompletedRemindersCoordinator()
        }

        Reduce<State, Action> { state, action in
            switch action {
            case let .allReminders(.delegate(delegateAction)):
                switch delegateAction {
                case let .onReminderChanged(reminder):
                    if state.completedReminders.remindersList.reminders[id: reminder.id] != nil {
                        state.completedReminders.remindersList.reminders[id: reminder.id] = reminder
                    }
                    return .none
                case let .onCompleteTapped(reminder):
                    if reminder.isCompleted {
                        state.completedReminders.remindersList.reminders.insert(reminder, at: 0)
                    } else {
                        state.completedReminders.remindersList.reminders.remove(reminder)
                    }
                    return .none
                case let .onDeleteTapped(ids):
                    for id in ids {
                        state.completedReminders.remindersList.reminders.remove(id: id)
                    }
                    return .none
                }
            case let .completedReminders(.delegate(delegateAction)):
                switch delegateAction {
                case let .onCompleteTapped(reminder):
                    state.allReminders.remindersList.reminders[id: reminder.id] = reminder
                    return .none
                case let .onReminderChanged(reminder):
                    state.allReminders.remindersList.reminders[id: reminder.id] = reminder
                    return .none
                case let .onDeleteTapped(ids):
                    for id in ids {
                        state.allReminders.remindersList.reminders.remove(id: id)
                    }
                    return .none
                }
            case .allReminders:
                return .none
            case .completedReminders:
                return .none
            case .binding:
                return .none
            }
        }
        .onChange(of: \.allReminders.remindersList.reminders) { _, _ in
            persistRemindersReducer()
        }
    }

    func persistRemindersReducer() -> some ReducerOf<Self> {
        Reduce { state, _ in
            .run { [reminders = state.allReminders.remindersList.reminders.elements] _ in
                try saveReminders(reminders)
            }
        }
    }
}
