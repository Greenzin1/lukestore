import SwiftUI

struct ConfigView: View {
    @EnvironmentObject private var store: SourceStore
    @Environment(\.dismiss) private var dismiss
    @State private var apagou = false

    var body: some View {
        NavigationStack {
            Form {
                Section("Sobre") {
                    LabeledContent("App", value: "LukeStore")
                    LabeledContent("Versão", value: Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "1.0.0")
                }
                Section {
                    LabeledContent("Downloads", value: "Arquivos › LukeStore › Downloads")
                    Button(apagou ? "Downloads apagados" : "Limpar downloads", role: .destructive) {
                        limpar()
                    }
                    .disabled(apagou)
                } header: {
                    Text("Armazenamento")
                } footer: {
                    Text("Apaga todos os .ipa baixados.")
                }
                if !store.mensagem.isEmpty {
                    Section("Último status") {
                        Text(store.mensagem).font(.footnote)
                    }
                }
            }
            .navigationTitle("Configurações")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Fechar") { dismiss() }
                }
            }
        }
    }

    @MainActor
    private func limpar() {
        let fm = FileManager.default
        if let itens = try? fm.contentsOfDirectory(at: store.downloadsDir, includingPropertiesForKeys: nil) {
            for url in itens {
                try? fm.removeItem(at: url)
            }
        }
        apagou = true
    }
}
