import SwiftUI

@main
struct TimeLoggerApp: App {
    @StateObject private var store = TimeLogStore()

    var body: some Scene {
        MenuBarExtra {
            ContentView(store: store)
                .frame(width: 320)
        } label: {
            Label("TimeLogger", systemImage: store.isRunning ? "record.circle" : "clock.fill")
        }
        .menuBarExtraStyle(.window)
    }
}
