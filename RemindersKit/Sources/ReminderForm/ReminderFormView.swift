import SwiftUI
import ComposableArchitecture

@ViewAction(for: ReminderFormFeature.self)
public struct ReminderFormView: View {
    @Perception.Bindable public var store: StoreOf<ReminderFormFeature>

    public init(store: StoreOf<ReminderFormFeature>) {
        self.store = store
    }

    public var body: some View {
        WithPerceptionTracking {
            Form {
                Section {
                    TextField("Title", text: $store.reminder.title, axis: .vertical)
                    TextField("Note", text: $store.reminder.note, axis: .vertical)
                        .frame(minHeight: 100, alignment: .topLeading)
                }
                Section {
                    Toggle("Date and time", isOn: .init(get: {
                        store.reminder.date != nil
                    }, set: { isOn in
                        send(.dateToggleTapped(isOn), animation: .easeInOut)
                    }))
                    if let date = store.reminder.date {
                        DatePicker("",
                                   selection: .init(
                                    get: {
                                        date
                                    },
                                    set: { newValue in
                                        store.reminder.date = newValue
                                    })
                        )
                        .datePickerStyle(GraphicalDatePickerStyle())
                    }
                }
            }
        }
    }
}
