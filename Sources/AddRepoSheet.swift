import SwiftUI

struct AddRepoSheet: View {
    @EnvironmentObject private var repos: RepoStore
    @Environment(\.dismiss) private var dismiss
    @State private var nome = ""
    @State private var url = ""

    var body: some View {
        NavigationStack {
            Form {
                Section("Source AltSource (JSON)") {
                    TextField("Nome (ex: UTM Repository)", text: $nome)
                    TextField("https://exemplo.com/source.json", text: $url)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .keyboardType(.URL)
                }
            }
            .navigationTitle("Adicionar repo")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Adicionar") {
                        repos.adicionar(
                            nome: nome.isEmpty ? URL(string: url)?.host ?? "Repo" : nome,
                            url: url
                        )
                        dismiss()
                    }
                    .disabled(!url.hasPrefix("http"))
                }
            }
        }
    }
}
