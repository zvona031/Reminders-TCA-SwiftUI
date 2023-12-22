import ComposableArchitecture
import RemindersList
import ReminderDetail
import ReminderForm
import Domain

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

        public init(selectedTab: Tab = .allReminders,
             allReminders: AllRemindersCoordinator.State = AllRemindersCoordinator.State(),
             completedReminders: CompletedRemindersCoordinator.State = CompletedRemindersCoordinator.State()) {
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

    public var body: some ReducerOf<Self> {
        BindingReducer()
        Scope(
          state: \.allReminders,
          action: \.allReminders
        ) {
            AllRemindersCoordinator()
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
                    if reminder.isComplete {
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

            case .allReminders:
                return .none
            case let .completedReminders(.delegate(.onReminderChanged(reminder))):
                state.allReminders.remindersList.reminders[id: reminder.id] = reminder
                return .none
            case let .completedReminders(.delegate(.onCompleteTapped(reminder))):
                state.allReminders.remindersList.reminders[id: reminder.id] = reminder
                return .none
            case .completedReminders:
                return .none
            case .binding:
                return .none
            }
        }
    }
}
