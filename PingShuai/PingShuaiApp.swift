import SwiftUI

@main
struct PingShuaiApp: App {
    @StateObject private var store = HistoryStore()
    @StateObject private var engine = SwingEngine()

    var body: some Scene {
        WindowGroup {
            TabView {
                TimerView()
                    .tabItem { Label("練功", systemImage: "timer") }
                HistoryView()
                    .tabItem { Label("日誌", systemImage: "calendar") }
            }
            .environmentObject(store)
            .environmentObject(engine)
            .onAppear { engine.onFinish = { store.add(seconds: $0, preset: $1) } }
        }
    }
}
