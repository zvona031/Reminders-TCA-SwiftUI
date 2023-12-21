import ComposableArchitecture
import RemindersList
import ReminderDetail
import ReminderForm
import Domain

@Reducer
public struct CompletedRemindersCoordinator {

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
            case editButtonTapped(Reminder)
            case saveEditReminderTapped(Reminder)
            case cancelEditReminderTapped
        }

        public enum Delegate {
            case onCompleteTapped(Reminder)
            case onReminderChanged(Reminder)
        }

        case destination(PresentationAction<Destination.Action>)
        case path(StackAction<PathFeature.State, PathFeature.Action>)
        case remindersList(RemindersListFeature.Action)
        case view(ViewAction)
        case delegate(Delegate)
    }

    public var body: some ReducerOf<Self> {
        Scope(
          state: \.remindersList,
          action: /Action.remindersList
        ) {
          RemindersListFeature()
        }

        Reduce<State, Action> { state, action in
            switch action {
            case let .view(viewAction):
                switch viewAction {
                case let .editButtonTapped(reminder):
                    state.destination = .editReminder(ReminderFormFeature.State(reminder: reminder))
                    return .none
                case let .saveEditReminderTapped(editedReminder):
                    if state.remindersList.reminders[id: editedReminder.id] != nil {
                        state.remindersList.reminders[id: editedReminder.id] = editedReminder
                    }

                    for (id, element) in zip(state.path.ids, state.path) {
                        switch element {
                        case .detail:
                            state.path[id: id, case: \.detail]?.reminder = editedReminder
                        }
                    }

                    state.destination = nil
                    return .send(.delegate(.onReminderChanged(editedReminder)))
                case .cancelEditReminderTapped:
                    state.destination = nil
                    return .none
                }
            case let .remindersList(.delegate(.onReminderTapped(reminder))):
                state.path.append(.detail(ReminderDetailFeature.State(reminder: reminder)))
                return .none
            case let .remindersList(.delegate(.onCompleteTapped(reminder))):
                state.remindersList.reminders.remove(reminder)
                return .send(.delegate(.onCompleteTapped(reminder)))
            case .remindersList:
                return .none
            case let .path(.element(id: _, action: .detail(.delegate(.onCompleteTapped(changedReminder))))):
                if changedReminder.isComplete {
                    state.remindersList.reminders.append(changedReminder)
                } else {
                    state.remindersList.reminders.remove(changedReminder)
                }
                return .send(.delegate(.onCompleteTapped(changedReminder)))
            case .path, .destination, .delegate:
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

extension CompletedRemindersCoordinator {
    @Reducer
    public struct Destination {
        @ObservableState
        public enum State {
            case editReminder(ReminderFormFeature.State)
        }

        public enum Action {
            case editReminder(ReminderFormFeature.Action)
        }

        public var body: some ReducerOf<Self> {
            Scope(state: \.editReminder, action: \.editReminder) {
                ReminderFormFeature()
            }
        }


    }
}

extension CompletedRemindersCoordinator {
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
