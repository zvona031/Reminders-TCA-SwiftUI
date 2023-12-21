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
            TabView(selection: $store.selectedTab) {
                AllRemindersView(store: store.scope(state: \.allReminders, action: \.allReminders))
                    .tabItem { Text("All") }
                    .tag(Tab.allReminders)

                CompletedRemindersView(store: store.scope(state: \.completedReminders, action: \.completedReminders))
                    .tabItem { Text("Completed") }
                    .tag(Tab.completedReminders)
            }
        }
    }
}

//#Preview {
//    AppView(
//        store: Store(initialState: AppFeature.State(
//            path: StackState([
//                .detail(ReminderDetailFeature.State(reminder: Reminder(id: UUID(), title: "Naslov", note: "Note je malo duzi nego sto je bilo ocekivano pa ide u tri reda cak stvarno", isComplete: true)))
//            ]),
//            remindersList: RemindersListFeature.State(
//                reminders: [
//                    Reminder(id: UUID(), title: "Naslov", note: "Note je malo duzi nego sto je bilo ocekivano pa ide u tri reda cak stvarno", isComplete: true)
//                ]
//            )
//        ),
//                     reducer: {
//                         AppFeature()
//                     })
//    )
//}
