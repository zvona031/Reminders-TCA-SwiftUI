import SwiftUI
import ComposableArchitecture
import AppFeature
import RemindersList
import Domain

@main
struct RemindersApp: App {
    var body: some Scene {
        WindowGroup {
            AppView(
                store: Store(
                    initialState: AppFeature.State(
                        allReminders: AllRemindersCoordinator.State(
                            remindersList: RemindersListFeature.State(
                                reminders: [
                                    Reminder(title: "1", note: "1"),
                                    Reminder(title: "2", note: "2"),
                                    Reminder(title: "3", note: "3"),
                                    Reminder(title: "4", note: "4")
                                ]
                            )
                        )
                    ),
                    reducer: {
                        AppFeature()
                    })
            )
        }
    }
}
