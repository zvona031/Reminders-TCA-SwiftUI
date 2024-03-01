import SwiftUI
import SwiftUIHelpers
import ComposableArchitecture

@ViewAction(for: RemindersListFeature.self)
public struct RemindersListView<CompletedView: View>: View {
    @Perception.Bindable public var store: StoreOf<RemindersListFeature>
    @ViewBuilder private let completedViewBuilder: (Date?) -> CompletedView

    public init(store: StoreOf<RemindersListFeature>,
                @ViewBuilder completedViewBuilder: @escaping (Date?) -> CompletedView
    ) {
        self.store = store
        self.completedViewBuilder = completedViewBuilder
    }

    public var body: some View {
        WithPerceptionTracking {
            List {
                ForEach(store.reminders, id: \.id) { reminder in
                    RemindersView(
                        reminder: reminder,
                        completedViewBuilder: completedViewBuilder) {
                            send(.onCompleteTapped(reminder.id), animation: .smooth)
                        } onReminderTapped: {
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
