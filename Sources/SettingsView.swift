import SwiftUI

struct SettingsView: View {
    @ObservedObject var store: SourceStore
    @Environment(\.dismiss) private var dismiss
    @State private var urlDraft = ""

    var body: some View {
        NavigationStack {
            Form {
                Section("Source AltSource (JSON)") {
                    TextField("https://exemplo.com/source.json", text: $urlDraft)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .keyboardType(.URL)
                }
                if !store.mensagem.isEmpty {
                    Section("Status") {
                        Text(store.mensagem).font(.footnote)
                    }
                }
                Section {
                    Text("Os IPAs baixados ficam em Arquivos › LukeStore › Downloads.")
                        .font(.footnote).foregroundStyle(.secondary)
                }
            }
            .navigationTitle("Configurações")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Fechar") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Salvar") {
                        store.sourceURL = urlDraft
                        Task { await store.buscar() }
                        dismiss()
                    }
                }
            }
            .onAppear { urlDraft = store.sourceURL }
        }
    }
}
