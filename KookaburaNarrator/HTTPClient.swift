import Foundation

protocol HTTPClient {
    func sendRequest(_ request: URLRequest, completion: @escaping (Result<Data, Error>) -> Void)
}
