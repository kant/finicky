import Foundation

final class Settings {

    private let userDefaults: UserDefaults

    init(userDefaults: UserDefaults) {
        self.userDefaults = userDefaults
    }

    // MARK: - Public API

    var configLocation: URL {
        get {
            guard let bookmarkData = self.userDefaults.data(forKey: Constants.configLocationBookmarkKey) else {
                return self.defaultConfigLocation
            }
            do {
                var bookmarkIsStale: Bool = false
                let url = try URL(resolvingBookmarkData: bookmarkData, bookmarkDataIsStale: &bookmarkIsStale)
                if bookmarkIsStale {
                    let newBookmarkData = try url.bookmarkData()
                    self.userDefaults.setValue(newBookmarkData, forKey: Constants.configLocationBookmarkKey)
                }
                return url
            } catch {
                return self.defaultConfigLocation
            }
        }
        set {
            if let bookmarkData = try? newValue.bookmarkData() {
                self.userDefaults.set(bookmarkData, forKey: Constants.configLocationBookmarkKey)
            } else {
                self.userDefaults.removeObject(forKey: Constants.configLocationBookmarkKey)
            }
        }
    }

    // MARK: - Private

    private struct Constants {
        static let configLocationBookmarkKey = "config_location_bookmark"
        static let defaultConfigPath: NSString = "~/.finicky.js"
    }

    private var defaultConfigLocation: URL {
        let path = Constants.defaultConfigPath.resolvingSymlinksInPath
        return URL(fileURLWithPath: path)
    }
}
