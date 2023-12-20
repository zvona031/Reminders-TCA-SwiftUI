import ComposableArchitecture
import SwiftUI

@ViewAction(for: ReminderDetailFeature.self)
public struct ReminderDetailView: View {
    @BindableStore public var store: StoreOf<ReminderDetailFeature>

    public init(store: StoreOf<ReminderDetailFeature>) {
        self.store = store
    }

    public var body: some View {
        WithPerceptionTracking {
            VStack {
                Text(store.reminder.note)
                Image(systemName: "checkmark.circle")
                    .opacity(store.reminder.isComplete ? 1.0 : 0.3)
                    .onTapGesture {
                        send(.completeButtonTapped)
                    }
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle(store.reminder.title)
        }
    }
}
