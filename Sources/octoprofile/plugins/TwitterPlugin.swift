import Foundation
import FeedKit

struct TwitterPlugin: OctoPlugin {
    static var name = "Twitter"
    var parameter: String? {
        get {
            return username
        }

        set {
            username = newValue
        }
    }
    private var username: String?

    func execute() -> String {
        guard let username = username else { return "" }
        return "[@\(username)](https://twitter.com/\(username))"
    }
}
