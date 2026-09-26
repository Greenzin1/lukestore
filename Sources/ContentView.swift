import SwiftUI

struct ContentView: View {
    @StateObject private var store = SourceStore()
    @State private var mostrarConfig = false

    var body: some View {
        NavigationStack {
            Group {
                if store.apps.isEmpty {
                    EmptyStateView { mostrarConfig = true }
                } else {
                    AppListView()
                        .environmentObject(store)
                }
            }
            .navigationTitle(store.source?.name ?? "LukeStore")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button { mostrarConfig = true } label: {
                        Image(systemName: "gearshape")
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button { Task { await store.buscar() } } label: {
                        Image(systemName: "arrow.clockwise")
                    }
                    .disabled(store.carregando)
                }
            }
            .sheet(isPresented: $mostrarConfig) {
                SettingsView(store: store)
            }
            .overlay(alignment: .top) {
                if store.carregando {
                    ProgressView().padding(8).background(.thinMaterial, in: Capsule())
                }
            }
        }
        .environmentObject(store)
        .task {
            if store.apps.isEmpty && !store.sourceURL.isEmpty {
                await store.buscar()
            }
        }
    }
}

private struct EmptyStateView: View {
    var configAction: () -> Void

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "shippingbox").font(.system(size: 48)).foregroundStyle(.secondary)
            Text("Nenhuma source carregada").font(.headline)
            Text("Cole a URL de um JSON AltSource nas configurações.")
                .font(.footnote).foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            Button("Configurar fonte", action: configAction)
                .buttonStyle(.borderedProminent)
        }
        .padding(32)
    }
}

private struct AppListView: View {
    @EnvironmentObject var store: SourceStore

    var body: some View {
        List(store.apps) { app in
            NavigationLink(value: app) {
                AppRow(app: app)
            }
        }
        .navigationDestination(for: SourceApp.self) { app in
            AppDetailView(app: app).environmentObject(store)
        }
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
