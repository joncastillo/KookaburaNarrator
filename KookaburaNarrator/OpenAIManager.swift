import SwiftUI

class OpenAIManager {
    private let apiKeyProvider: APIKeyProvider
    private let httpClient: HTTPClient
    private let jsonHandler: JSONHandler
    private var systemInstructions: String

    init(
        apiKeyProvider: APIKeyProvider,
        httpClient: HTTPClient,
        jsonHandler: JSONHandler,
        systemInstructions: String = "Your response depends if the photo is an artwork, a person or a common photo. If it is an artwork briefly state the art style. If it is a person, find the person’s best physical quality and comment on it in a positive way. If it is a common photo, then create a creative description of it. Only reply with the answer without titles or tags."
    ) {
        self.apiKeyProvider = apiKeyProvider
        self.httpClient = httpClient
        self.jsonHandler = jsonHandler
        self.systemInstructions = systemInstructions
    }

    func getSystemInstructions() -> String {
        return systemInstructions
    }

    func setSystemInstructions(_ instructions: String) {
        self.systemInstructions = instructions
    }

    func generateDescription(for image: ImageProtocol, completion: @escaping (Result<String, Error>) -> Void) {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            completion(.failure(NSError(domain: "ImageProcessingError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to process the image."])))
            return
        }
        let base64Image = imageData.base64EncodedString()

        let payload: [String: Any] = [
            "model": "chatgpt-4o-latest",
            "messages": [
                ["role": "system", "content": systemInstructions],
                ["role": "user", "content": [["type": "image_url", "image_url": ["url": "data:image/jpeg;base64,\(base64Image)"]]]]
            ],
            "max_tokens": 300
        ]

        do {
            let jsonData = try jsonHandler.serialize(payload)
            let apiKey = apiKeyProvider.getAPIKey()
            let url = URL(string: "https://api.openai.com/v1/chat/completions")!
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = jsonData

            httpClient.sendRequest(request) { result in
                switch result {
                case .success(let data):
                    do {
                        if let jsonResponse = try self.jsonHandler.deserialize(data) as? [String: Any],
                           let choices = jsonResponse["choices"] as? [[String: Any]],
                           let message = choices.first?["message"] as? [String: Any],
                           let content = message["content"] as? String {
                            completion(.success(content))
                        } else {
                            completion(.failure(NSError(domain: "ResponseFormatError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid response format."])))
                        }
                    } catch {
                        completion(.failure(error))
                    }
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        } catch {
            completion(.failure(error))
        }
    }
}
