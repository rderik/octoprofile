import Foundation
import ArgumentParser

struct Octoprofile: ParsableCommand {

    @Argument(help: "markdown template filename.")
    var filename: String

    @Option(name: [.customShort("o"), .long], help: "name of output file")
    var output: String?

    func run() throws {
        let plugins: [String: OctoPlugin] = [
            RssPlugin.name: RssPlugin(),
            TwitterPlugin.name: TwitterPlugin()
        ]
        let pluginPattern = #"\{\{octo-plugin:(?<plugin>\w+):?(?<parameter>.*)\}\}"#
        let contents = try String(contentsOfFile: filename, encoding: .utf8)

        let regex = try NSRegularExpression(pattern: pluginPattern, options: [])
        var content = [String]()
        contents.enumerateLines() { line, _ in
            let range = NSRange(line.startIndex..<line.endIndex, in: line)

            if let match = regex.firstMatch(in: line, options: [], range: range)  {
                let pluginNameRange = match.range(withName: "plugin")
                if pluginNameRange.location != NSNotFound, let range = Range(pluginNameRange, in: line) {
                    let pluginName = String(line[range])
                    var parameter: String? = nil
                    let parameterRange = match.range(withName: "parameter")
                    if parameterRange.location != NSNotFound, let prange = Range(parameterRange, in: line) {
                        parameter = String(line[prange])
                    }
                    for (name, p) in plugins {
                        if pluginName == name {
                            var p = p
                            p.parameter = parameter
                            let output = regex.stringByReplacingMatches(in: line, options: [], range: match.range, withTemplate: p.execute())
                            content.append(output)
                            break
                        }
                    }
                }
            } else {
                content.append(line)
            }
        }
        if let output = output {
            let outputURL = URL(fileURLWithPath: output)
            do {
             try content.joined(separator: "\n").write(to: outputURL, atomically: true, encoding: .utf8)
            } catch {
                FileHandle.standardError.write(error.localizedDescription.data(using: .utf8)!)
                Foundation.exit(EXIT_FAILURE)
            }
        }
        else {
            print(content.joined(separator: "\n"))
        }
    }
}
Octoprofile.main()
