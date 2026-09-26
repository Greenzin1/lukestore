import SwiftUI

struct AppDetailView: View {
    @EnvironmentObject var store: SourceStore
    let app: SourceApp

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                header
                if let desc = app.localizedDescription {
                    Text(desc).font(.body)
                }
                metadata
                action
            }
            .padding()
        }
        .navigationTitle(app.name)
        .navigationBarTitleDisplayMode(.inline)
        .safeAreaInset(edge: .bottom) {
            if let msg = store.mensagem.isEmpty ? nil : store.mensagem {
                Text(msg).font(.caption).foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity).padding(6)
            }
        }
    }

    private var header: some View {
        HStack(spacing: 14) {
            AsyncImage(url: URL(string: app.iconURL ?? "")) { phase in
                if let img = phase.image { img.resizable().scaledToFit() }
                else { RoundedRectangle(cornerRadius: 12).fill(.quaternary) }
            }
            .frame(width: 72, height: 72)
            .clipShape(RoundedRectangle(cornerRadius: 12))

            VStack(alignment: .leading, spacing: 4) {
                Text(app.name).font(.title3.bold())
                Text(app.developerName ?? "").font(.subheadline).foregroundStyle(.secondary)
                if let v = app.version {
                    Text("v\(v)").font(.caption).foregroundStyle(.secondary)
                }
            }
            Spacer()
        }
    }

    private var metadata: some View {
        VStack(alignment: .leading, spacing: 6) {
            if let d = app.versionDate {
                row("Data", d)
            }
            if let s = app.size {
                row("Tamanho", ByteCountFormatter.string(fromByteCount: s, countStyle: .file))
            }
            row("ID", app.bundleIdentifier)
        }
        .font(.footnote)
    }

    private func row(_ k: String, _ v: String) -> some View {
        HStack {
            Text(k).foregroundStyle(.secondary)
            Spacer()
            Text(v).multilineTextAlignment(.trailing)
        }
    }

    @ViewBuilder
    private var action: some View {
        if let arquivo = store.ipaExiste(app) {
            ShareLink(item: arquivo) {
                Label("Compartilhar IPA", systemImage: "square.and.arrow.up")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            Text("Salvo em Arquivos › LukeStore › Downloads")
                .font(.caption).foregroundStyle(.secondary)
        } else if store.baixando == app.bundleIdentifier {
            HStack {
                ProgressView()
                Text("Baixando…")
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
        } else {
            Button {
                Task { await store.baixar(app) }
            } label: {
                Label("Baixar IPA", systemImage: "arrow.down.circle")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
        }
    }
}
