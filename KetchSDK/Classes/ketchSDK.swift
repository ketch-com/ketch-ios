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
    /// Retrieves full organization configuration data.
    /// - Parameters:
    ///   - organization: organization code
    ///   - property: property code
    /// - Returns: Publisher of organization configuration request result.
    public func config(
        organization: String,
        property: String
    ) -> AnyPublisher<Configuration, KetchError> {
        KetchApiRequest()
            .fetchConfig(organization: organization, property: organization)
            .eraseToAnyPublisher()
    }

    /// Retrieves currently set consent status.
    /// - Parameters:
    ///   - organizationCode: organization code
    ///   - controllerCode: controller code
    ///   - propertyCode: property code
    ///   - environmentCode: environment code
    ///   - jurisdictionCode: jurisdiction code
    ///   - identities: map of identity code and value
    ///   - purposes: map of purpose code and PurposeLegalBasis
    /// - Returns: Publisher of set consent request result.
    public func getConsent(
        organizationCode: String,
        controllerCode: String,
        propertyCode: String,
        environmentCode: String,
        jurisdictionCode: String,
        identities: [String : String],
        purposes: [String : ConsentConfig.PurposeLegalBasis]
    ) -> AnyPublisher<ConsentStatus, KetchError> {
        KetchApiRequest()
            .getConsent(
                config: ConsentConfig(
                    organizationCode: organizationCode,
                    controllerCode: controllerCode,
                    propertyCode: propertyCode,
                    environmentCode: environmentCode,
                    jurisdictionCode: jurisdictionCode,
                    identities: identities,
                    purposes: purposes
                )
            )
            .eraseToAnyPublisher()
    }

    /// Sends a request for updating consent status
    /// - Parameters:
    ///   - organizationCode: organization code
    ///   - controllerCode: controller code
    ///   - propertyCode: property code
    ///   - environmentCode: environment code
    ///   - identities: map of identity code and value
    ///   - collectedAt: the current timestamp
    ///   - jurisdictionCode: jurisdiction code
    ///   - migrationOption: migration option.
    ///   - purposes: map of purpose code and PurposeLegalBasis
    ///   - vendors: list of vendors
    /// - Returns: Publisher of get consent request result.
    public func setConsent(
        organizationCode: String,
        controllerCode: String,
        propertyCode: String,
        environmentCode: String,
        identities: [String : String],
        collectedAt: Int?,
        jurisdictionCode: String,
        migrationOption: ConsentUpdate.MigrationOption,
        purposes: [String : ConsentUpdate.PurposeAllowedLegalBasis],
        vendors: [String]?
    ) -> AnyPublisher<Void, KetchError> {
        KetchApiRequest()
            .updateConsent(
                update: ConsentUpdate(
                    organizationCode: organizationCode,
                    controllerCode: controllerCode,
                    propertyCode: propertyCode,
                    environmentCode: environmentCode,
                    identities: identities,
                    collectedAt: collectedAt,
                    jurisdictionCode: jurisdictionCode,
                    migrationOption: migrationOption,
                    purposes: purposes,
                    vendors: vendors
                )
            )
            .eraseToAnyPublisher()
    }

    /// Invokes the specified rights.
    /// - Parameters:
    ///   - organizationCode: organization code
    ///   - controllerCode: controller code
    ///   - propertyCode: property code
    ///   - environmentCode: environment code
    ///   - identities: jurisdiction code
    ///   - invokedAt: the current time
    ///   - jurisdictionCode: map of identity code and value
    ///   - rightCode: right code
    ///   - user: current user object
    /// - Returns: Publisher of invoke rights request result.
    public func invokeRights(
        organizationCode: String,
        controllerCode: String,
        propertyCode: String,
        environmentCode: String,
        identities: [String : String],
        invokedAt: Int?,
        jurisdictionCode: String,
        rightCode: String,
        user: InvokeRightConfig.User
    ) -> AnyPublisher<Void, KetchError> {
        KetchApiRequest()
            .invokeRights(
                config: InvokeRightConfig(
                    organizationCode: organizationCode,
                    controllerCode: controllerCode,
                    propertyCode: propertyCode,
                    environmentCode: environmentCode,
                    identities: identities,
                    invokedAt: invokedAt,
                    jurisdictionCode: jurisdictionCode,
                    rightCode: rightCode,
                    user: user
                )
            )
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
