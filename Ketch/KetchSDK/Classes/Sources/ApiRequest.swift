//
//  ApiService.swift
//  KetchSDK
//
//  Created by Anton Lyfar on 07.10.2022.
//

import Foundation
import Combine

struct ApiRequest {
    let endPoint: String
    let method: Method
    let body: Data?

    init(endPoint: String, method: Method = .get, body: Data? = nil) {
        self.endPoint = endPoint
        self.method = method
        self.body = body
    }
}

extension ApiRequest {
    enum Method: String {
        case get = "GET"
        case post = "POST"
    }

    struct HeaderField {
        static let accept = "Accept"
        static let contentType = "Content-Type"
    }

    struct HeaderValue {
        static let applicationJson = "application/json"
        static let contentTypeJson = "application/json; charset=UTF-8"
    }
}

enum ApiClient {
    enum ApiClientError: Error {
        case requestURLError
        case sessionError(error: KetchApiError)
        case unknownError
    }

    static func execute<T: Codable>(request: ApiRequest) -> AnyPublisher<T, ApiClientError> {
        guard let request = urlRequest(with: request) else {
            return Fail(error: ApiClientError.requestURLError).eraseToAnyPublisher()
        }

        return URLSession.shared
            .dataTaskPublisher(for: request)
            .tryMap { output in
                guard
                    let httpResponse = output.response as? HTTPURLResponse,
                      (200..<300).contains(httpResponse.statusCode)
                else {
                    let error = try JSONDecoder().decode(KetchApiError.self, from: output.data)
                    throw ApiClientError.sessionError(error: error)
                }

                if let responseData = bootstrapFunctionData(with: output.data) {
                    return responseData
                }

                return output.data
            }
            .decode(type: T.self, decoder: JSONDecoder())
            .mapError { error in
                error as? ApiClientError ?? .unknownError
            }
            .eraseToAnyPublisher()
    }

    private static func bootstrapFunctionData(with responseData: Data) -> Data? {
        let jsFuncPrefix = "!function(){var n='semaphore',a="

        guard
            var string = String(data: responseData, encoding: .utf8),
            string.hasPrefix(jsFuncPrefix)
        else { return nil }

        string.removeFirst(jsFuncPrefix.count)
        let model = string.components(separatedBy: ";").first

        return model?.data(using: .utf8)
    }
}

extension ApiClient {
    static func urlRequest(with request: ApiRequest) -> URLRequest? {
        guard let url = URL(string: request.endPoint) else { return nil }

        var urlRequest = URLRequest(url: url)

        urlRequest.httpBody = request.body
        urlRequest.httpMethod = request.method.rawValue
        urlRequest.cachePolicy = .reloadIgnoringLocalCacheData
        
        urlRequest.setValue(
            ApiRequest.HeaderValue.applicationJson,
            forHTTPHeaderField: ApiRequest.HeaderField.accept
        )

        urlRequest.setValue(
            ApiRequest.HeaderValue.applicationJson,
            forHTTPHeaderField: ApiRequest.HeaderField.contentType
        )

        return urlRequest
    }
}

struct KetchApiError: Codable {
    let error: KetchApiErrorModel

    struct KetchApiErrorModel: Codable {
        let code: String
        let message: String
        let status: Int
    }
}

