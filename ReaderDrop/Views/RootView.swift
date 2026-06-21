import SwiftUI

struct RootView: View {
    @EnvironmentObject private var router: AppRouter

    var body: some View {
        TabView(selection: $router.selectedTab) {
            SendView()
                .tabItem { Label("tab.send", systemImage: "paperplane.fill") }
                .tag(AppRouter.Tab.send)
            HistoryView()
                .tabItem { Label("tab.history", systemImage: "clock.fill") }
                .tag(AppRouter.Tab.history)
            SettingsView()
                .tabItem { Label("tab.settings", systemImage: "gearshape.fill") }
                .tag(AppRouter.Tab.settings)
        }
        .tint(AppTheme.accent)
        .onOpenURL { url in
            if url.isFileURL { router.openFile(url) }
            else if ["http", "https"].contains(url.scheme?.lowercased() ?? "") { router.openLink(url) }
        }
    }
}
