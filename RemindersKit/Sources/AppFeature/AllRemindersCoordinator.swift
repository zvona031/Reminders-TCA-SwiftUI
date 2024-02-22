import ComposableArchitecture
import RemindersList
import ReminderDetail
import ReminderForm
import Domain
import Foundation

@Reducer
public struct AllRemindersCoordinator {
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
            case addButtonTapped
            case saveAddReminderTapped
            case cancelAddReminderTapped
            case editButtonTapped(Reminder)
            case saveEditReminderTapped
            case cancelEditReminderTapped
        }

        @CasePathable
        public enum Delegate {
            case onReminderChanged(Reminder)
            case onCompleteTapped(Reminder)
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
          action: /Action.remindersList
        ) {
          RemindersListFeature()
        }

        Reduce<State, Action> { state, action in
            switch action {
            case let .view(viewAction):
                switch viewAction {
                case .addButtonTapped:
                    @Dependency(\.uuid) var uuid
                    let newReminder = Reminder(id: uuid(), title: "", note: "")
                    state.destination = .addReminder(ReminderFormFeature.State(reminder: newReminder))
                    return .none
                case .saveAddReminderTapped:
                    guard let newReminder = state.destination?.addReminder?.reminder else {
                        return .none
                    }

                    state.remindersList.reminders.append(newReminder)
                    state.destination = nil
                    return .none
                case .cancelAddReminderTapped:
                    state.destination = nil
                    return .none
                case let .editButtonTapped(reminder):
                    state.destination = .editReminder(ReminderFormFeature.State(reminder: reminder))
                    return .none
                case .saveEditReminderTapped:
                    guard let editedReminder = state.destination?[case: \.editReminder]?.reminder else {
                        return .none
                    }
                    state.remindersList.reminders[id: editedReminder.id] = editedReminder

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
                    return .send(.delegate(.onCompleteTapped(reminder)))
                case let .onDeleteTapped(ids):
                    return .send(.delegate(.onDeleteTapped(ids)))
                }
            case let .path(.element(id: _, action: .detail(.delegate(.onCompleteTapped(changedReminder))))):
                state.remindersList.reminders[id: changedReminder.id] = changedReminder
                return .send(.delegate(.onCompleteTapped(changedReminder)))
            case .remindersList, .path, .destination, .delegate:
                return .none
            }
        }
        .forEach(\.path, action: \.path)
        .ifLet(\.$destination, action: \.destination)
    }
}

extension AllRemindersCoordinator {
    @Reducer(state: .equatable)
    public enum Destination {
        case editReminder(ReminderFormFeature)
        case addReminder(ReminderFormFeature)
    }
}

extension AllRemindersCoordinator {
    @Reducer(state: .equatable)
    public enum PathFeature {
        case detail(ReminderDetailFeature)
    }
}
