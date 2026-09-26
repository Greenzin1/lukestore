import SwiftUI

struct SearchView: View {
    @EnvironmentObject private var repos: RepoStore
    @EnvironmentObject private var search: SearchStore

    private var temFiltro: Bool {
        !search.query.trimmingCharacters(in: .whitespaces).isEmpty || search.filtroRepo != nil
    }

    private var nomeFiltro: String {
        guard let id = search.filtroRepo else { return "Todos os repos" }
        return repos.repos.first { $0.id == id }?.nome ?? "Todos os repos"
    }

    var body: some View {
        let hits = search.hits(repos: repos.repos)
        List {
            Section {
                HStack {
                    Menu {
                        Button {
                            search.filtroRepo = nil
                        } label: {
                            Label("Todos os repos", systemImage: "square.grid.2x2")
                        }
                        Divider()
                        ForEach(repos.repos) { r in
                            Button {
                                search.filtroRepo = r.id
                            } label: {
                                Label(r.nome, systemImage: "folder")
                            }
                        }
                    } label: {
                        Label(nomeFiltro, systemImage: "line.3.horizontal.decrease.circle")
                            .font(.subheadline)
                    }
                    Spacer()
                    if temFiltro {
                        Button {
                            search.limparFiltros()
                        } label: {
                            Label("Limpar", systemImage: "xmark.circle.fill")
                                .font(.subheadline)
                        }
                    }
                }
            } footer: {
                if !search.status.isEmpty {
                    Text(search.status)
                }
            }

            if search.carregando {
                HStack {
                    Spacer()
                    ProgressView()
                    Spacer()
                }
            } else if hits.isEmpty {
                Text(repos.repos.isEmpty ? "Adicione um repo na aba Repos" : "Nada encontrado")
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
            } else {
                ForEach(hits) { hit in
                    NavigationLink {
                        AppDetailView(app: hit.app)
                    } label: {
                        SearchRow(hit: hit)
                    }
                }
            }
        }
        .navigationTitle("Buscar")
        .searchable(text: $search.query, prompt: "Buscar apps…")
        .task { await search.carregar(repos: repos.repos, tudo: false) }
        .refreshable { await search.carregar(repos: repos.repos, tudo: true) }
    }
}

struct SearchRow: View {
    let hit: SearchStore.Hit

    var body: some View {
        HStack(spacing: 12) {
            AsyncImage(url: URL(string: hit.app.iconURL ?? "")) { phase in
                if let img = phase.image {
                    img.resizable().scaledToFill()
                } else {
                    RoundedRectangle(cornerRadius: 8).fill(.quaternary)
                }
            }
            .frame(width: 44, height: 44)
            .clipShape(RoundedRectangle(cornerRadius: 8))

            VStack(alignment: .leading, spacing: 2) {
                Text(hit.app.name).font(.body.weight(.medium)).lineLimit(1)
                Text(hit.app.developerName ?? hit.app.bundleIdentifier)
                    .font(.caption).foregroundStyle(.secondary).lineLimit(1)
                Text(hit.repo.nome)
                    .font(.caption2)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(.quaternary, in: Capsule())
            }
            Spacer()
            if let v = hit.app.version {
                Text(v).font(.caption).foregroundStyle(.secondary)
            }
        }
    }
}
