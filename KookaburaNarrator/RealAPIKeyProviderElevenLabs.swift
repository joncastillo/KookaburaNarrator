import Foundation

class RealAPIKeyProviderElevenLabs: APIKeyProvider {
    func getAPIKey() -> String {
        guard let path = Bundle.main.path(forResource: "Secrets", ofType: "plist"),
              let dictionary = NSDictionary(contentsOfFile: path) as? [String: Any],
              let apiKey = dictionary["APIKEY_ELEVENLABS"] as? String else {
            fatalError("API key not found in Secrets.plist")
        }
        return apiKey
    }
}
