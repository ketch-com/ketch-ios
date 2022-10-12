//
//  KetchApiRequest.swift
//  KetchSDK
//
//  Created by Anton Lyfar on 07.10.2022.
//

import Foundation
import Combine

class KetchApiRequest {
    private let apiClient: ApiClient

    init(apiClient: ApiClient = DefaultApiClient()) {
        self.apiClient = apiClient
    }

    func fetchConfig() -> AnyPublisher<Configuration, KetchError> {
        apiClient.execute(
            request: ApiRequest(
                endPoint: "https://global.ketchcdn.com/web/v2/config/transcenda/website_smart_tag/production/13171895563553497268/default/en/config.json"
            )
        )
        .mapError(KetchError.init)
        .decode(type: Configuration.self, decoder: JSONDecoder())
        .mapError(KetchError.init)
        .eraseToAnyPublisher()
    }

    func fetchBootConfig() -> AnyPublisher<BootConfiguration, KetchError> {
        apiClient.execute(
            request: ApiRequest(
                endPoint: "https://global.ketchcdn.com/web/v2/config/transcenda/website_smart_tag/boot.js"
            )
        )
        .mapError(KetchError.init)
        .decode(type: BootConfiguration.self, decoder: JSONDecoder())
        .mapError(KetchError.init)
        .eraseToAnyPublisher()
    }

    func getConsent(config: ConsentConfig) -> AnyPublisher<ConsentStatus, KetchError> {
        apiClient.execute(
            request: ApiRequest(
                endPoint: "https://global.ketchcdn.com/web/v2/consent/transcenda/get",
                method: .post,
                body: try? JSONEncoder().encode(config)
            )
        )
        .decode(type: ConsentStatus.self, decoder: JSONDecoder())
        .mapError(KetchError.init)
        .eraseToAnyPublisher()
    }

    func updateConsent(update: ConsentUpdate) -> AnyPublisher<Void, KetchError> {
        apiClient.execute(
            request: ApiRequest(
                endPoint: "https://global.ketchcdn.com/web/v2/consent/transcenda/update",
                method: .post,
                body: try? JSONEncoder().encode(update)
            )
        )
        .map { _ in }
        .mapError(KetchError.init)
        .eraseToAnyPublisher()
    }

    func invokeRights(config: InvokeRightConfig) -> AnyPublisher<Void, KetchError> {
        apiClient.execute(
            request: ApiRequest(
                endPoint: "https://global.ketchcdn.com/web/v2/rights/transcenda/invoke",
                method: .post,
                body: try? JSONEncoder().encode(config)
            )
        )
        .map { _ in }
        .mapError(KetchError.init)
        .eraseToAnyPublisher()
    }
}

extension KetchApiRequest {
    enum KetchError: Error {
        case responseError(message: String)
        case requestError
        case decodingError(message: String)

        init(with error: Error) {
            if let apiError = error as? ApiClientError {
                switch apiError {
                case .requestURLError: self = .requestError
                case .sessionError(let error): self = .responseError(message: error.error.message)
                case .unknownError: self = .responseError(message: "Unknown response error")
                }
            } else if let decodingError = error as? DecodingError {
                self = .decodingError(message: decodingError.localizedDescription)
            } else {
                self = .responseError(message: "Unknown error")
            }
        }
    }
}
