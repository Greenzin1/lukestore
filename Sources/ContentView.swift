import SwiftUI

enum Aba: Hashable {
    case home
    case repos
}

enum Rota: Hashable {
    case apps(Repo)
}

struct MainView: View {
    @EnvironmentObject private var store: SourceStore
    @EnvironmentObject private var temas: TemaStore
    @State private var aba: Aba = .home
    @State private var caminho: [Rota] = []
    @State private var mostrarTemas = false
    @State private var mostrarConfig = false

    var body: some View {
        GeometryReader { geo in
            HStack(spacing: 0) {
                if geo.size.width >= 700 {
                    SidebarView(aba: $aba) {
                        mostrarTemas = true
                    } onConfig: {
                        mostrarConfig = true
                    }
                    .environmentObject(temas)
                    Divider()
                }
                conteudo
            }
        }
        .tint(temas.atual.cor)
        .sheet(isPresented: $mostrarTemas) { TemasView() }
        .sheet(isPresented: $mostrarConfig) { ConfigView() }
    }

    private var conteudo: some View {
        NavigationStack(path: $caminho) {
            Group {
                switch aba {
                case .home: HomeView(aba: $aba)
                case .repos: ReposView()
                }
            }
            .navigationDestination(for: Rota.self) { rota in
                switch rota {
                case .apps(let repo): RepoAppsView(repo: repo)
                }
            }
            .toolbar {
                ToolbarItemGroup(placement: .topBarTrailing) {
                    if aba == .repos && caminho.isEmpty {
                        Button { mostrarAdd = true } label: { Image(systemName: "plus") }
                    }
                    Button { aba = .home; caminho = [] } label: {
                        Image(systemName: "house")
                    }
                    Button { aba = .repos; caminho = [] } label: {
                        Image(systemName: "square.grid.2x2")
                    }
                    Button { mostrarTemas = true } label: { Image(systemName: "paintbrush") }
                    Button { mostrarConfig = true } label: { Image(systemName: "gearshape") }
                }
            }
        }
        .sheet(isPresented: $mostrarAdd) { AddRepoSheet() }
    }

    @State private var mostrarAdd = false
}

struct SidebarView: View {
    @EnvironmentObject private var temas: TemaStore
    @Binding var aba: Aba
    var onTemas: () -> Void
    var onConfig: () -> Void

    var body: some View {
        VStack(spacing: 6) {
            botao("Home", "house", selecionado: aba == .home) { aba = .home }
            botao("Repos", "square.grid.2x2", selecionado: aba == .repos) { aba = .repos }
            botao("Temas", "paintbrush", selecionado: false, acao: onTemas)
            botao("Config", "gearshape", selecionado: false, acao: onConfig)
            Spacer()
        }
        .padding(.top, 24)
        .frame(width: 150)
        .frame(maxHeight: .infinity)
        .background(.thinMaterial)
    }

    private func botao(_ nome: String, _ icone: String, selecionado: Bool, acao: @escaping () -> Void) -> some View {
        Button(action: acao) {
            HStack(spacing: 8) {
                Image(systemName: icone)
                Text(nome)
            }
            .font(.subheadline.weight(selecionado ? .semibold : .regular))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .background(
                selecionado ? temas.atual.cor.opacity(0.2) : .clear,
                in: RoundedRectangle(cornerRadius: 8)
            )
            .foregroundStyle(selecionado ? temas.atual.cor : .primary)
        }
        .padding(.horizontal, 10)
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
