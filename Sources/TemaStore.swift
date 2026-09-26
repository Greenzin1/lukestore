import SwiftUI

struct Tema: Identifiable {
    let id: String
    let nome: String
    let cor: Color
}

extension Tema {
    static let todos: [Tema] = [
        Tema(id: "padrao", nome: "Padrão (azul)", cor: .blue),
        Tema(id: "roxo", nome: "Roxo", cor: .purple),
        Tema(id: "verde", nome: "Verde", cor: .green),
        Tema(id: "laranja", nome: "Laranja", cor: .orange),
        Tema(id: "rosa", nome: "Rosa", cor: .pink),
        Tema(id: "vermelho", nome: "Vermelho", cor: .red),
        Tema(id: "amarelo", nome: "Amarelo", cor: .yellow),
        Tema(id: "cinza", nome: "Cinza", cor: .gray),
    ]
}

@MainActor
final class TemaStore: ObservableObject {
    @Published var selecionado: String {
        didSet { UserDefaults.standard.set(selecionado, forKey: "tema") }
    }

    init() {
        selecionado = UserDefaults.standard.string(forKey: "tema") ?? "padrao"
    }

    var atual: Tema {
        Tema.todos.first { $0.id == selecionado } ?? Tema.todos[0]
    }
}
