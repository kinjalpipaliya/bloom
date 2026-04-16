import SwiftUI

struct MainTabView: View {
    init() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(red: 13/255, green: 15/255, blue: 20/255, alpha: 0.94)

        appearance.stackedLayoutAppearance.selected.iconColor = UIColor(BloomTheme.cream)
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [
            .foregroundColor: UIColor(BloomTheme.cream)
        ]

        appearance.stackedLayoutAppearance.normal.iconColor = UIColor(BloomTheme.textSecondary)
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [
            .foregroundColor: UIColor(BloomTheme.textSecondary)
        ]

        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }

    var body: some View {
        TabView {
            NavigationStack {
                HomeView()
            }
            .tabItem {
                Image(systemName: "house.fill")
                Text("Home")
            }

            NavigationStack {
                LibraryView()
            }
            .tabItem {
                Image(systemName: "heart.text.square.fill")
                Text("Library")
            }

            NavigationStack {
                SettingsView()
            }
            .tabItem {
                Image(systemName: "gearshape.fill")
                Text("Settings")
            }
        }
        .tint(BloomTheme.cream)
    }
}
