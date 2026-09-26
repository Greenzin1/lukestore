import Foundation

@MainActor
final class SourceStore: ObservableObject {
    @Published var source: AltSource?
    @Published var apps: [SourceApp] = []
    @Published var mensagem: String = ""
    @Published var carregando = false
    @Published var baixando: String?

    var sourceURL: String {
        didSet { UserDefaults.standard.set(sourceURL, forKey: "sourceURL") }
    }

    init() {
        sourceURL = UserDefaults.standard.string(forKey: "sourceURL") ?? ""
    }

    var downloadsDir: URL {
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let dir = docs.appendingPathComponent("Downloads", isDirectory: true)
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir
    }

    private func fileName(_ app: SourceApp) -> String {
        app.bundleIdentifier.replacingOccurrences(of: "/", with: "_") + ".ipa"
    }

    func ipaExiste(_ app: SourceApp) -> URL? {
        let url = downloadsDir.appendingPathComponent(fileName(app))
        return FileManager.default.fileExists(atPath: url.path) ? url : nil
    }

    func buscar() async {
        guard sourceURL.hasPrefix("http"), let url = URL(string: sourceURL) else {
            mensagem = "Cole uma URL de source começando com http"
            return
        }
        carregando = true
        mensagem = ""
        defer { carregando = false }
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            if let http = response as? HTTPURLResponse, !(200..<300).contains(http.statusCode) {
                mensagem = "Servidor respondeu HTTP \(http.statusCode)"
                return
            }
            let src = try JSONDecoder().decode(AltSource.self, from: data)
            source = src
            apps = src.apps
            mensagem = "\(src.apps.count) apps em \(src.name)"
        } catch {
            mensagem = "Erro: \(error.localizedDescription)"
        }
    }

    func baixar(_ app: SourceApp) async {
        guard let url = URL(string: app.downloadURL) else {
            mensagem = "downloadURL inválida"
            return
        }
        baixando = app.bundleIdentifier
        defer { baixando = nil }
        do {
            let (temp, response) = try await URLSession.shared.download(from: url)
            if let http = response as? HTTPURLResponse, !(200..<300).contains(http.statusCode) {
                mensagem = "Download falhou: HTTP \(http.statusCode)"
                return
            }
            let destino = downloadsDir.appendingPathComponent(fileName(app))
            if FileManager.default.fileExists(atPath: destino.path) {
                try FileManager.default.removeItem(at: destino)
            }
            try FileManager.default.moveItem(at: temp, to: destino)
            mensagem = "Salvo: \(fileName(app))"
        } catch {
            mensagem = "Erro no download: \(error.localizedDescription)"
        }
    }
}
