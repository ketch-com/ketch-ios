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
    private let nativeStorage: NativeStorage
    private var plugins = Set<PolicyPlugin>()

    // Headless getFullConfiguration() cache — avoids re-fetching when the config URL path is unchanged
    private var cachedConfig: KetchSDK.Configuration?
    private var cachedConfigKey: String?

    // Headless getLocation() cache — GET /ip takes no path params, so it never needs invalidation
    private var cachedLocation: KetchSDK.LocationResponse?

    private let cacheLock = NSLock()

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
        userDefaults: UserDefaults = .standard,
        apiClient: ApiClient = DefaultApiClient()
    ) {
        self.organizationCode = organizationCode
        self.propertyCode = propertyCode
        self.environmentCode = environmentCode
        self.identities = identities
        self.dataCenter = dataCenter
        self.apiRequest = KetchApiRequest(dataCenter: dataCenter, apiClient: apiClient)
        self.userDefaults = userDefaults
        self.nativeStorage = NativeStorage(userDefaults: userDefaults)

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
            .getConsent(config: consentConfig)
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
                    protocols: protocols
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
    /// GeoIP location (`GET /ip`). Cached on this instance — `/ip` takes no path params, so the
    /// cache never invalidates.
    private func getLocation(
        completion: @escaping (Result<KetchSDK.LocationResponse, KetchSDK.KetchError>) -> Void
    ) {
        cacheLock.lock()
        if let cachedLocation {
            cacheLock.unlock()
            completion(.success(cachedLocation))
            return
        }
        cacheLock.unlock()

        apiRequest.getLocation()
            .sink { if case .failure(let error) = $0 { completion(.failure(error)) } }
            receiveValue: { location in
                self.cacheLock.lock()
                self.cachedLocation = location
                self.cacheLock.unlock()
                completion(.success(location))
            }
            .store(in: &subscriptions)
    }

    /// Combined ISO region code (e.g. "US-CA") from GeoIP. Backed by the same cache as [getLocation].
    public func getRegion(
        completion: @escaping (Result<String?, KetchSDK.KetchError>) -> Void
    ) {
        getLocation { result in
            completion(result.map { $0.location?.toRegionCode() })
        }
    }

    public func getBootstrapConfiguration(
        completion: @escaping (Result<KetchSDK.Configuration, KetchSDK.KetchError>) -> Void
    ) {
        apiRequest.getBootstrapConfiguration(organization: organizationCode, property: propertyCode)
            .sink { if case .failure(let error) = $0 { completion(.failure(error)) } }
            receiveValue: { completion(.success($0)) }
            .store(in: &subscriptions)
    }

    /// Full config with optional env/jurisdiction/language and hash query param.
    ///
    /// Cached on this instance, keyed on the request's URL-path-affecting fields. A cache hit
    /// skips the network call entirely.
    public func getFullConfiguration(
        request: KetchSDK.FullConfigurationRequest,
        completion: @escaping (Result<KetchSDK.Configuration, KetchSDK.KetchError>) -> Void
    ) {
        let key = Self.buildConfigCacheKey(for: request)
        cacheLock.lock()
        if cachedConfigKey == key, let cachedConfig {
            cacheLock.unlock()
            completion(.success(cachedConfig))
            return
        }
        cacheLock.unlock()

        apiRequest.getFullConfiguration(request: request)
            .sink { if case .failure(let error) = $0 { completion(.failure(error)) } }
            receiveValue: { configuration in
                self.cacheLock.lock()
                self.cachedConfig = configuration
                self.cachedConfigKey = key
                self.cacheLock.unlock()
                completion(.success(configuration))
            }
            .store(in: &subscriptions)
    }

    /// Resolved jurisdiction code for this instance's current org/property/environment, e.g. from
    /// a `jurisdiction` `ExperienceOption`. Backed by the same cache as [getFullConfiguration].
    public func getJurisdiction(
        completion: @escaping (Result<String?, KetchSDK.KetchError>) -> Void
    ) {
        getFullConfiguration(request: buildJurisdictionConfigRequest()) { result in
            completion(result.map { $0.jurisdiction?.code ?? $0.jurisdiction?.defaultJurisdictionCode })
        }
    }

    private func buildJurisdictionConfigRequest() -> KetchSDK.FullConfigurationRequest {
        .init(
            organizationCode: organizationCode,
            propertyCode: propertyCode,
            environmentCode: environmentCode
        )
    }

    // Cache key for getFullConfiguration() — mirrors HeadlessApiClient's path-building exactly
    // (blank treated as absent) via configPathSegment()/normalizedHash(), so requests that hit the
    // same URL always share a key and requests that hit different URLs never collide.
    private static func buildConfigCacheKey(for request: KetchSDK.FullConfigurationRequest) -> String {
        let segment = request.configPathSegment()
        return [
            request.organizationCode,
            request.propertyCode,
            segment?.env ?? "",
            segment?.jurisdiction ?? "",
            segment?.language ?? "",
            request.normalizedHash() ?? ""
        ].joined(separator: "|")
    }

    public func getConsent(
        consentConfig: KetchSDK.ConsentConfig,
        completion: @escaping (Result<KetchSDK.ConsentStatus, KetchSDK.KetchError>) -> Void
    ) {
        apiRequest.getConsent(config: consentConfig)
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

    public func getPreferenceQRUrl(request: KetchSDK.PreferenceQRRequest) -> URL? {
        apiRequest.getPreferenceQRUrl(request: request)
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
        getConsent(consentConfig: consentConfig, completion: completion)
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
        nativeStorage.set(version, forKey: CONSENT_VERSION)
    }

    func getConsentVersion() -> Int? {
        nativeStorage.value(forKey: CONSENT_VERSION) as? Int
    }

    func updatePreferenceVersion(version: Int?) {
        nativeStorage.set(version, forKey: PREFERENCE_VERSION)
    }

    func getPreferenceVersion() -> Int? {
        nativeStorage.value(forKey: PREFERENCE_VERSION) as? Int
    }
}
