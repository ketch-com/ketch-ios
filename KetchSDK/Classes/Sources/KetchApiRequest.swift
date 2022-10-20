//
//  KetchApiRequest.swift
//  KetchSDK
//
//  Created by Anton Lyfar on 07.10.2022.
//

import Foundation
import Combine

class KetchApiRequest {
    typealias KetchError = KetchSDK.KetchError
    typealias Configuration = KetchSDK.Configuration
    typealias ConsentStatus = KetchSDK.ConsentStatus
    typealias ConsentConfig = KetchSDK.ConsentConfig
    typealias ConsentUpdate = KetchSDK.ConsentUpdate
    typealias InvokeRightConfig = KetchSDK.InvokeRightConfig

    private let apiClient: ApiClient

    init(apiClient: ApiClient = DefaultApiClient()) {
        self.apiClient = apiClient
    }

    func fetchConfig(organization: String, property: String) -> AnyPublisher<Configuration, KetchError> {
        apiClient.execute(
            request: ApiRequest(
                endPoint: .config(organization: organization, property: organization)
            )
        )
        .decode(type: Configuration.self, decoder: JSONDecoder())
        .mapError(KetchError.init)
        .eraseToAnyPublisher()
    }

    func getConsent(config: ConsentConfig) -> AnyPublisher<ConsentStatus, KetchError> {
        apiClient.execute(
            request: ApiRequest(
                endPoint: .getConsent(organization: config.organizationCode),
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
                endPoint: .updateConsent(organization: update.organizationCode),
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
                endPoint: .invokeRights(organization: config.organizationCode),
                method: .post,
                body: try? JSONEncoder().encode(config)
            )
        )
        .map { _ in }
        .mapError(KetchError.init)
        .eraseToAnyPublisher()
    }
}

extension KetchSDK.KetchError {
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
