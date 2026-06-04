//
//  KetchApiRequest.swift
//  KetchSDK
//

import Foundation
import Combine

/// Request processor for Ketch headless (web/v3) API.
class KetchApiRequest {
    typealias KetchError = KetchSDK.KetchError
    typealias Configuration = KetchSDK.Configuration
    typealias ConsentStatus = KetchSDK.ConsentStatus
    typealias ConsentConfig = KetchSDK.ConsentConfig
    typealias ConsentUpdate = KetchSDK.ConsentUpdate
    typealias InvokeRightConfig = KetchSDK.InvokeRightConfig
    typealias Vendors = KetchSDK.Vendors
    typealias LocalizedStrings = KetchSDK.LocalizedStrings

    private let headless: HeadlessApiClient
    private let apiClient: ApiClient

    init(dataCenter: KetchDataCenter = .us, apiClient: ApiClient = DefaultApiClient()) {
        self.apiClient = apiClient
        self.headless = HeadlessApiClient(dataCenter: dataCenter, apiClient: apiClient)
    }

    func fetchLocalizedStrings(languageCode: String = String(Locale.preferredLanguages[0].prefix(2))) -> AnyPublisher<LocalizedStrings, KetchError> {
        apiClient.execute(
            request: ApiRequest(
                endPoint: .localizedStrings(languageCode: languageCode)
            )
        )
        .decode(type: LocalizedStrings.self, decoder: JSONDecoder())
        .mapError(KetchError.init)
        .eraseToAnyPublisher()
    }

    func fetchLocation() -> AnyPublisher<KetchSDK.LocationResponse, KetchError> {
        headless.fetchLocation()
    }

    func fetchBootstrapConfiguration(organization: String, property: String) -> AnyPublisher<Configuration, KetchError> {
        headless.fetchBootstrapConfiguration(organization: organization, property: property)
    }

    func fetchFullConfiguration(request: KetchSDK.FullConfigurationRequest) -> AnyPublisher<Configuration, KetchError> {
        headless.fetchFullConfiguration(request: request)
    }

    func fetchConfig(organization: String, property: String) -> AnyPublisher<Configuration, KetchError> {
        headless.fetchConfig(organization: organization, property: property)
    }

    func fetchConfig(
        organization: String,
        property: String,
        environment: String,
        hash: Int,
        jurisdiction: String,
        language: String
    ) -> AnyPublisher<Configuration, KetchError> {
        headless.fetchConfig(
            organization: organization,
            property: property,
            environment: environment,
            hash: String(hash),
            jurisdiction: jurisdiction,
            language: language
        )
    }

    func fetchConsent(config: ConsentConfig) -> AnyPublisher<ConsentStatus, KetchError> {
        headless.fetchConsent(config: config)
    }

    func fetchProtocols(config: ConsentConfig) -> AnyPublisher<ConsentStatus, KetchError> {
        headless.fetchProtocols(config: config)
    }

    func getConsent(config: ConsentConfig) -> AnyPublisher<ConsentStatus, KetchError> {
        headless.getConsent(config: config)
    }

    func setConsent(update: ConsentUpdate) -> AnyPublisher<ConsentStatus, KetchError> {
        headless.setConsent(update: update)
    }

    func updateConsent(update: ConsentUpdate) -> AnyPublisher<ConsentStatus, KetchError> {
        headless.updateConsent(update: update)
    }

    func invokeRights(organization: String, config: InvokeRightConfig) -> AnyPublisher<Void, KetchError> {
        headless.invokeRights(organization: organization, config: config)
    }

    func getVendors() -> AnyPublisher<Vendors, KetchError> {
        headless.getVendors()
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
