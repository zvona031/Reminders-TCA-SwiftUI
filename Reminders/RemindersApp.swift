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
                    initialState: AppFeature.State()
                ) {
                    AppFeature()
                }
            )
        }
    }
}
