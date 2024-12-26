import Foundation

class RealJSONHandler: JSONHandler {
    func serialize(_ object: Any) throws -> Data {
        return try JSONSerialization.data(withJSONObject: object, options: [])
    }
    
    func deserialize(_ data: Data) throws -> Any {
        return try JSONSerialization.jsonObject(with: data, options: [])
    }
}
