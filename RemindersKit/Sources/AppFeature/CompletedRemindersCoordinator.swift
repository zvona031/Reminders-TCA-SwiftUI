import ComposableArchitecture
import RemindersList
import ReminderDetail
import ReminderForm
import Domain

@Reducer
public struct CompletedRemindersCoordinator {
    public init() {}

    @ObservableState
    public struct State: Equatable {
        @Presents public var destination: Destination.State?
        public var path = StackState<PathFeature.State>()
        public var remindersList = RemindersListFeature.State()

        public init(
            destination: Destination.State? = nil,
            path: StackState<PathFeature.State> = StackState<PathFeature.State>(),
            remindersList: RemindersListFeature.State = RemindersListFeature.State()
        ) {
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

        @CasePathable
        public enum Delegate {
            case onCompleteTapped(Reminder)
            case onReminderChanged(Reminder)
            case onDeleteTapped([Reminder.ID])
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
          action: \.remindersList
        ) {
            RemindersListFeature()
                .transformDependency(\.remindersClient) { dependency in
                    let load = dependency.load
                    dependency.load = { try load().filter { $0.isCompleted } }
                }
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
            case let .remindersList(.delegate(delegateAction)):
                switch delegateAction {
                case let .onReminderTapped(reminder):
                    state.path.append(.detail(ReminderDetailFeature.State(reminder: reminder)))
                    return .none
                case let .onCompleteTapped(reminder):
                    state.remindersList.reminders.remove(reminder)
                    return .send(.delegate(.onCompleteTapped(reminder)))
                case let .onDeleteTapped(ids):
                    return .send(.delegate(.onDeleteTapped(ids)))
                }

            case let .path(.element(id: _, action: .detail(.delegate(.onCompleteTapped(changedReminder))))):
                if changedReminder.isCompleted {
                    state.remindersList.reminders.append(changedReminder)
                } else {
                    state.remindersList.reminders.remove(changedReminder)
                }
                return .send(.delegate(.onCompleteTapped(changedReminder)))
            case .remindersList, .path, .destination, .delegate:
                return .none
            }
        }
        .forEach(\.path, action: \.path)
        .ifLet(\.$destination, action: \.destination)
    }
}

extension CompletedRemindersCoordinator {
    @Reducer(state: .equatable)
    public enum Destination {
        case editReminder(ReminderFormFeature)
    }
}

extension CompletedRemindersCoordinator {
    @Reducer(state: .equatable)
    public enum PathFeature {
        case detail(ReminderDetailFeature)
    }
}
