import Foundation

struct AltSource: Decodable {
    let name: String
    let apps: [SourceApp]
}

enum FlexInt: Decodable {
    case number(Int64)

    init(from decoder: Decoder) throws {
        let c = try decoder.singleValueContainer()
        if let i = try? c.decode(Int64.self) { self = .number(i); return }
        if let s = try? c.decode(String.self),
           let i = Int64(s.trimmingCharacters(in: .whitespaces)) {
            self = .number(i)
            return
        }
        self = .number(0)
    }

    var value: Int64 {
        switch self {
        case .number(let n): return n
        }
    }
}

struct VersionEntry: Decodable {
    let version: String?
    let date: String?
    let downloadURL: String?
    let size: FlexInt?
}

struct SourceApp: Decodable, Identifiable, Hashable {
    let name: String
    let bundleIdentifier: String
    let developerName: String?
    let localizedDescription: String?
    let iconURL: String?
    let subtitle: String?
    let version: String?
    let versionDate: String?
    let downloadURL: String?
    let size: Int64?

    var id: String { bundleIdentifier }

    private enum K: String, CodingKey {
        case name, bundleIdentifier, developerName, localizedDescription
        case iconURL, subtitle, versions, version, versionDate, downloadURL, size
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: K.self)
        name = try c.decode(String.self, forKey: .name)
        bundleIdentifier = try c.decodeIfPresent(String.self, forKey: .bundleIdentifier) ?? name
        developerName = try c.decodeIfPresent(String.self, forKey: .developerName)
        localizedDescription = try c.decodeIfPresent(String.self, forKey: .localizedDescription)
        iconURL = try c.decodeIfPresent(String.self, forKey: .iconURL)
        subtitle = try c.decodeIfPresent(String.self, forKey: .subtitle)

        // Formato novo (AltSource 1.1+): campos dentro de versions[].
        // Formato antigo: campos direto no app. Aceita os dois.
        let atual = try c.decodeIfPresent([VersionEntry].self, forKey: .versions)?.first
        version = try c.decodeIfPresent(String.self, forKey: .version) ?? atual?.version
        versionDate = try c.decodeIfPresent(String.self, forKey: .versionDate) ?? atual?.date
        downloadURL = try c.decodeIfPresent(String.self, forKey: .downloadURL) ?? atual?.downloadURL
        size = try c.decodeIfPresent(FlexInt.self, forKey: .size)?.value ?? atual?.size?.value
    }
}

func descreverErro(_ e: DecodingError) -> String {
    switch e {
    case .keyNotFound(let k, _):
        return "falta a chave \"\(k.stringValue)\""
    case .valueNotFound(let k, _):
        return "valor ausente em \"\(k.stringValue)\""
    case .typeMismatch(_, let ctx):
        return "tipo errado em \(ctx.codingPath.map(\.stringValue).joined(separator: "."))"
    case .dataCorrupted(let ctx):
        return "JSON corrompido em \(ctx.codingPath.map(\.stringValue).joined(separator: "."))"
    @unknown default:
        return e.localizedDescription
    }
}
