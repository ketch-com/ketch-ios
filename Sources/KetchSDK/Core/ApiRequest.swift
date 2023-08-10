//
//  ApiService.swift
//  KetchSDK
//

import Foundation
import Combine

struct EndPoint {
    private static let defaultScheme = "https"
    private static let ketchHost = "global.ketchcdn.com"
    private static let ketchApi = "/web"
    private static let ketchApiVersion = "v2"

    let scheme: String
    let host: String
    let path: String
    let queryItems: [URLQueryItem]

    static func config(organization: String, property: String) -> EndPoint {
        EndPoint(
            scheme: defaultScheme,
            host: ketchHost,
            path: [ketchApi, ketchApiVersion, "config", organization, property, "config.json"].joined(separator: "/"),
            queryItems: [URLQueryItem(name:"language", value:Locale.preferredLanguages[0])]
        )
    }

    static func fullConfig(
        organization: String,
        property: String,
        environment: String,
        hash: Int,
        jurisdiction: String,
        language: String
    ) -> EndPoint {
        EndPoint(
            scheme: defaultScheme,
            host: ketchHost,
            path: [
                ketchApi, ketchApiVersion,
                "config", organization, property, environment, String(hash), jurisdiction, language,
                "config.json"
            ].joined(separator: "/"),
            queryItems: []
        )
    }

    static func getConsent(organization: String) -> EndPoint {
        EndPoint(
            scheme: defaultScheme,
            host: ketchHost,
            path: [ketchApi, ketchApiVersion, "consent", organization, "get"].joined(separator: "/"),
            queryItems: []
        )
    }

    static func updateConsent(organization: String) -> EndPoint {
        EndPoint(
            scheme: defaultScheme,
            host: ketchHost,
            path: [ketchApi, ketchApiVersion, "consent", organization, "update"].joined(separator: "/"),
            queryItems: []
        )
    }

    static func invokeRights(organization: String) -> EndPoint {
        EndPoint(
            scheme: defaultScheme,
            host: ketchHost,
            path: [ketchApi, ketchApiVersion, "rights", organization, "invoke"].joined(separator: "/"),
            queryItems: []
        )
    }

    static func getVendors() -> EndPoint {
        EndPoint(
            scheme: defaultScheme,
            host: ketchHost,
            path: [ketchApi, ketchApiVersion, "gvl", "vendor-list.json"].joined(separator: "/"),
            queryItems: []
        )
    }

    var url: URL? {
        var components = URLComponents()
        components.scheme = scheme
        components.host = host
        components.path = path
        components.queryItems = queryItems

        return components.url
    }
}

struct ApiRequest {
    let endPoint: EndPoint
    let method: Method
    let body: Data?

    init(endPoint: EndPoint, method: Method = .get, body: Data? = nil) {
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
        guard let url = request.endPoint.url else { return nil }
        
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

