import Foundation

enum FonteFetch {
    static func buscar(url: String) async throws -> AltSource {
        guard let u = URL(string: url), url.hasPrefix("http") else {
            throw URLError(.badURL)
        }
        let (data, response) = try await URLSession.shared.data(from: u)
        if let http = response as? HTTPURLResponse, !(200..<300).contains(http.statusCode) {
            throw URLError(.badServerResponse)
        }
        return try JSONDecoder().decode(AltSource.self, from: data)
    }
}
