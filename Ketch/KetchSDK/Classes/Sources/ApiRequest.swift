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

protocol ApiClient {
    func execute(request: ApiRequest) -> AnyPublisher<Data, ApiClientError>
}

enum ApiClientError: Error {
    case requestURLError
    case sessionError(error: KetchApiError)
    case unknownError
}

class DefaultApiClient: ApiClient {
    func execute(request: ApiRequest) -> AnyPublisher<Data, ApiClientError> {
        guard let request = Self.urlRequest(with: request) else {
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

                return output.data
            }
            .mapError { error in
                error as? ApiClientError ?? .unknownError
            }
            .eraseToAnyPublisher()
    }

    private static func urlRequest(with request: ApiRequest) -> URLRequest? {
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

