import ComposableArchitecture
import Foundation
import Domain
import Dependencies

@Reducer
public struct RemindersListFeature {
    public init() {}

    @Dependency(\.remindersClient.load) var loadReminders

    @ObservableState
    public struct State: Equatable {
        public var reminders: IdentifiedArrayOf<Reminder> = []

        public init() {}
    }

    public enum Action: ViewAction {
        public enum ViewAction {
            case onReminderTapped(Reminder)
            case onCompleteTapped(Reminder.ID)
            case onDeleteTapped(IndexSet)
            case onFirstAppear
        }

        @CasePathable
        public enum Delegate {
            case onReminderTapped(Reminder)
            case onCompleteTapped(Reminder)
            case onDeleteTapped([Reminder.ID])
        }

        case view(ViewAction)
        case delegate(Delegate)
        case remindersResponse(Result<[Reminder], Error>)
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
                case .onFirstAppear:
                    return .run { send in
                        await send(.remindersResponse(Result { try loadReminders() }))
                    }
                }
            case .remindersResponse(.success(let reminders)):
                state.reminders = IdentifiedArray(uniqueElements: reminders)
                return .none
            case .remindersResponse(.failure):
                return .none
            case .delegate:
                return .none
            }
        }
    }
}
