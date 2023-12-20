import ComposableArchitecture
import SwiftUI
import RemindersList
import Domain
import ReminderDetail
import ReminderForm

@ViewAction(for: AppFeature.self)
public struct AppView: View {
    @BindableStore public var store: StoreOf<AppFeature>

    public init(store: StoreOf<AppFeature>) {
        self.store = store
    }

    public var body: some View {
        WithPerceptionTracking {
            NavigationStack(path: $store.scope(state: \.path, action: \.path)) {
                root()
            } destination: { store in
                switch store.state {
                case .detail:
                    reminderDetailView(store: store)
                }
            }
        }
    }

    @ViewBuilder
    func root() -> some View {
        RemindersListView(
            store: self.store.scope(state: \.remindersList, action: \.remindersList )
        )
        .toolbar(content: {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Add") {
                    send(.addButtonTapped)
                }
            }
        })
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
                .toolbar(content: {
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
                })
        }
    }

    @ViewBuilder
    func addReminderFormView(store: StoreOf<ReminderFormFeature>) -> some View {
        NavigationStack {
            ReminderFormView(store: store)
                .navigationTitle("New reminder")
                .toolbar(content: {
                    ToolbarItem(placement: .topBarLeading) {
                        Button {
                            send(.cancelAddReminderTapped)
                        } label: {
                            Text("Cancel")
                        }

                    }
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            send(.saveAddReminderTapped(store.state.reminder))
                        } label: {
                            Text("Save")
                        }

                    }
                })
        }
    }

    @ViewBuilder
    func reminderDetailView(store: StoreOf<AppFeature.PathFeature>) -> some View {
        if let store = store.scope(state: \.detail, action: \.detail) {
            ReminderDetailView(store: store)
                .toolbar(content: {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Edit") {
                            send(.editButtonTapped(store.state.reminder))
                        }
                    }
                })
        }
    }
}

#Preview {
    AppView(
        store: Store(initialState: AppFeature.State(
            path: StackState([
                .detail(ReminderDetailFeature.State(reminder: Reminder(id: UUID(), title: "Naslov", note: "Note je malo duzi nego sto je bilo ocekivano pa ide u tri reda cak stvarno", isComplete: true)))
            ]),
            remindersList: RemindersListFeature.State(
                reminders: [
                    Reminder(id: UUID(), title: "Naslov", note: "Note je malo duzi nego sto je bilo ocekivano pa ide u tri reda cak stvarno", isComplete: true)
                ]
            )
        ),
                     reducer: {
            AppFeature()
        })
    )
}
