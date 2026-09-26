import SwiftUI

struct ReposView: View {
    @EnvironmentObject private var repos: RepoStore

    var body: some View {
        Group {
            if repos.repos.isEmpty {
                VStack(spacing: 10) {
                    Image(systemName: "square.grid.2x2").font(.system(size: 44)).foregroundStyle(.secondary)
                    Text("Nenhum repo ainda").font(.headline)
                    Text("Toque em + pra adicionar uma source AltSource.")
                        .font(.footnote).foregroundStyle(.secondary)
                }
                .padding(32)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List {
                    ForEach(repos.repos) { repo in
                        NavigationLink(value: Rota.apps(repo)) {
                            RepoRow(repo: repo)
                        }
                    }
                    .onDelete { indice in
                        for i in indice.sorted(by: >) {
                            repos.remover(repos.repos[i])
                        }
                    }
                }
            }
        }
        .navigationTitle("Repos")
    }
}

struct RepoRow: View {
    let repo: Repo

    var body: some View {
        HStack(spacing: 12) {
            AsyncImage(url: favicon(repo.url)) { phase in
                if let img = phase.image {
                    img.resizable().scaledToFit()
                } else {
                    RoundedRectangle(cornerRadius: 8).fill(.quaternary)
                        .frame(width: 44, height: 44)
                        .overlay(Image(systemName: "globe").foregroundStyle(.secondary))
                }
            }
            .frame(width: 44, height: 44)
            .clipShape(RoundedRectangle(cornerRadius: 8))

            VStack(alignment: .leading, spacing: 2) {
                Text(repo.nome).font(.body.weight(.medium)).lineLimit(1)
                Text(repo.url).font(.caption).foregroundStyle(.secondary).lineLimit(1)
            }
        }
    }

    private func favicon(_ url: String) -> URL? {
        guard let u = URL(string: url), let host = u.host else { return nil }
        return URL(string: "https://\(host)/favicon.ico")
    }
}

struct RepoAppsView: View {
    @EnvironmentObject private var store: SourceStore
    let repo: Repo

    var body: some View {
        Group {
            if store.carregando && store.apps.isEmpty {
                ProgressView().frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if store.apps.isEmpty {
                VStack(spacing: 8) {
                    Text("Sem apps").font(.headline)
                    if !store.mensagem.isEmpty {
                        Text(store.mensagem).font(.caption).foregroundStyle(.secondary)
                    }
                }
                .padding(32)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List(store.apps) { app in
                    NavigationLink {
                        AppDetailView(app: app)
                    } label: {
                        AppRow(app: app)
                    }
                }
            }
        }
        .navigationTitle(repo.nome)
        .navigationBarTitleDisplayMode(.inline)
        .task {
            if store.sourceURL != repo.url {
                store.apps = []
                store.sourceURL = repo.url
                await store.buscar()
            } else if store.apps.isEmpty {
                await store.buscar()
            }
        }
    }
}
