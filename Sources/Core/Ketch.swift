//
//  Ketch.swift
//  KetchSDK
//
//  Created by Anton Lyfar on 01.11.2022.
//

import Combine

public class Ketch {
    public let organizationCode: String
    public let propertyCode: String
    public let environmentCode: String
    public let controllerCode: String
    public let identities: [String: String]

    private var subscriptions = Set<AnyCancellable>()
    private var plugins = Set<PolicyPlugin>()

    let userDefaults: UserDefaults

    init(
        organizationCode: String,
        propertyCode: String,
        environmentCode: String,
        controllerCode: String,
        identities: [String : String],
        userDefaults: UserDefaults = .standard
    ) {
        self.organizationCode = organizationCode
        self.propertyCode = propertyCode
        self.environmentCode = environmentCode
        self.controllerCode = controllerCode
        self.identities = identities
        self.userDefaults = userDefaults

        configurationSubject
            .replaceError(with: nil)
            .compactMap { $0 }
            .sink { configuration in
                self.plugins.forEach { plugin in
                    plugin.configLoaded(configuration)
                }
            }
            .store(in: &subscriptions)

        consentSubject
            .replaceError(with: nil)
            .compactMap { $0 }
            .sink { consentStatus in
                self.plugins.forEach { plugin in
                    plugin.consentChanged(consentStatus)
                }
            }
            .store(in: &subscriptions)
    }

    private var configurationSubject = CurrentValueSubject<KetchSDK.Configuration?, KetchSDK.KetchError>(nil)
    var configurationPublisher: AnyPublisher<KetchSDK.Configuration?, KetchSDK.KetchError> {
        configurationSubject.eraseToAnyPublisher()
    }

    private var consentSubject = CurrentValueSubject<KetchSDK.ConsentStatus?, KetchSDK.KetchError>(nil)
    var consentPublisher: AnyPublisher<KetchSDK.ConsentStatus?, KetchSDK.KetchError> {
        consentSubject.eraseToAnyPublisher()
    }

    public func loadConfiguration() {
        KetchApiRequest()
            .fetchConfig(organization: organizationCode, property: propertyCode)
            .sink { result in
                if case .failure(let error) = result {
                    self.configurationSubject.send(completion: .failure(error))
                }
            } receiveValue: { configuration in
                self.configurationSubject.send(configuration)
            }
            .store(in: &subscriptions)
    }

    public func loadConfiguration(
        jurisdiction: String
    ) {
        KetchApiRequest()
            .fetchConfig(
                organization: organizationCode,
                property: propertyCode,
                environment: environmentCode,
                hash: Int(Date().timeIntervalSince1970 * 1000),
                jurisdiction: jurisdiction,
                language: Locale.current.languageCode ?? "en"
            )
            .sink { result in
                if case .failure(let error) = result {
                    self.configurationSubject.send(completion: .failure(error))
                }
            } receiveValue: { configuration in
                self.configurationSubject.send(configuration)
            }
            .store(in: &subscriptions)
    }

    public func invokeRights(
        right: String? = nil,
        user: KetchSDK.InvokeRightConfig.User
    ) {
        guard let jurisdictionCode = configurationSubject.value?.jurisdiction?.code else { return }

        let invokedAt = Int(Date().timeIntervalSince1970 * 1000)

        return KetchApiRequest()
            .invokeRights(
                organization: organizationCode,
                config: .init(
                    controllerCode: controllerCode,
                    propertyCode: propertyCode,
                    environmentCode: environmentCode,
                    jurisdictionCode: jurisdictionCode,
                    invokedAt: invokedAt,
                    identities: identities,
                    rightCode: right ?? configurationSubject.value?.rights?.first?.code,
                    user: user
                )
            )
            .sink { result in
                if case .failure(let error) = result {
                    print(error)
                }
            } receiveValue: {
                self.rightInvoked(
                    controller: self.controllerCode,
                    property: self.propertyCode,
                    environment: self.environmentCode,
                    invokedAt: invokedAt,
                    identities: self.identities,
                    right: right,
                    user: user
                )
            }
            .store(in: &subscriptions)
    }

    private func rightInvoked(
        controller: String?,
        property: String,
        environment: String,
        invokedAt: Int?,
        identities: [String: String],
        right: String?,
        user: KetchSDK.InvokeRightConfig.User
    ) {
        plugins.forEach { plugin in
            plugin.rightInvoked(
                controller: controller,
                property: property,
                environment: environment,
                invokedAt: invokedAt,
                identities: identities,
                right: right,
                user: user
            )
        }
    }

    public func loadConsent() {
        guard let jurisdictionCode = configurationSubject.value?.jurisdiction?.code else { return }

        guard
            let purposes = configurationSubject.value?.purposes?
                .reduce(into: [String: KetchSDK.ConsentConfig.PurposeLegalBasis](), { result, purpose in
                    result[purpose.code] = .init(legalBasisCode: purpose.legalBasisCode)
                })
        else { return }

        KetchApiRequest()
            .getConsent(
                config: .init(
                    organizationCode: organizationCode,
                    controllerCode: controllerCode,
                    propertyCode: propertyCode,
                    environmentCode: environmentCode,
                    jurisdictionCode: jurisdictionCode,
                    identities: identities,
                    purposes: purposes
                )
            )
            .sink { result in
                if case .failure(let error) = result {
                    self.consentSubject.send(completion: .failure(error))
                }
            } receiveValue: { consentStatus in
                self.consentSubject.send(consentStatus)
            }
            .store(in: &subscriptions)
    }

    public func updateConsent(
        purposes: [String: KetchSDK.ConsentUpdate.PurposeAllowedLegalBasis]? = nil,
        vendors: [String]? = nil
    ) {
        guard let jurisdictionCode = configurationSubject.value?.jurisdiction?.code else { return }

        let purposes = purposes ?? configurationSubject.value?.purposes?
            .reduce(into: [String: KetchSDK.ConsentUpdate.PurposeAllowedLegalBasis](), { result, purpose in
                result[purpose.code] = .init(allowed: true, legalBasisCode: purpose.legalBasisCode)
            })

        let vendors = vendors ?? configurationSubject.value?.vendors?.map(\.id)

        return KetchApiRequest()
            .updateConsent(
                update: .init(
                    organizationCode: organizationCode,
                    controllerCode: controllerCode,
                    propertyCode: propertyCode,
                    environmentCode: environmentCode,
                    identities: identities,
                    jurisdictionCode: jurisdictionCode,
                    migrationOption: .migrateDefault,
                    purposes: purposes ?? [:],
                    vendors: vendors
                )
            )
            .sink { result in
                if case .failure(let error) = result {
                    print(error)
                }
            } receiveValue: {
                let purposesUpdate = purposes?.reduce(into: [String: Bool](), { result, purpose in
                    result[purpose.key] = purpose.value.allowed
                })
                let consentUpdate = KetchSDK.ConsentStatus(
                    purposes: purposesUpdate ?? [:],
                    vendors: vendors
                )

                self.consentSubject.send(consentUpdate)
            }
            .store(in: &subscriptions)
    }
}

extension Ketch {
    public func fetchConfig(
        organization: String,
        property: String,
        completion: @escaping (Result<KetchSDK.Configuration, KetchSDK.KetchError>
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
        consentConfig: KetchSDK.ConsentConfig,
        completion: @escaping (Result<KetchSDK.ConsentStatus, KetchSDK.KetchError>) -> Void
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
        consentUpdate: KetchSDK.ConsentUpdate,
        completion: @escaping (Result<Void, KetchSDK.KetchError>) -> Void
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
        organization: String,
        config: KetchSDK.InvokeRightConfig,
        completion: @escaping (Result<Void, KetchSDK.KetchError>) -> Void
    ) {
        KetchApiRequest()
            .invokeRights(
                organization: organization,
                config: config
            )
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

extension Ketch {
    public func add(plugin: PolicyPlugin) {
        plugins.insert(plugin)
    }

    public func add(plugins: [PolicyPlugin]) {
        plugins.forEach {
            self.plugins.insert($0)
        }
    }

    public func remove(plugin: PolicyPlugin) {
        plugins.remove(plugin)
    }

    public func removeAllPlugins() {
        plugins = []
    }

    public func contains(plugin: PolicyPlugin) -> Bool {
        plugins.contains(plugin)
    }
}

private let CONSENT_VERSION = "consent_version"
private let PREFERENCE_VERSION = "preference_version"

extension Ketch {
    func updateConsentVersion(version: Int?) {
        userDefaults.set(version, forKey: CONSENT_VERSION)
    }

    func getConsentVersion() -> Int? {
        userDefaults.value(forKey: CONSENT_VERSION) as? Int
    }

    func updatePreferenceVersion(version: Int?) {
        userDefaults.set(version, forKey: PREFERENCE_VERSION)
    }

    func getPreferenceVersion() -> Int? {
        userDefaults.value(forKey: PREFERENCE_VERSION) as? Int
    }
}
