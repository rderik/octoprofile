# Octoprofile

Octoprofile is a command-line tool that helps you generate a `README.md` file with dynamic content for your GitHub profile. The tool works by using a template file that can include calls to plugins that generate dynamic content for your `README.md`.

By default, it comes with two simple plugins to show how you can automate the creation of your GitHub profile.

The two plugins are:

+ RSSPlugin - Allows you to fetch posts from an RSS feed and add the title and link to the template.
+ Twitter   - Adds a link to your Twitter profile.

These plugins are very simple, but they should give you enough information on how to build your own plugins. 


# Why use octoprofile

The GitHub profile is static, and if you would like to update it frequently to display updates, you'll have to edit manually. You can automate the generation of dynamic content by using `octoprofile`'s template/plugin system.

## Let's see an example:

Imagine you would like to display the three latest posts from your blog on your GitHub profile. But you don't want it to become a chore, where you have to manually edit your `README.md` to add the link for the new post and delete the oldest one.

To automate the process, you could use `octoprofile` for the generation of the `README.md` using the `RSSPlugin`. The plugin fetches the three latest posts on your blog's feed and generates a new `README.md` that you can upload to GitHub.

It is as simple as creating a template with the following format. This template is the one I use on my GitHub Profile:

```md
### Derik Ramirez - [rderik.com](https://rderik.com) 👋

Hello, I'm Derik - a *nix command-line tools developer, primarily macOS. I also work as a backend engineer. You can check my articles at [rderik.com](https://rderik.com).


### Get in touch
- 🕸 Website - [rderik.com](https://rderik.com)
- 🐦 Twitter - [@rderik](https://twitter.com/rderik)
- ✉️ Mail - [derik@rderik.com](mailto:derik@rderik.com)
- 🐙 GitHub Gists - [Gists](https://gist.github.com/rderik)

The following is the list of the latest articles on my blog:

{{octo-plugin:RSS:http://rderik.com/feed.xml:numPosts:3}}

Don't forget to follow me on twitter At {{octo-plugin:Twitter:rderik}}
```


Notice the entries `{{octo-plugin:...}}`. Those entries will trigger a call to a registered plugin and replace them with the text returned by the plugin. A call to a plugin is simple:

```
{{octo-plugin:PLUGIN_NAME:PARAMETERS}}
```

The `octoprofile` usage is the following:

```
USAGE: octoprofile <filename> [--output <output>]

ARGUMENTS:
  <filename>              markdown template filename.

OPTIONS:
  -o, --output <output>   name of output file
  -h, --help              Show help information.
```

If we run this on the command-line:

```
$ octoprofile ./template.md
```

The command displays the generated MD on-screen (you could also specify an output file by using the `-o output_file.md` option):

```
### Derik Ramirez - [rderik.com](https://rderik.com) 👋

Hello, I'm Derik - a *nix command-line tools developer, primarily macOS. I also work as a backend engineer. You can check my articles at [rderik.com](https://rderik.com).


### Get in touch
- 🕸 Website - [rderik.com](https://rderik.com)
- 🐦 Twitter - [@rderik](https://twitter.com/rderik)
- ✉️ Mail - [derik@rderik.com](mailto:derik@rderik.com)
- 🐙 GitHub Gists - [Gists](https://gist.github.com/rderik)

The following is the list of the latest articles on my blog:

- [How to read passwords and sensitive data from the command-line using Swift](https://rderik.com/blog/how-to-read-passwords-and-sensitive-data-from-the-command-line-using-swift/)
- [Understanding the Swift Argument Parser and working with STDIN](https://rderik.com/blog/understanding-the-swift-argument-parser-and-working-with-stdin/)
- [Extracting entitlements from process memory using LLDB](https://rderik.com/blog/extracting-entitlements-from-process-memory-using-lldb/)


Don't forget to follow me on twitter At [@rderik](https://twitter.com/rderik)


```

As you can see it now contains the three latest posts on my feed, and also a link to my Twitter profile.

# The idea behind a command-line tool

Octoprofile is a simple command-line tool. But the benefit comes when you add it to your specific workflow.

For example, You could add a [Git Hook](https://git-scm.com/book/en/v2/Customizing-Git-Git-Hooks) to your blog repository (maybe a `post-recieve`), and every time you push code with the new post the hook calls `octoprofile` to generate a new `README.md` and upload it to your GitHub profile repository. Or create a `cron(8)` job that everyday generates a new `README.md` with fresh information. The sky is the limit.

You could also use `octoprofile` for generating other markdown files that you would like to contain dynamic content powered by an Octoprofile-plugin.

# Create your own plugins

How do you create a plugin?

As easy as creating a struct/class that implements the `OctoPlugin` protocol:

```
protocol OctoPlugin {
    static var name: String { get }
    var parameter: String? {get set}
    func execute() -> String
}
```

At the moment just add your file to the `Sources/octoprofile/plugins/` directory. And "Register" it in the `main.swift` file by adding it to the `plugins` dictionary.

```swift
        let plugins: [String: OctoPlugin] = [
            RssPlugin.name: RssPlugin(),
            TwitterPlugin.name: TwitterPlugin()
        ]
```

And you'll be able to use it on your template by referencing the plugin name. For example, if your plugin returns a simple "Hello, World!".


```swift
struct HelloWorldPlugin: OctoPlugin {
    static var name = "HelloWorld"
    var parameter: String?

    func execute() -> String {
        return "Hello, World!"
    }
}
```

Add it to the `plugins` dictionary in main:

```swift
        let plugins: [String: OctoPlugin] = [
            RssPlugin.name: RssPlugin(),
            TwitterPlugin.name: TwitterPlugin(),
            HelloWorldPlugin.name: HelloWorldPlugin()
        ]
```

And that's it your template can use it by calling:

```md
# This is my profile

{{octo-plugin:HelloWorld}}
```

Build and run `octoprofile`:

```bash
$ swift run octoprofile ./Resources/template.md
```

And you should see the hello world displayed on the screen.

# Contributions and Feedback

Octoprofile is a working progress, and far from complete. There are many improvements I would like to implement (plugin system, I'm looking at you) but I'm just doing this as a pet project. 

I believe this is an excellent project to contribute if you are a beginner (experts are also welcomed), you can focus on just your plugin, and it'll help other people. So don't hesitate to open a pull request or start a discussion in the issues.
