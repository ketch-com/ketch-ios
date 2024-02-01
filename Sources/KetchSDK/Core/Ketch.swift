//
//  Ketch.swift
//  KetchSDK
//

import Combine
import Foundation

public final class Ketch: ObservableObject {
    /// Identity entity consumable by Ketch
    public enum Identity {
        case idfa(String) // Default identity for iOS (AdvertisementIdentifier)
        case custom(key: String, value: String)

        var key: String {
            switch self {
            case .idfa: return "idfa"
            case .custom(let key, _): return key
            }
        }

        var value: String {
            switch self {
            case .idfa(let id): return id
            case .custom(_, let value): return value
            }
        }
    }

    /// Configuration updates stream
    @Published public var configuration: KetchSDK.Configuration?
    
    /// Localize Strings updates stream
    @Published public var localizedStrings: KetchSDK.LocalizedStrings?

    /// Consent updates stream
    @Published public var consent: KetchSDK.ConsentStatus?

    let organizationCode: String
    let propertyCode: String
    private let environmentCode: String
    let identities: [Identity]
    private let userDefaults: UserDefaults
    private var plugins = Set<PolicyPlugin>()

    private var configurationSubject = CurrentValueSubject<KetchSDK.Configuration?, KetchSDK.KetchError>(nil)
    private var localizedStringsSubject = CurrentValueSubject<KetchSDK.LocalizedStrings?, KetchSDK.KetchError>(nil)
    private var consentSubject = CurrentValueSubject<KetchSDK.ConsentStatus?, KetchSDK.KetchError>(nil)
    private var subscriptions = Set<AnyCancellable>()

    /// Instantiation of Ketch class
    /// - Parameters:
    ///   - organizationCode: Organization defined in the platform side.
    ///   - propertyCode: Property defined in the platform side.
    ///   - environmentCode: Environment defined in the platform side.
    ///   - identities: Identifiers of current instance of app. Possible types defined in the platform side. For iOS it is usually "idfa" (AdvertisementIdentifier)
    ///   - userDefaults: UserDefaults where consent processing result will be stored by Plugins
    init(
        organizationCode: String,
        propertyCode: String,
        environmentCode: String,
        identities: [Identity],
        userDefaults: UserDefaults = .standard
    ) {
        self.organizationCode = organizationCode
        self.propertyCode = propertyCode
        self.environmentCode = environmentCode
        self.identities = identities
        self.userDefaults = userDefaults

        configurationSubject
            .replaceError(with: nil)
            .compactMap { $0 }
            .sink { configuration in
                self.plugins.forEach { plugin in
                    plugin.configLoaded(configuration)
                }

                DispatchQueue.main.async {
                    self.configuration = configuration
                }
            }
            .store(in: &subscriptions)
        
        localizedStringsSubject
            .replaceError(with: nil)
            .compactMap { $0 }
            .sink { localizedStrings in
                DispatchQueue.main.async {
                    self.localizedStrings = localizedStrings
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

                DispatchQueue.main.async {
                    self.consent = consentStatus
                }
            }
            .store(in: &subscriptions)
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
        KetchApiRequest()
            .fetchLocalizedStrings()
            .sink { result in
                if case .failure(let error) = result {
                    self.localizedStringsSubject.send(completion: .failure(error))
                }
            } receiveValue: { localizedStrings in
                self.localizedStringsSubject.send(localizedStrings)
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
                language: String(Locale.preferredLanguages[0].prefix(2))
            )
            .sink { result in
                if case .failure(let error) = result {
                    self.configurationSubject.send(completion: .failure(error))
                }
            } receiveValue: { configuration in
                self.configurationSubject.send(configuration)
            }
            .store(in: &subscriptions)
        KetchApiRequest()
            .fetchLocalizedStrings(languageCode:String(Locale.preferredLanguages[0].prefix(2)))
            .sink { result in
                if case .failure(let error) = result {
                    self.localizedStringsSubject.send(completion: .failure(error))
                }
            } receiveValue: { localizedStrings in
                self.localizedStringsSubject.send(localizedStrings)
            }
            .store(in: &subscriptions)
    }

    public func invokeRights(
        right: KetchSDK.Configuration.Right?,
        user: KetchSDK.InvokeRightConfig.User
    ) {
        guard let jurisdictionCode = configurationSubject.value?.jurisdiction?.code else { return }

        let invokedAt = Int(Date().timeIntervalSince1970 * 1000)
        let identities = [String: String](
            uniqueKeysWithValues: identities.map { ($0.key, $0.value) }
        )

        return KetchApiRequest()
            .invokeRights(
                organization: organizationCode,
                config: .init(
                    propertyCode: propertyCode,
                    environmentCode: environmentCode,
                    jurisdictionCode: jurisdictionCode,
                    invokedAt: invokedAt,
                    identities: identities,
                    rightCode: right?.code,
                    user: user
                )
            )
            .sink { result in
                if case .failure(let error) = result {
                    print(error)
                }
            } receiveValue: {
                self.rightInvoked(
                    property: self.propertyCode,
                    environment: self.environmentCode,
                    invokedAt: invokedAt,
                    identities: identities,
                    right: right?.code,
                    user: user
                )
            }
            .store(in: &subscriptions)
    }

    private func rightInvoked(
        property: String,
        environment: String,
        invokedAt: Int?,
        identities: [String: String],
        right: String?,
        user: KetchSDK.InvokeRightConfig.User
    ) {
        plugins.forEach { plugin in
            plugin.rightInvoked(
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

        let identities = [String: String](
            uniqueKeysWithValues: identities.map { ($0.key, $0.value) }
        )

        KetchApiRequest()
            .getConsent(
                config: .init(
                    organizationCode: organizationCode,
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
        purposes: [String: KetchSDK.ConsentUpdate.PurposeAllowedLegalBasis]?,
        vendors: [String]?
    ) {
        guard let jurisdictionCode = configurationSubject.value?.jurisdiction?.code else { return }

        let identities = [String: String](
            uniqueKeysWithValues: identities.map { ($0.key, $0.value) }
        )
        
        return KetchApiRequest()
            .updateConsent(
                update: .init(
                    organizationCode: organizationCode,
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

// MARK: - Publishers with error.
extension Ketch {
    /// Configuration updates stream
    public var configurationPublisher: AnyPublisher<KetchSDK.Configuration?, KetchSDK.KetchError> {
        configurationSubject.eraseToAnyPublisher()
    }

    /// Consent updates stream
    public var consentPublisher: AnyPublisher<KetchSDK.ConsentStatus?, KetchSDK.KetchError> {
        consentSubject.eraseToAnyPublisher()
    }
}

// MARK: - Requests helper methods with completion closures
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

// MARK: - Plugin features interface.
extension Ketch {
    /// Adding plugin for consent events handling
    /// - Parameter plugin: Entity that can handle consent events.
    public func add(plugin: PolicyPlugin) {
        plugins.insert(plugin)
    }

    /// Adding plugins for consent events handling
    /// - Parameter plugin: Entities that can handle consent events.
    public func add(plugins: [PolicyPlugin]) {
        plugins.forEach {
            self.plugins.insert($0)
        }
    }

    /// Removing plugin from Ketch handling list
    /// - Parameter plugin: Entity which should be removed from handle consent events.
    public func remove(plugin: PolicyPlugin) {
        plugins.remove(plugin)
    }

    /// Removing all applied plugins from Ketch handling list
    public func removeAllPlugins() {
        plugins = []
    }

    /// Check if Plugin is currently handling events
    /// - Parameter plugin: Plugin entity for check
    /// - Returns: Result is Plugin is already added
    public func contains(plugin: PolicyPlugin) -> Bool {
        plugins.contains(plugin)
    }
}

private let CONSENT_VERSION = "consent_version"
private let PREFERENCE_VERSION = "preference_version"

// MARK: - Internal interface for storage usage
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
