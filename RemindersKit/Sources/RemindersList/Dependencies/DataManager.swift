import Dependencies
import DependenciesMacros
import Foundation

@DependencyClient
struct DataManager {
    var save: (_ data: Data, _ url: URL) throws -> Void
    var load: (_ url: URL) throws -> Data
}

extension DataManager: DependencyKey {
    static let liveValue = DataManager { data, url in
        try data.write(to: url)
    } load: { url in
        try Data(contentsOf: url)
    }
}

extension DependencyValues {
    var dataManager: DataManager {
        get { self[DataManager.self] }
        set { self[DataManager.self] = newValue}
    }
}
