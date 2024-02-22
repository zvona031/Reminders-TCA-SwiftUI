import ComposableArchitecture
import SwiftUI
import RemindersList
import Domain
import ReminderDetail
import ReminderForm

@ViewAction(for: CompletedRemindersCoordinator.self)
public struct CompletedRemindersView: View {
    @Perception.Bindable public var store: StoreOf<CompletedRemindersCoordinator>

    public init(store: StoreOf<CompletedRemindersCoordinator>) {
        self.store = store
    }

    public var body: some View {
        WithPerceptionTracking {
            NavigationStack(path: $store.scope(state: \.path, action: \.path)) {
                root()
            } destination: { store in
                switch store.case {
                case let .detail(detailStore):
                    reminderDetailView(detailStore: detailStore)
                }
            }
        }
    }

    @ViewBuilder
    func root() -> some View {
        RemindersListView(
            store: self.store.scope(state: \.remindersList, action: \.remindersList )
        )
        .navigationTitle("Completed reminders")
        .sheet(item: $store.scope(state: \.destination?.editReminder, action: \.destination.editReminder)) { store in
            editReminderFormView(store: store)
        }
    }

    @ViewBuilder
    func editReminderFormView(store: StoreOf<ReminderFormFeature>) -> some View {
        NavigationStack {
            ReminderFormView(store: store)
                .navigationTitle("Edit reminder")
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button {
                            send(.cancelEditReminderTapped)
                        } label: {
                            Text("Cancel")
                        }
                    }
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            send(.saveEditReminderTapped(store.state.reminder))
                        } label: {
                            Text("Edit")
                        }
                    }
                }
        }
    }

    @ViewBuilder
    func reminderDetailView(detailStore: StoreOf<ReminderDetailFeature>) -> some View {
        ReminderDetailView(store: detailStore)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Edit") {
                        send(.editButtonTapped(detailStore.state.reminder))
                    }
                }
            }
            .toolbar(.hidden, for: .tabBar)
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle(detailStore.state.reminder.title)
    }
}
