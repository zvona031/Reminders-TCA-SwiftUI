import SwiftUI
import ComposableArchitecture
import Domain

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
                    TextField(String(localized: "Title", bundle: .module), text: $store.reminder.title, axis: .vertical)
                    TextField(String(localized: "Note", bundle: .module), text: $store.reminder.note, axis: .vertical)
                        .frame(minHeight: 50, alignment: .topLeading)
                }
                Section {
                    Toggle(String(localized: "Date and time", bundle: .module), isOn: .init(get: {
                        store.reminder.date != nil
                    }, set: { isOn in
                        send(.dateToggleTapped(isOn), animation: .default)
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

                if store.reminder.date != nil {
                    earlyReminderSection()
                }
            }
        }
    }

    @ViewBuilder
    func earlyReminderSection() -> some View {
        Section {
            Picker("Early Reminder", selection: $store.reminder.earlyReminderType) {
                ForEach(EarlyReminder.choices, id: \.self) { item in
                    Text(item.menuButtonTitle).tag(item)
                }
            }
            if store.reminder.earlyReminderType.is(\.custom),
               let earlyReminderTrigger = store.reminder.earlyReminderTrigger {
                customEarlyReminderText(earlyReminderTrigger.time, earlyReminderTrigger.unit)
                HStack {
                    Picker(
                        "",
                        selection: .init(
                            get: {
                                earlyReminderTrigger.time
                            },
                            set: { newValue in
                                // not forced to call send(someAction)
                                store.reminder.earlyReminderTrigger?.time = newValue
                            }
                        )
                    ) {
                        ForEach(TimeUnit.range, id: \.self) { value in
                            Text(value.description).tag(value)
                        }
                    }
                    .pickerStyle(.wheel)
                    Picker("", selection: .init(get: {
                        earlyReminderTrigger.unit
                    }, set: { newUnit in
                        store.reminder.earlyReminderTrigger?.unit = newUnit
                    })) {
                        ForEach(TimeUnit.allCases, id: \.self) { timeUnit in
                            Text(timeUnit.rawValue).tag(timeUnit)
                        }
                    }
                    .pickerStyle(.wheel)
                }
            }
        }
    }

    @ViewBuilder
    func customEarlyReminderText(_ value: UInt, _ unit: TimeUnit) -> some View {
        let label = switch unit {
        case .minute:
            String(localized: "\(value) minutes before", bundle: .module)
        case .hour:
            String(localized: "\(value) hours before", bundle: .module)
        case .day:
            String(localized: "\(value) days before", bundle: .module)
        case .week:
            String(localized: "\(value) weeks before", bundle: .module)
        case .month:
            String(localized: "\(value) months before", bundle: .module)
        }

        HStack {
            Spacer()
            Text(label)
                .frame(maxWidth: .infinity)
                .border(Color.black)
        }
    }
}

extension EarlyReminder {
    var menuButtonTitle: String {
        switch self {
        case .none:
            String(localized: "None", bundle: .module)
        case let .predefined(reminderTrigger):
            switch reminderTrigger.unit {
            case .minute:
                String(localized: "\(reminderTrigger.time) minutes before", bundle: .module)
            case .hour:
                String(localized: "\(reminderTrigger.time) hours before", bundle: .module)
            case .day:
                String(localized: "\(reminderTrigger.time) days before", bundle: .module)
            case .week:
                String(localized: "\(reminderTrigger.time) weeks before", bundle: .module)
            case .month:
                String(localized: "\(reminderTrigger.time) months before", bundle: .module)
            }
        case .custom:
            String(localized: "Custom", bundle: .module)
        }
    }

    var menuLabelTitle: String {
        switch self {
        case .none:
            String(localized: "None", bundle: .module)
        case let .predefined(reminderTrigger):
            switch reminderTrigger.unit {
            case .minute:
                String(localized: "\(reminderTrigger.time) minutes", bundle: .module)
            case .hour:
                String(localized: "\(reminderTrigger.time) hours", bundle: .module)
            case .day:
                String(localized: "\(reminderTrigger.time) days", bundle: .module)
            case .week:
                String(localized: "\(reminderTrigger.time) weeks", bundle: .module)
            case .month:
                String(localized: "\(reminderTrigger.time) months", bundle: .module)
            }
        case .custom:
            String(localized: "Custom", bundle: .module)
        }
    }
}

#Preview {
    ReminderFormView(
        store: Store(
            initialState: ReminderFormFeature.State(
                reminder: Reminder(
                    title: "",
                    note: "",
                    date: Date(timeIntervalSince1970: 123456789),
                    earlyReminderTrigger: ReminderTrigger(time: 5, unit: .hour))
            )
        ) {
            ReminderFormFeature()
        }
    )
}
