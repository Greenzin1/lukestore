import Foundation

struct AltSource: Decodable {
    let name: String
    let identifier: String?
    let subtitle: String?
    let apps: [SourceApp]
}

struct SourceApp: Decodable, Identifiable, Hashable {
    let name: String
    let bundleIdentifier: String
    let developerName: String?
    let version: String?
    let versionDate: String?
    let versionDescription: String?
    let downloadURL: String
    let localizedDescription: String?
    let iconURL: String?
    let size: Int64?

    var id: String { bundleIdentifier }
}
