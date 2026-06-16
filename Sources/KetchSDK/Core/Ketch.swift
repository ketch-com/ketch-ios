//
//  Ketch.swift
//  KetchSDK
//

import Combine
import Foundation

public final class Ketch: ObservableObject {
    /// Identity entity consumable by Ketch
    public struct Identity {
        let key: String
        let value: String
        
        public init(key: String, value: String) {
            self.key = key
            self.value = value
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
    let environmentCode: String
    let identities: [Identity]
    public let dataCenter: KetchDataCenter
    private let apiRequest: KetchApiRequest
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
        dataCenter: KetchDataCenter = .us,
        userDefaults: UserDefaults = .standard
    ) {
        self.organizationCode = organizationCode
        self.propertyCode = propertyCode
        self.environmentCode = environmentCode
        self.identities = identities
        self.dataCenter = dataCenter
        self.apiRequest = KetchApiRequest(dataCenter: dataCenter)
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
        apiRequest
            .fetchConfig(organization: organizationCode, property: propertyCode)
            .sink { result in
                if case .failure(let error) = result {
                    self.configurationSubject.send(completion: .failure(error))
                }
            } receiveValue: { configuration in
                self.configurationSubject.send(configuration)
            }
            .store(in: &subscriptions)
        apiRequest
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
        apiRequest
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
        apiRequest
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

        return apiRequest
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

        loadConsent(
            consentConfig: .init(
                organizationCode: organizationCode,
                propertyCode: propertyCode,
                environmentCode: environmentCode,
                jurisdictionCode: jurisdictionCode,
                identities: identityMap(),
                purposes: purposes
            )
        )
    }

    /// Fetches consent from the CDN without requiring WebView-loaded configuration.
    public func loadConsent(consentConfig: KetchSDK.ConsentConfig) {
        apiRequest
            .fetchConsent(config: consentConfig)
            .sink { result in
                if case .failure(let error) = result {
                    self.consentSubject.send(completion: .failure(error))
                }
            } receiveValue: { consentStatus in
                self.consentSubject.send(consentStatus)
            }
            .store(in: &subscriptions)
    }

    private func identityMap() -> [String: String] {
        [String: String](uniqueKeysWithValues: identities.map { ($0.key, $0.value) })
    }

    public func updateConsent(
        purposes: [String: KetchSDK.ConsentUpdate.PurposeAllowedLegalBasis]?,
        vendors: [String]?,
        protocols: [String: String]?
    ) {
        guard let jurisdictionCode = configurationSubject.value?.jurisdiction?.code else { return }

        return apiRequest
            .setConsent(
                update: .init(
                    organizationCode: organizationCode,
                    propertyCode: propertyCode,
                    environmentCode: environmentCode,
                    identities: identityMap(),
                    jurisdictionCode: jurisdictionCode,
                    migrationOption: .migrateDefault,
                    purposes: purposes ?? [:],
                    vendors: vendors,
                    protocols: nil
                )
            )
            .sink { result in
                if case .failure(let error) = result {
                    print(error)
                }
            } receiveValue: { consentStatus in
                self.consentSubject.send(consentStatus)
            }
            .store(in: &subscriptions)
    }
}

// MARK: - Headless API (web/v3, pre-WebView)
extension Ketch {
    public func fetchLocation(
        completion: @escaping (Result<KetchSDK.LocationResponse, KetchSDK.KetchError>) -> Void
    ) {
        apiRequest.fetchLocation()
            .sink { if case .failure(let error) = $0 { completion(.failure(error)) } }
            receiveValue: { completion(.success($0)) }
            .store(in: &subscriptions)
    }

    public func fetchBootstrapConfiguration(
        completion: @escaping (Result<KetchSDK.Configuration, KetchSDK.KetchError>) -> Void
    ) {
        apiRequest.fetchBootstrapConfiguration(organization: organizationCode, property: propertyCode)
            .sink { if case .failure(let error) = $0 { completion(.failure(error)) } }
            receiveValue: { completion(.success($0)) }
            .store(in: &subscriptions)
    }

    public func fetchFullConfiguration(
        request: KetchSDK.FullConfigurationRequest,
        completion: @escaping (Result<KetchSDK.Configuration, KetchSDK.KetchError>) -> Void
    ) {
        apiRequest.fetchFullConfiguration(request: request)
            .sink { if case .failure(let error) = $0 { completion(.failure(error)) } }
            receiveValue: { completion(.success($0)) }
            .store(in: &subscriptions)
    }

    public func fetchConsent(
        consentConfig: KetchSDK.ConsentConfig,
        completion: @escaping (Result<KetchSDK.ConsentStatus, KetchSDK.KetchError>) -> Void
    ) {
        apiRequest.fetchConsent(config: consentConfig)
            .sink { if case .failure(let error) = $0 { completion(.failure(error)) } }
            receiveValue: { completion(.success($0)) }
            .store(in: &subscriptions)
    }

    public func fetchProtocols(
        consentConfig: KetchSDK.ConsentConfig,
        completion: @escaping (Result<KetchSDK.ConsentStatus, KetchSDK.KetchError>) -> Void
    ) {
        apiRequest.fetchProtocols(config: consentConfig)
            .sink { if case .failure(let error) = $0 { completion(.failure(error)) } }
            receiveValue: { completion(.success($0)) }
            .store(in: &subscriptions)
    }

    public func setConsent(
        consentUpdate: KetchSDK.ConsentUpdate,
        completion: @escaping (Result<KetchSDK.ConsentStatus, KetchSDK.KetchError>) -> Void
    ) {
        apiRequest.setConsent(update: consentUpdate)
            .sink { if case .failure(let error) = $0 { completion(.failure(error)) } }
            receiveValue: { completion(.success($0)) }
            .store(in: &subscriptions)
    }

    public func invokeRight(
        request: KetchSDK.InvokeRightRequest,
        completion: @escaping (Result<Void, KetchSDK.KetchError>) -> Void
    ) {
        apiRequest.invokeRight(request: request)
            .sink { if case .failure(let error) = $0 { completion(.failure(error)) } }
            receiveValue: { completion(.success(())) }
            .store(in: &subscriptions)
    }

    public func getProfile(
        request: KetchSDK.GetProfileRequest,
        completion: @escaping (Result<KetchSDK.GetProfileResponse, KetchSDK.KetchError>) -> Void
    ) {
        apiRequest.getProfile(request: request)
            .sink { if case .failure(let error) = $0 { completion(.failure(error)) } }
            receiveValue: { completion(.success($0)) }
            .store(in: &subscriptions)
    }

    public func putProfile(
        request: KetchSDK.PutProfileRequest,
        completion: @escaping (Result<Void, KetchSDK.KetchError>) -> Void
    ) {
        apiRequest.putProfile(request: request)
            .sink { if case .failure(let error) = $0 { completion(.failure(error)) } }
            receiveValue: { completion(.success(())) }
            .store(in: &subscriptions)
    }

    public func getSubscriptions(
        request: KetchSDK.SubscriptionsRequest,
        completion: @escaping (Result<KetchSDK.SubscriptionsResponse, KetchSDK.KetchError>) -> Void
    ) {
        apiRequest.getSubscriptions(request: request)
            .sink { if case .failure(let error) = $0 { completion(.failure(error)) } }
            receiveValue: { completion(.success($0)) }
            .store(in: &subscriptions)
    }

    public func setSubscriptions(
        request: KetchSDK.SubscriptionsRequest,
        completion: @escaping (Result<Void, KetchSDK.KetchError>) -> Void
    ) {
        apiRequest.setSubscriptions(request: request)
            .sink { if case .failure(let error) = $0 { completion(.failure(error)) } }
            receiveValue: { completion(.success(())) }
            .store(in: &subscriptions)
    }

    public func fetchSubscriptionsConfiguration(
        request: KetchSDK.SubscriptionConfigurationRequest,
        completion: @escaping (Result<KetchSDK.SubscriptionConfiguration, KetchSDK.KetchError>) -> Void
    ) {
        apiRequest.fetchSubscriptionsConfiguration(request: request)
            .sink { if case .failure(let error) = $0 { completion(.failure(error)) } }
            receiveValue: { completion(.success($0)) }
            .store(in: &subscriptions)
    }

    public func preferenceQRUrl(request: KetchSDK.PreferenceQRRequest) -> URL? {
        apiRequest.preferenceQRUrl(request: request)
    }

    public func webReport(
        channel: String,
        request: KetchSDK.WebReportRequest,
        completion: @escaping (Result<Void, KetchSDK.KetchError>) -> Void
    ) {
        apiRequest.webReport(channel: channel, request: request)
            .sink { if case .failure(let error) = $0 { completion(.failure(error)) } }
            receiveValue: { completion(.success(())) }
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
        apiRequest
            .fetchConfig(organization: organization, property: property)
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
        fetchConsent(consentConfig: consentConfig, completion: completion)
    }

    public func fetchSetConsent(
        consentUpdate: KetchSDK.ConsentUpdate,
        completion: @escaping (Result<Void, KetchSDK.KetchError>) -> Void
    ) {
        setConsent(consentUpdate: consentUpdate) { result in
            switch result {
            case .success: completion(.success(()))
            case .failure(let error): completion(.failure(error))
            }
        }
    }

    public func fetchInvokeRights(
        organization: String,
        config: KetchSDK.InvokeRightConfig,
        completion: @escaping (Result<Void, KetchSDK.KetchError>) -> Void
    ) {
        apiRequest
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
