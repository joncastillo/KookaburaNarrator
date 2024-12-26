import Foundation

protocol JSONHandler {
    func serialize(_ object: Any) throws -> Data
    func deserialize(_ data: Data) throws -> Any
}
