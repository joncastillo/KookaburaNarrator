
import XCTest
@testable import Pictochat2
/*
import Foundation
class MockAPIKeyProvider: APIKeyProvider {
    let apiKeyToReturn: String

    init(apiKeyToReturn: String) {
        self.apiKeyToReturn = apiKeyToReturn
    }

    func getAPIKey() -> String {
        return apiKeyToReturn
    }
}

class MockHTTPClient: HTTPClient {
    let dataToReturn: Data?
    let errorToReturn: Error?
    var requestSent: URLRequest?

    init(dataToReturn: Data?, errorToReturn: Error?) {
        self.dataToReturn = dataToReturn
        self.errorToReturn = errorToReturn
    }

    func sendRequest(_ request: URLRequest, completion: @escaping (Result<Data, Error>) -> Void) {
        self.requestSent = request
        if let error = errorToReturn {
            completion(.failure(error))
        } else if let data = dataToReturn {
            completion(.success(data))
        } else {
            completion(.failure(NSError(domain: "HTTPClientError", code: 0, userInfo: [NSLocalizedDescriptionKey: "No data returned"])))
        }
    }
}

class MockJSONHandler: JSONHandler {
    var serializeReturnValue: Data?
    var deserializeReturnValue: Any?
    var deserializeThrowError: Error?

    func serialize(_ object: Any) throws -> Data {
        if let error = deserializeThrowError {
            throw error
        }
        return serializeReturnValue ?? Data()
    }

    func deserialize(_ data: Data) throws -> Any {
        if let error = deserializeThrowError {
            throw error
        }
        return deserializeReturnValue ?? [:]
    }
}
struct TestData {
    let responseJson: [String: Any]
    let expectedResponse: String
}
let testData: [TestData] = [
    TestData(
        responseJson: [
            "choices": [
                [
                    "message": [
                        "content": "This is a test response."
                    ]
                ]
            ]
        ],
        expectedResponse: "This is a test response."
    ),
    TestData(
        responseJson: [
            "choices": [
                [
                    "message": [
                        "content": "Test response with formatting issues."
                    ]
                ]
            ]
        ],
        expectedResponse: "Test response with formatting issues."
    )
]


final class OpenAIManagerTest_A: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testGenerateDescription() {
        let apiKeyProvider = MockAPIKeyProvider(apiKeyToReturn: "test-api-key")
        let jsonHandler = MockJSONHandler()
        let url = URL(string: "https://api.openai.com/v1/chat/completions")!

        for test in testData {
            let httpClient = MockHTTPClient(dataToReturn: try! JSONSerialization.data(withJSONObject: test.responseJson, options: []), errorToReturn: nil)
            let openAIManager = OpenAIManager(apiKeyProvider: apiKeyProvider, httpClient: httpClient, jsonHandler: jsonHandler)

            var generatedDescription: String?
            var testError: Error?

            openAIManager.generateDescription(for: UIImage()) { result in
                switch result {
                case .success(let description):
                    generatedDescription = description
                case .failure(let error):
                    testError = error
                }
            }

            RunLoop.main.run(until: Date().addingTimeInterval(2))

            XCTAssertNil(testError, "Test failed: Error should be nil")
            XCTAssertEqual(generatedDescription, test.expectedResponse, "Test failed: Generated description does not match expected response")
        }
    }
}

*/
