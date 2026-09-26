import Foundation

@MainActor
final class SearchStore: ObservableObject {
    struct Hit: Identifiable {
        let repo: Repo
        let app: SourceApp
        var id: String { repo.id.uuidString + "/" + app.id }
    }

    @Published var query = ""
    @Published var filtroRepo: UUID?
    @Published var carregando = false
    @Published var status = ""

    private var cache: [UUID: [SourceApp]] = [:]

    func carregar(repos: [Repo], tudo: Bool) async {
        let pendentes = repos.filter { tudo || cache[$0.id] == nil }
        guard !pendentes.isEmpty else {
            if status.isEmpty {
                status = repos.isEmpty ? "Nenhum repo configurado" : "\(repos.count) repos carregados"
            }
            return
        }
        carregando = true
        var ok = 0
        var erros = 0
        for repo in pendentes {
            do {
                let src = try await FonteFetch.buscar(url: repo.url)
                cache[repo.id] = src.apps
                ok += 1
            } catch {
                erros += 1
            }
        }
        carregando = false
        var novo = ""
        if ok > 0 { novo = "\(ok) repo(s) carregado(s)" }
        if erros > 0 { novo += novo.isEmpty ? "" : " · "; novo += "\(erros) com erro" }
        status = novo
    }

    func hits(repos: [Repo]) -> [Hit] {
        let q = query.trimmingCharacters(in: .whitespaces).lowercased()
        var out: [Hit] = []
        for repo in repos {
            if let f = filtroRepo, f != repo.id { continue }
            guard let apps = cache[repo.id] else { continue }
            for app in apps {
                if q.isEmpty {
                    out.append(Hit(repo: repo, app: app))
                } else if app.name.lowercased().contains(q)
                    || (app.developerName ?? "").lowercased().contains(q)
                    || app.bundleIdentifier.lowercased().contains(q) {
                    out.append(Hit(repo: repo, app: app))
                }
            }
        }
        return out
    }

    func limparFiltros() {
        query = ""
        filtroRepo = nil
    }
}
