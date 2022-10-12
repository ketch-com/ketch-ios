//
//  KetchApiRequest.swift
//  KetchSDK
//
//  Created by Anton Lyfar on 07.10.2022.
//

import Foundation
import Combine

enum KetchApiRequest {
    static func fetchConfig() -> AnyPublisher<Configuration, KetchError> {
        ApiClient.execute(
            request: ApiRequest(
                endPoint: "https://global.ketchcdn.com/web/v2/config/transcenda/website_smart_tag/production/13171895563553497268/default/en/config.json"
            )
        )
        .mapError(KetchError.init)
        .eraseToAnyPublisher()
    }

    static func fetchBootConfig() -> AnyPublisher<BootConfiguration, KetchError> {
        ApiClient.execute(
            request: ApiRequest(
                endPoint: "https://global.ketchcdn.com/web/v2/config/transcenda/website_smart_tag/boot.js"
            )
        )
        .mapError(KetchError.init)
        .eraseToAnyPublisher()
    }

    static func getConsent(config: ConsentConfig) -> AnyPublisher<ConsentStatus, KetchError> {
        ApiClient.execute(
            request: ApiRequest(
                endPoint: "https://global.ketchcdn.com/web/v2/consent/transcenda/get",
                method: .post,
                body: try? JSONEncoder().encode(config)
            )
        )
        .mapError(KetchError.init)
        .eraseToAnyPublisher()
    }

    static func updateConsent(update: ConsentUpdate) -> AnyPublisher<Void, KetchError> {
        ApiClient.execute(
            request: ApiRequest(
                endPoint: "https://global.ketchcdn.com/web/v2/consent/transcenda/update",
                method: .post,
                body: try? JSONEncoder().encode(update)
            )
        )
        .map { (_: [String: String]) -> Void in }
        .mapError(KetchError.init)
        .eraseToAnyPublisher()
    }

    static func invokeRights(config: InvokeRightConfig) -> AnyPublisher<Void, KetchError> {
        ApiClient.execute(
            request: ApiRequest(
                endPoint: "https://global.ketchcdn.com/web/v2/rights/transcenda/invoke",
                method: .post,
                body: try? JSONEncoder().encode(config)
            )
        )
        .map { (_: [String: String]) -> Void in }
        .mapError(KetchError.init)
        .eraseToAnyPublisher()
    }
}

extension KetchApiRequest {
    enum KetchError: Error {
        case responseError(message: String)
        case requestError

        init(with error: ApiClient.ApiClientError) {
            switch error {
            case .requestURLError: self = .requestError
            case .sessionError(let error): self = .responseError(message: error.error.message)
            case .unknownError: self = .responseError(message: "Unknown error")
            }
        }
    }

}

