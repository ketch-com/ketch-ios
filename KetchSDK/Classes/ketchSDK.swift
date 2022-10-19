//
//  ketchSDK.swift
//  ketchSDK
//
//  Created by Anton Lyfar on 05.10.2022.
//

import Combine

public class KetchSDK {
    public static let shared = KetchSDK()

    private var subscriptions = Set<AnyCancellable>()

    private init() { }
}

extension KetchSDK {
    public func config(organization: String, property: String) -> AnyPublisher<Configuration, KetchError> {
        KetchApiRequest()
            .fetchConfig(organization: organization, property: organization)
            .eraseToAnyPublisher()
    }

    public func getConsent(consentConfig: ConsentConfig) -> AnyPublisher<ConsentStatus, KetchError> {
        KetchApiRequest()
            .getConsent(config: consentConfig)
            .eraseToAnyPublisher()
    }

    public func setConsent(consentUpdate: ConsentUpdate) -> AnyPublisher<Void, KetchError> {
        KetchApiRequest()
            .updateConsent(update: consentUpdate)
            .eraseToAnyPublisher()
    }

    public func invokeRights(config: InvokeRightConfig) -> AnyPublisher<Void, KetchError> {
        KetchApiRequest()
            .invokeRights(config: config)
            .eraseToAnyPublisher()
    }
}

extension KetchSDK {
    public func fetchConfig(
        organization: String,
        property: String,
        completion: @escaping (Result<Configuration, KetchError>
    ) -> Void) {
        KetchApiRequest()
            .fetchConfig(organization: organization, property: organization)
            .sink { result in
                if case .failure(let error) = result {
                    completion(.failure(error))
                }
            } receiveValue: { configuration in
                completion(.success(configuration))
            }
            .store(in: &subscriptions)
    }

    public func fetchGetConsent(
        consentConfig: ConsentConfig,
        completion: @escaping (Result<ConsentStatus, KetchError>) -> Void
    ) {
        KetchApiRequest()
            .getConsent(config: consentConfig)
            .sink { result in
                if case .failure(let error) = result {
                    completion(.failure(error))
                }
            } receiveValue: { consentStatus in
                completion(.success(consentStatus))
            }
            .store(in: &subscriptions)
    }

    public func fetchSetConsent(
        consentUpdate: ConsentUpdate,
        completion: @escaping (Result<Void, KetchError>) -> Void
    ) {
        KetchApiRequest()
            .updateConsent(update: consentUpdate)
            .sink { result in
                if case .failure(let error) = result {
                    completion(.failure(error))
                }
            } receiveValue: {
                completion(.success(()))
            }
            .store(in: &subscriptions)
    }

    public func fetchInvokeRights(
        config: InvokeRightConfig,
        completion: @escaping (Result<Void, KetchError>) -> Void
    ) {
        KetchApiRequest()
            .invokeRights(config: config)
            .sink { result in
                if case .failure(let error) = result {
                    completion(.failure(error))
                }
            } receiveValue: {
                completion(.success(()))
            }
            .store(in: &subscriptions)
    }
}
