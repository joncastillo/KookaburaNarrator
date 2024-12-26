import XCTest
@testable import Pictochat2

// Mock implementations for dependency injection
class MockAPIKeyProvider: APIKeyProvider {
    var apiKey: String

    init(apiKey: String) {
        self.apiKey = apiKey
    }

    func getAPIKey() -> String {
        return apiKey
    }
}

class MockHTTPClient: HTTPClient {
    var sentRequest: URLRequest?
    var completion: ((Result<Data, Error>) -> Void)?

    func sendRequest(_ request: URLRequest, completion: @escaping (Result<Data, Error>) -> Void) {
        self.sentRequest = request
        self.completion = completion
    }

    func complete(with data: Data, error: Error? = nil) {
        completion?(error.map({ .failure($0) }) ?? .success(data))
    }
}

class MockJSONHandler: JSONHandler {
    func serialize(_ object: Any) throws -> Data {
        return try JSONSerialization.data(withJSONObject: object, options: [])
    }

    func deserialize(_ data: Data) throws -> Any {
        return try JSONSerialization.jsonObject(with: data, options: [])
    }
}

class MockImage: ImageProtocol {
    func jpegData(compressionQuality: CGFloat) -> Data? {
        return nil
    }
}


class StubbedValidImage: ImageProtocol {
    func jpegData(compressionQuality: CGFloat) -> Data? {
        // Create a valid JPEG Header:
        let validJPEGData = Data([
            0xFF, 0xD8, // Start Of Image
            0xFF, 0xE0, // APP0
            0x00, 0x10, // Length
            0x4A, 0x46, 0x49, 0x46, 0x00, // "JFIF\0"
            0x01, 0x01, // Version
            0x00,       // Units
            0x00, 0x01, 0x00, 0x01, // X and Y density
            0x00, 0x00  // Thumbnail dimensions
        ])
        return validJPEGData
    }
}

class StubbedNullImage: ImageProtocol {
    func jpegData(compressionQuality: CGFloat) -> Data? {
        return nil
    }
}


class OpenAIManagerTests: XCTestCase {
    // A successful case where the image is processed, the request is sent, and a valid response is received.
    func testGenerateDescriptionSuccess() {
        let apiKey = "test-api-key"
        let mockAPIKeyProvider = MockAPIKeyProvider(apiKey: apiKey)
        let mockHTTPClient = MockHTTPClient()
        let mockJSONHandler = MockJSONHandler()

        let openAIManager = OpenAIManager(
            apiKeyProvider: mockAPIKeyProvider,
            httpClient: mockHTTPClient,
            jsonHandler: mockJSONHandler
        )

        let image = StubbedValidImage() // Placeholder image
        var response: String?
        var error: Error?

        openAIManager.generateDescription(for: image) { result in
            switch result {
            case .success(let desc):
                response = desc
            case .failure(let err):
                error = err
            }
        }

        let mockResponseData = """
        {
            "choices": [
                {
                    "message": {
                        "content": "Mocked response content"
                    }
                }
            ]
        }
        """.data(using: .utf8)!
        mockHTTPClient.complete(with: mockResponseData)
        
        let imageData = image.jpegData(compressionQuality: 0.8)!
        let base64Image = imageData.base64EncodedString()

        let expectedPayload: [String: Any] = [
            "model": "chatgpt-4o-latest",
            "messages": [
                ["role": "system", "content": openAIManager.getSystemInstructions()],
                ["role": "user", "content": [["type": "image_url", "image_url": ["url": "data:image/jpeg;base64,\(base64Image)"]]]]
            ],
            "max_tokens": 300
        ]

        let jsonData = try? JSONSerialization.data(withJSONObject: expectedPayload, options: [])
        let unwrappedJsonData = jsonData!
        
        XCTAssertEqual(mockAPIKeyProvider.getAPIKey(), apiKey)
        XCTAssertNotNil(mockHTTPClient.sentRequest)
        XCTAssertEqual(mockHTTPClient.sentRequest?.httpMethod, "POST")
        if let sentRequest = mockHTTPClient.sentRequest, let requestBody = sentRequest.httpBody {
            XCTAssertEqual(requestBody.count, unwrappedJsonData.count, "httpBody length does not match jsonData length")
        } else {
            XCTFail("httpBody is nil")
        }
        XCTAssertEqual(mockHTTPClient.sentRequest?.allHTTPHeaderFields?["Authorization"], "Bearer \(apiKey)")
        XCTAssertEqual(mockHTTPClient.sentRequest?.allHTTPHeaderFields?["Content-Type"], "application/json")
        XCTAssertNotNil(response)
        XCTAssertNil(error)
    }

    // An image processing error where the jpegData method fails.
    func testGenerateDescriptionImageProcessingError() {
        let apiKey = "test-api-key"
        let mockAPIKeyProvider = MockAPIKeyProvider(apiKey: apiKey)
        let mockHTTPClient = MockHTTPClient()
        let mockJSONHandler = MockJSONHandler()

        let openAIManager = OpenAIManager(
            apiKeyProvider: mockAPIKeyProvider,
            httpClient: mockHTTPClient,
            jsonHandler: mockJSONHandler
        )

        let image = StubbedNullImage()
        var response: String?
        var error: Error?

        openAIManager.generateDescription(for: image) { result in
            switch result {
            case .success(let desc):
                response = desc
            case .failure(let err):
                error = err
            }
        }

        XCTAssertNil(response)
        XCTAssertNotNil(error)
        XCTAssertEqual(error?.localizedDescription, "Failed to process the image.")
    }

    // An HTTP client error where the request fails with a custom error.
    func testGenerateDescriptionHTTPClientError() {
        let apiKey = "test-api-key"
        let mockAPIKeyProvider = MockAPIKeyProvider(apiKey: apiKey)
        let mockHTTPClient = MockHTTPClient()
        let mockJSONHandler = MockJSONHandler()

        let openAIManager = OpenAIManager(
            apiKeyProvider: mockAPIKeyProvider,
            httpClient: mockHTTPClient,
            jsonHandler: mockJSONHandler
        )

        let image = StubbedValidImage() // Placeholder image
        var response: String?
        var error: Error?

        openAIManager.generateDescription(for: image) { result in
            switch result {
            case .success(let desc):
                response = desc
            case .failure(let err):
                error = err
            }
        }

        mockHTTPClient.complete(with: Data(), error: NSError(domain: "HTTPClientError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Test HTTP Error"]))

        XCTAssertNil(response)
        XCTAssertNotNil(error)
        XCTAssertEqual(error?.localizedDescription, "Test HTTP Error")
    }

    // An invalid response format error where the JSON response is not as expected.
    func testGenerateDescriptionInvalidResponseFormat() {
        let apiKey = "test-api-key"
        let mockAPIKeyProvider = MockAPIKeyProvider(apiKey: apiKey)
        let mockHTTPClient = MockHTTPClient()
        let mockJSONHandler = MockJSONHandler()

        let openAIManager = OpenAIManager(
            apiKeyProvider: mockAPIKeyProvider,
            httpClient: mockHTTPClient,
            jsonHandler: mockJSONHandler
        )

        let image = StubbedValidImage() // Placeholder image
        var response: String?
        var error: Error?

        openAIManager.generateDescription(for: image) { result in
            switch result {
            case .success(let desc):
                response = desc
            case .failure(let err):
                error = err
            }
        }

        let invalidData = """
        {
            "status": "Invalid OpenAI Response"
        }
        """.data(using: .utf8)!
        mockHTTPClient.complete(with: invalidData)

        XCTAssertNil(response)
        XCTAssertNotNil(error)
        XCTAssertEqual(error?.localizedDescription, "Invalid response format.")
    }
}

