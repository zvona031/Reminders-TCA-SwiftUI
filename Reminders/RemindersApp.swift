import SwiftUI
import ComposableArchitecture
import AppFeature

@main
struct RemindersApp: App {
    var body: some Scene {
        WindowGroup {
                AppView(
                    store: Store(initialState: AppFeature.State(),
                                 reducer: {
                        AppFeature()
                    })
                )
        }
    }
}
