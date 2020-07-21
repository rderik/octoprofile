protocol OctoPlugin {
    static var name: String { get }
    var parameter: String? {get set}
    func execute() -> String
}
