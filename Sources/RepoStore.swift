import Foundation

@MainActor
final class RepoStore: ObservableObject {
    @Published var repos: [Repo] {
        didSet { salvar() }
    }

    init() {
        if let data = UserDefaults.standard.data(forKey: "repos"),
           let lista = try? JSONDecoder().decode([Repo].self, from: data) {
            repos = lista
        } else {
            repos = [Repo(nome: "UTM Repository", url: "https://alt.getutm.app")]
        }
    }

    private func salvar() {
        if let data = try? JSONEncoder().encode(repos) {
            UserDefaults.standard.set(data, forKey: "repos")
        }
    }

    func adicionar(nome: String, url: String) {
        repos.append(Repo(nome: nome, url: url))
    }

    func remover(_ repo: Repo) {
        repos.removeAll { $0.id == repo.id }
    }
}
