import SwiftUI
import ComposableArchitecture

public struct ReminderFormView: View {
    @BindableStore var store: StoreOf<ReminderFormFeature>

    public init(store: StoreOf<ReminderFormFeature>) {
        self.store = store
    }

    public var body: some View {
        WithPerceptionTracking {
            Form {
                Section {
                    TextField("Title", text: $store.reminder.title)

                } header: {
                    Text("Info")
                }
                Section {
                    TextEditor(text: $store.reminder.note)
                } header: {
                    Text("Note")
                }
            }
        }
    }
}
