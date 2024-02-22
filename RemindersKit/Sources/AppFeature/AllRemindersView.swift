import ComposableArchitecture
import SwiftUI
import RemindersList
import Domain
import ReminderDetail
import ReminderForm

@ViewAction(for: AllRemindersCoordinator.self)
public struct AllRemindersView: View {
    @Perception.Bindable public var store: StoreOf<AllRemindersCoordinator>

    public init(store: StoreOf<AllRemindersCoordinator>) {
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
        .navigationTitle("All reminders")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Add") {
                    send(.addButtonTapped)
                }
            }
        }
        .sheet(item: $store.scope(state: \.destination?.editReminder, action: \.destination.editReminder)) { store in
            editReminderFormView(store: store)
        }
        .sheet(item: $store.scope(state: \.destination?.addReminder, action: \.destination.addReminder)) { store in
            addReminderFormView(store: store)
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
                            send(.saveEditReminderTapped)
                        } label: {
                            Text("Edit")
                        }

                    }
                }
        }
    }

    @ViewBuilder
    func addReminderFormView(store: StoreOf<ReminderFormFeature>) -> some View {
        NavigationStack {
            ReminderFormView(store: store)
                .navigationTitle("New reminder")
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button {
                            send(.cancelAddReminderTapped)
                        } label: {
                            Text("Cancel")
                        }

                    }
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            send(.saveAddReminderTapped)
                        } label: {
                            Text("Save")
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
