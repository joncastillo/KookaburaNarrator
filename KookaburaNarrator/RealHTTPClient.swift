import Foundation

class RealHTTPClient: HTTPClient {
    func sendRequest(_ request: URLRequest, completion: @escaping (Result<Data, Error>) -> Void) {
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let data = data else {
                completion(.failure(NSError(domain: "HTTPClientError", code: 0, userInfo: [NSLocalizedDescriptionKey: "No data received"])))
                return
            }
            completion(.success(data))
        }
        task.resume()
    }
}
