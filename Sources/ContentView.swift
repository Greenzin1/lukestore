import SwiftUI

enum Aba: Hashable {
    case home
    case repos
    case buscar
    case temas
    case config
}

enum Rota: Hashable {
    case apps(Repo)
}

struct MainView: View {
    @EnvironmentObject private var store: SourceStore
    @EnvironmentObject private var temas: TemaStore
    @State private var aba: Aba = .home
    @State private var mostrarAdd = false

    var body: some View {
        TabView(selection: $aba) {
            NavigationStack {
                HomeView(aba: $aba)
            }
            .tabItem { Label("Home", systemImage: "house") }
            .tag(Aba.home)

            NavigationStack {
                ReposView()
                    .navigationDestination(for: Rota.self) { rota in
                        switch rota {
                        case .apps(let repo): RepoAppsView(repo: repo)
                        }
                    }
                    .toolbar {
                        ToolbarItem(placement: .topBarTrailing) {
                            Button { mostrarAdd = true } label: {
                                Image(systemName: "plus")
                            }
                        }
                    }
            }
            .tabItem { Label("Repos", systemImage: "square.grid.2x2") }
            .tag(Aba.repos)

            NavigationStack {
                SearchView()
            }
            .tabItem { Label("Buscar", systemImage: "magnifyingglass") }
            .tag(Aba.buscar)

            NavigationStack {
                TemasView()
            }
            .tabItem { Label("Temas", systemImage: "paintbrush") }
            .tag(Aba.temas)

            NavigationStack {
                ConfigView()
            }
            .tabItem { Label("Config", systemImage: "gearshape") }
            .tag(Aba.config)
        }
        .tint(temas.atual.cor)
        .sheet(isPresented: $mostrarAdd) { AddRepoSheet() }
    }
}

struct HomeView: View {
    @EnvironmentObject private var store: SourceStore
    @Binding var aba: Aba

    var body: some View {
        VStack(spacing: 14) {
            Image(systemName: "shippingbox.fill")
                .font(.system(size: 52))
                .foregroundStyle(.secondary)
            Text("LukeStore").font(.title2.bold())
            Text("Gerencie suas sources AltSource em um só lugar.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            Button("Ver repos") { aba = .repos }
                .buttonStyle(.borderedProminent)
            if !store.mensagem.isEmpty {
                Text(store.mensagem)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(32)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .navigationTitle("Home")
    }
}

struct AppRow: View {
    let app: SourceApp

    var body: some View {
        HStack(spacing: 12) {
            AsyncImage(url: URL(string: app.iconURL ?? "")) { phase in
                if let img = phase.image {
                    img.resizable().scaledToFill()
                } else {
                    RoundedRectangle(cornerRadius: 8).fill(.quaternary)
                }
            }
            .frame(width: 44, height: 44)
            .clipShape(RoundedRectangle(cornerRadius: 8))

            VStack(alignment: .leading, spacing: 2) {
                Text(app.name).font(.body.weight(.medium)).lineLimit(1)
                Text(app.developerName ?? app.bundleIdentifier)
                    .font(.caption).foregroundStyle(.secondary).lineLimit(1)
            }
            Spacer()
            if let v = app.version {
                Text(v).font(.caption).foregroundStyle(.secondary)
            }
        }
    }
}
