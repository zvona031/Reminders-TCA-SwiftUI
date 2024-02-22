import SwiftUI
import ComposableArchitecture


@ViewAction(for: RemindersListFeature.self)
public struct RemindersListView: View {
    @Perception.Bindable public var store: StoreOf<RemindersListFeature>

    public init(store: StoreOf<RemindersListFeature>) {
        self.store = store
    }

    public var body: some View {
        WithPerceptionTracking {
            List {
                ForEach(store.reminders, id: \.id) { reminder in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(reminder.title)
                            Text(reminder.note)
                        }
                        Spacer()
                        Image(systemName: "checkmark.circle")
                            .opacity(reminder.isComplete ? 1.0 : 0.3)
                            .onTapGesture {
                                send(.onCompleteTapped(reminder.id))
                            }
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        send(.onReminderTapped(reminder))
                    }
                }.onDelete(perform: { indexSet in
                    send(.onDeleteTapped(indexSet))
                })
            }
        }
    }
}
