import SwiftUI

@main
struct LukeStoreApp: App {
    @StateObject private var store = SourceStore()
    @StateObject private var repos = RepoStore()
    @StateObject private var temas = TemaStore()
    @StateObject private var search = SearchStore()

    var body: some Scene {
        WindowGroup {
            MainView()
                .environmentObject(store)
                .environmentObject(repos)
                .environmentObject(temas)
                .environmentObject(search)
                .tint(temas.atual.cor)
        }
    }
}
