import SwiftUI
import SwiftUIHelpers
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
                                .font(.headline)
                            Text(reminder.note)
                                .font(.subheadline)
                            if let date = reminder.date {
                                Text(date.formatted(date: .long, time: .shortened))
                                    .font(.footnote)
                            }
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
                }.onDelete { indexSet in
                    send(.onDeleteTapped(indexSet))
                }
            }
            .onFirstAppear {
                await send(.onFirstAppear).finish()
            }
        }
    }
}
