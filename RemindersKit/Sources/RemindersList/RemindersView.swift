import SwiftUI
import Domain

struct RemindersView<CompletedView: View>: View {
    private let reminder: Reminder
    private let onCompleteTapped: () -> Void
    private let onReminderTapped: () -> Void
    @ViewBuilder private let completedViewBuilder: (Date?) -> CompletedView

    init(
        reminder: Reminder,
        @ViewBuilder completedViewBuilder: @escaping (Date?) -> CompletedView,
        onCompleteTapped: @escaping () -> Void,
        onReminderTapped: @escaping () -> Void
    ) {
        self.reminder = reminder
        self.onCompleteTapped = onCompleteTapped
        self.onReminderTapped = onReminderTapped
        self.completedViewBuilder = completedViewBuilder
    }

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(reminder.title)
                    .font(.subheadline)

                Text(reminder.note)
                    .font(.footnote)
                if let date = reminder.date {
                    Text("Reminder: \(date.formatted(date: .long, time: .shortened))")
                        .font(.caption)
                }
                completedViewBuilder(reminder.completedDate)
            }
            Spacer()
            Image(systemName: "checkmark.circle")
                .opacity(reminder.isCompleted ? 1.0 : 0.3)
                .onTapGesture {
                    onCompleteTapped()
                }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            onReminderTapped()
        }
    }
}
