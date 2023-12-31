import ComposableArchitecture
import RemindersList
import ReminderDetail
import ReminderForm
import Domain

@Reducer
public struct AppFeature {

    public init() {}

    @ObservableState
    public struct State {
        @Presents var destination: Destination.State? = nil
        var path = StackState<PathFeature.State>()
        var remindersList = RemindersListFeature.State()

        public init(destination: Destination.State? = nil,
             path: StackState<PathFeature.State> = StackState<PathFeature.State>(),
             remindersList: RemindersListFeature.State = RemindersListFeature.State()) {
            self.destination = destination
            self.path = path
            self.remindersList = remindersList
        }
    }

    public enum Action: ViewAction {
        public enum ViewAction {
            case addButtonTapped
            case saveAddReminderTapped(Reminder)
            case cancelAddReminderTapped
            case editButtonTapped(Reminder)
            case saveEditReminderTapped(Reminder)
            case cancelEditReminderTapped
        }

        case destination(PresentationAction<Destination.Action>)
        case path(StackAction<PathFeature.State, PathFeature.Action>)
        case remindersList(RemindersListFeature.Action)
        case view(ViewAction)
    }

    public var body: some ReducerOf<Self> {
        Scope(
          state: \.remindersList,
          action: /Action.remindersList
        ) {
          RemindersListFeature()
        }

        Reduce { state, action in
            switch action {
            case let .view(viewAction):
                switch viewAction {
                case .addButtonTapped:
                    @Dependency(\.uuid) var uuid
                    let newReminder = Reminder(id: uuid(), title: "", note: "")
                    state.destination = .addReminder(ReminderFormFeature.State(reminder: newReminder))
                    return .none
                case let .saveAddReminderTapped(newReminder):
                    state.remindersList.reminders.append(newReminder)
                    state.destination = nil
                    return .none
                case .cancelAddReminderTapped:
                    state.destination = nil
                    return .none
                case let .editButtonTapped(reminder):
                    state.destination = .editReminder(ReminderFormFeature.State(reminder: reminder))
                    return .none
                case let .saveEditReminderTapped(editedReminder):
                    state.remindersList.reminders[id: editedReminder.id] = editedReminder

                    for (id, element) in zip(state.path.ids, state.path) {
                        switch element {
                        case .detail:
                            state.path[id: id, case: \.detail]?.reminder = editedReminder
                        }
                    }

                    state.destination = nil
                    return .none
                case .cancelEditReminderTapped:
                    state.destination = nil
                    return .none
                }
            case let .remindersList(.delegate(.onReminderTapped(reminder))):
                state.path.append(.detail(ReminderDetailFeature.State(reminder: reminder)))
                return .none
            case .remindersList:
                return .none
            case let .path(.element(id: _, action: .detail(.delegate(.reminderChanged(changedReminder))))):
                state.remindersList.reminders[id: changedReminder.id] = changedReminder
                return .none
            case .path:
                return .none
            case .destination:
                return .none
            }
        }
        .forEach(\.path, action: \.path) {
            PathFeature()
          }
        .ifLet(\.$destination, action: \.destination) {
            Destination()
        }
    }
}

extension AppFeature {
    @Reducer
    public struct Destination {
        @ObservableState
        public enum State {
            case editReminder(ReminderFormFeature.State)
            case addReminder(ReminderFormFeature.State)
        }

        public enum Action {
            case editReminder(ReminderFormFeature.Action)
            case addReminder(ReminderFormFeature.Action)
        }

        public var body: some ReducerOf<Self> {
            Scope(state: \.editReminder, action: \.editReminder) {
                ReminderFormFeature()
            }
            Scope(state: \.addReminder, action: \.addReminder) {
                ReminderFormFeature()
            }
        }


    }
}

extension AppFeature {
    @Reducer
    public struct PathFeature {

        public init() {}

        @ObservableState
        public enum State {
            case detail(ReminderDetailFeature.State)
        }

        public enum Action {
            case detail(ReminderDetailFeature.Action)
        }

        public var body: some ReducerOf<Self> {
            Scope(state: \.detail, action: \.detail) {
                ReminderDetailFeature()
            }
        }
    }
}
