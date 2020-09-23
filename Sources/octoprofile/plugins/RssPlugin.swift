import Foundation
import FeedKit

struct BlogPost {
    var title: String?
    var url: String?
}

struct RssPlugin: OctoPlugin {
    static var name = "RSS"

    var parameter: String? {
        get {
            return _feedURL
        }
        set {
            let parameters = newValue?.components(separatedBy: ":numPosts:")
            _feedURL = parameters?.first
            defaultPostNum = Int(parameters?.last ?? "") ?? 5
        }
    }

    var defaultPostNum = 5
    private var _feedURL: String?

    func execute() -> String {
        let stderr = FileHandle.standardError
        guard let _feedURL = _feedURL else {
            let message = "Error: missing feed URL"
            stderr.write(message.data(using: .utf8)!)
            Foundation.exit(EXIT_FAILURE)
        }
        guard let url = URL(string: _feedURL ) else {
            let message = "Error: malformed url \(_feedURL)"
            stderr.write(message.data(using: .utf8)!)
            Foundation.exit(EXIT_FAILURE)
        }

        var blogPosts = [BlogPost]()

        let parser = FeedParser(URL: url)
        let result = parser.parse()

        switch result {
        case .success(let feed):
            switch feed {
            case .rss(let myFeed):
                let postNum = min(defaultPostNum, myFeed.items?.count ?? 0)
                for i in (0 ..< postNum) {
                    let title = myFeed.items?[i].title ?? ""
                    let link = myFeed.items?[i].link ?? ""
                    blogPosts.append(BlogPost(title: title, url: link))
                }
            case .atom(let myFeed):
                let postNum = min(defaultPostNum, myFeed.entries?.count ?? 0)
                for i in (0 ..< postNum) {
                    let title = myFeed.entries?[i].title ?? ""
                    let link = myFeed.entries?[i].links?[0].attributes?.href ?? "#"
                    blogPosts.append(BlogPost(title: title, url: link))
                }
            case .json(let myFeed):
                print("Is Json")
                let postNum = min(defaultPostNum, myFeed.items?.count ?? 0)
                for i in (0 ..< postNum) {
                    let title = myFeed.items?[i].title ?? ""
                    let link = myFeed.items?[i].url ?? ""
                    blogPosts.append(BlogPost(title: title, url: link))
                }
            }
        case .failure(let error):
            stderr.write(
                (error.localizedDescription.data(using: .utf8) ?? "Error: Can't parse feed".data(using: .utf8))!
            )
            Foundation.exit(EXIT_FAILURE)
        }
        var content = ""
        for blogPost in blogPosts {
            content += "- [\(blogPost.title!)](\(blogPost.url!))\n"
        }
        return content
    }
}
