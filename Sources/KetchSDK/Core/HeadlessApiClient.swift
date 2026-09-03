//
//  HeadlessApiClient.swift
//  KetchSDK
//
//  Native HTTP client mirroring ketch-tag KetchWebAPI (web/v3).
//

import Combine
import Foundation

/// Builds v3 CDN URLs and performs headless API calls.
final class HeadlessApiClient {
    typealias KetchError = KetchSDK.KetchError
    typealias Configuration = KetchSDK.Configuration
    typealias ConsentStatus = KetchSDK.ConsentStatus
    typealias ConsentConfig = KetchSDK.ConsentConfig
    typealias ConsentUpdate = KetchSDK.ConsentUpdate

    private let baseURL: URL
    private let apiClient: ApiClient
    private let managedIdentity: ManagedIdentityResolver

    init(
        dataCenter: KetchDataCenter = .us,
        apiClient: ApiClient = DefaultApiClient(),
        managedIdentity: ManagedIdentityResolver = .shared
    ) {
        self.baseURL = dataCenter.baseURL
        self.apiClient = apiClient
        self.managedIdentity = managedIdentity
    }

    func getLocation() -> AnyPublisher<KetchSDK.LocationResponse, KetchError> {
        get(path: "/ip")
            .decode(type: KetchSDK.LocationResponse.self, decoder: JSONDecoder())
            .mapError(KetchError.init)
            .eraseToAnyPublisher()
    }

    func getBootstrapConfiguration(
        organization: String,
        property: String
    ) -> AnyPublisher<Configuration, KetchError> {
        get(path: "/config/\(organization)/\(property)/boot.json")
            .decode(type: Configuration.self, decoder: JSONDecoder())
            .mapError(KetchError.init)
            .eraseToAnyPublisher()
    }

    func getFullConfiguration(
        request: KetchSDK.FullConfigurationRequest
    ) -> AnyPublisher<Configuration, KetchError> {
        var path = "/config/\(request.organizationCode)/\(request.propertyCode)"
        if let segment = request.configPathSegment() {
            path += "/\(segment.env)/\(segment.jurisdiction)/\(segment.language)"
        }
        path += "/config.json"
        return get(path: path, queryItems: request.configQueryItems())
            .decode(type: Configuration.self, decoder: JSONDecoder())
            .mapError(KetchError.init)
            .eraseToAnyPublisher()
    }

    /// The `identities` section of a property's configuration.
    func getIdentityConfiguration(
        organization: String,
        property: String
    ) -> AnyPublisher<[String: KetchSDK.IdentityDefinition]?, KetchError> {
        get(
            path: "/config/\(organization)/\(property)/config.json",
            queryItems: [URLQueryItem(name: "include", value: "identities")]
        )
        .decode(type: IdentityConfigurationResponse.self, decoder: JSONDecoder())
        .mapError(KetchError.init)
        .map(\.identities)
        .handleEvents(receiveOutput: { identities in
            if identities == nil {
                KetchLogger.log.warning(
                    "Config for \(organization)/\(property) carried no identities key; treating as no managed identity"
                )
            }
        })
        .eraseToAnyPublisher()
    }

    /// Adds the Ketch-managed identifier to `identities`.
    ///
    /// Without a property code the identity space cannot be looked up, so the identifier already
    /// resolved is reused. Omitting it is worse than reusing it.
    private func withManagedIdentity(
        _ identities: [String: String],
        organization: String,
        property: String?
    ) -> AnyPublisher<[String: String], Never> {
        guard let property, !property.isEmpty else {
            return Just(ManagedIdentity.merged(identities, with: managedIdentity.lastResolved()))
                .eraseToAnyPublisher()
        }
        return managedIdentity.resolve(
            organizationCode: organization,
            propertyCode: property,
            loadConfig: { [weak self] in
                guard let self else {
                    return Fail(error: KetchError.requestError).eraseToAnyPublisher()
                }
                return self.getIdentityConfiguration(organization: organization, property: property)
                    .mapError { $0 as Error }
                    .eraseToAnyPublisher()
            }
        )
        .map { ManagedIdentity.merged(identities, with: $0) }
        .eraseToAnyPublisher()
    }

    /// The encoded request body for `makePayload`, with the Ketch-managed identifier merged into
    /// the identities handed to it.
    ///
    /// Every identity-bearing endpoint needs the same three steps -- resolve, merge, encode -- and
    /// only the payload type differs, so the call sites supply just that.
    private func identifiedBody<Payload: Encodable>(
        identities: [String: String],
        organization: String,
        property: String?,
        _ makePayload: @escaping ([String: String]) -> Payload
    ) -> AnyPublisher<Data, KetchError> {
        withManagedIdentity(identities, organization: organization, property: property)
            .tryMap { try JSONEncoder().encode(makePayload($0)) }
            .mapError { _ in KetchError.requestError }
            .eraseToAnyPublisher()
    }

    func getConsent(config: ConsentConfig) -> AnyPublisher<ConsentStatus, KetchError> {
        let path = "/consent/\(config.organizationCode)/get"
        return identifiedBody(
            identities: config.identities,
            organization: config.organizationCode,
            property: config.propertyCode
        ) { ConsentConfigPayload(config: config.withIdentities($0)) }
        .flatMap { self.postConsent(path: path, body: $0, config: config) }
        .eraseToAnyPublisher()
    }

    /// Returns server consent including computed `protocols`; omits `protocols` from request body.
    func setConsent(update: ConsentUpdate) -> AnyPublisher<ConsentStatus, KetchError> {
        let path = "/consent/\(update.organizationCode)/update"
        return identifiedBody(
            identities: update.identities,
            organization: update.organizationCode,
            property: update.propertyCode
        ) { SetConsentPayload(update: update.withIdentities($0)) }
        .flatMap { self.postSetConsent(path: path, body: $0, fallback: update) }
        .eraseToAnyPublisher()
    }

    // MARK: - Legacy v3 endpoints (used by existing KetchApiRequest)

    func fetchConfig(organization: String, property: String) -> AnyPublisher<Configuration, KetchError> {
        getFullConfiguration(
            request: .init(
                organizationCode: organization,
                propertyCode: property,
                languageCode: KetchSDK.FullConfigurationRequest.deviceLanguageTag()
            )
        )
    }

    func fetchConfig(
        organization: String,
        property: String,
        environment: String,
        hash: String,
        jurisdiction: String,
        language: String
    ) -> AnyPublisher<Configuration, KetchError> {
        getFullConfiguration(
            request: .init(
                organizationCode: organization,
                propertyCode: property,
                environmentCode: environment,
                jurisdictionCode: jurisdiction,
                languageCode: language,
                hash: hash
            )
        )
    }

    func invokeRight(request: KetchSDK.InvokeRightRequest) -> AnyPublisher<Void, KetchError> {
        let path = "/rights/\(request.organizationCode)/invoke"
        return identifiedBody(
            identities: request.identities,
            organization: request.organizationCode,
            property: request.propertyCode
        ) { request.withIdentities($0) }
        .flatMap { self.postVoid(path: path, body: $0) }
        .eraseToAnyPublisher()
    }

    func getSubscriptions(
        request: KetchSDK.SubscriptionsRequest
    ) -> AnyPublisher<KetchSDK.SubscriptionsResponse, KetchError> {
        let path = "/subscriptions/\(request.organizationCode)/get"
        return identifiedBody(
            identities: request.identities ?? [:],
            organization: request.organizationCode,
            property: request.propertyCode
        ) { request.withIdentities($0) }
        .flatMap { self.post(path: path, body: $0) }
        .decode(type: KetchSDK.SubscriptionsResponse.self, decoder: JSONDecoder())
        .mapError(KetchError.init)
        .eraseToAnyPublisher()
    }

    func setSubscriptions(request: KetchSDK.SubscriptionsRequest) -> AnyPublisher<Void, KetchError> {
        let path = "/subscriptions/\(request.organizationCode)/update"
        return identifiedBody(
            identities: request.identities ?? [:],
            organization: request.organizationCode,
            property: request.propertyCode
        ) { request.withIdentities($0) }
        .flatMap { self.postVoid(path: path, body: $0) }
        .eraseToAnyPublisher()
    }

    func invokeRights(organization: String, config: KetchSDK.InvokeRightConfig) -> AnyPublisher<Void, KetchError> {
        guard let rightCode = config.rightCode, !rightCode.isEmpty else {
            return Fail(error: KetchError.requestError).eraseToAnyPublisher()
        }
        return invokeRight(request: .init(organizationCode: organization, config: config))
    }

    func getPreferenceQRUrl(request: KetchSDK.PreferenceQRRequest) -> URL? {
        var pairs: [(String, String)] = []
        if let environmentCode = request.environmentCode {
            pairs.append(("env", environmentCode))
        }
        if let imageSize = request.imageSize {
            pairs.append(("size", String(imageSize)))
        }
        if let path = request.path {
            pairs.append(("path", path))
        }
        if let backgroundColor = request.backgroundColor {
            pairs.append(("bgcolor", backgroundColor))
        }
        if let foregroundColor = request.foregroundColor {
            pairs.append(("fgcolor", foregroundColor))
        }
        for (key, value) in request.parameters {
            pairs.append((key, value))
        }
        guard let base = buildURL(
            path: "/qr/\(request.organizationCode)/\(request.propertyCode)/preferences.png"
        ) else {
            return nil
        }
        guard !pairs.isEmpty else {
            return base
        }
        let query = pairs
            .map { "\($0.0)=\(Self.encodeURIComponent($0.1))" }
            .joined(separator: "&")
        return URL(string: base.absoluteString + "?" + query)
    }

    /// Matches JavaScript `encodeURIComponent` (ketch-tag `URL.searchParams`).
    private static func encodeURIComponent(_ value: String) -> String {
        var allowed = CharacterSet.alphanumerics
        allowed.insert(charactersIn: "-_.~")
        return value.addingPercentEncoding(withAllowedCharacters: allowed) ?? value
    }

    // MARK: - Networking

    private func get(path: String, queryItems: [URLQueryItem] = []) -> AnyPublisher<Data, KetchError> {
        guard let url = buildURL(path: path, queryItems: queryItems) else {
            return Fail(error: KetchError.requestError).eraseToAnyPublisher()
        }
        let request = ApiRequest(
            endPoint: EndPoint(url: url),
            method: .get,
            body: nil
        )
        return apiClient.execute(request: request)
            .mapError { KetchError(with: $0) }
            .eraseToAnyPublisher()
    }

    private func post(path: String, body: Data) -> AnyPublisher<Data, KetchError> {
        guard let url = buildURL(path: path) else {
            return Fail(error: KetchError.requestError).eraseToAnyPublisher()
        }
        let request = ApiRequest(
            endPoint: EndPoint(url: url),
            method: .post,
            body: body
        )
        return apiClient.execute(request: request)
            .mapError { KetchError(with: $0) }
            .eraseToAnyPublisher()
    }

    private func postVoid(path: String, body: Data) -> AnyPublisher<Void, KetchError> {
        guard let url = buildURL(path: path) else {
            return Fail(error: KetchError.requestError).eraseToAnyPublisher()
        }
        let request = ApiRequest(endPoint: EndPoint(url: url), method: .post, body: body)
        return apiClient.execute(request: request)
            .map { _ in () }
            .mapError { KetchError(with: $0) }
            .eraseToAnyPublisher()
    }

    private func postConsent(
        path: String,
        body: Data,
        config: ConsentConfig
    ) -> AnyPublisher<ConsentStatus, KetchError> {
        guard let url = buildURL(path: path) else {
            return Fail(error: KetchError.requestError).eraseToAnyPublisher()
        }
        let request = ApiRequest(endPoint: EndPoint(url: url), method: .post, body: body)
        return apiClient.execute(request: request)
            .map { data -> ConsentStatus in
                if data.isEmpty || String(data: data, encoding: .utf8) == "null" {
                    return Self.emptyConsentStatus(for: config)
                }
                if let decoded = try? JSONDecoder().decode(ConsentStatus.self, from: data),
                   Self.hasUsableConsentFields(decoded) {
                    return decoded
                }
                return Self.emptyConsentStatus(for: config)
            }
            .mapError { KetchError(with: $0) }
            .eraseToAnyPublisher()
    }

    private func postSetConsent(
        path: String,
        body: Data,
        fallback: ConsentUpdate
    ) -> AnyPublisher<ConsentStatus, KetchError> {
        guard let url = buildURL(path: path) else {
            return Fail(error: KetchError.requestError).eraseToAnyPublisher()
        }
        let request = ApiRequest(endPoint: EndPoint(url: url), method: .post, body: body)
        return apiClient.execute(request: request)
            .tryMap { data -> ConsentStatus in
                // Empty / null body: server accepted the write with no payload — mirror
                // Android / Flutter / RN and synthesize status from the request.
                if data.isEmpty || String(data: data, encoding: .utf8) == "null" {
                    return Self.consentStatus(from: fallback)
                }
                if let decoded = try? JSONDecoder().decode(ConsentStatus.self, from: data),
                   Self.hasUsableConsentFields(decoded) {
                    return Self.mergingProtocols(from: decoded, fallback: fallback)
                }
                // Valid JSON without usable consent fields — same empty-response fallback.
                if let object = try? JSONSerialization.jsonObject(with: data),
                   object is [String: Any] || object is [Any] {
                    return Self.consentStatus(from: fallback)
                }
                throw KetchError.decodingError(message: "Unparseable setConsent response")
            }
            .mapError { error -> KetchError in
                if let ketchError = error as? KetchError {
                    return ketchError
                }
                return KetchError(with: error)
            }
            .eraseToAnyPublisher()
    }

    func buildURL(path: String, queryItems: [URLQueryItem] = []) -> URL? {
        guard var components = URLComponents(url: baseURL, resolvingAgainstBaseURL: true) else {
            return nil
        }
        let normalized = path.hasPrefix("/") ? path : "/\(path)"
        let basePath = components.path.hasSuffix("/") ? String(components.path.dropLast()) : components.path
        components.path = basePath + normalized
        if !queryItems.isEmpty {
            components.queryItems = queryItems
        }
        return components.url
    }

    private static func hasUsableConsentFields(_ status: ConsentStatus) -> Bool {
        if let purposes = status.purposes, !purposes.isEmpty { return true }
        if let vendors = status.vendors, !vendors.isEmpty { return true }
        if let protocols = status.protocols, !protocols.isEmpty { return true }
        return false
    }

    private static func emptyConsentStatus(for config: ConsentConfig) -> ConsentStatus {
        ConsentStatus(purposes: [:], vendors: nil, protocols: nil)
    }

    private static func consentStatus(from update: ConsentUpdate) -> ConsentStatus {
        let purposes = update.purposes.reduce(into: [String: Bool]()) { result, entry in
            result[entry.key] = entry.value.allowed
        }
        return ConsentStatus(
            purposes: purposes,
            vendors: update.vendors,
            protocols: update.protocols
        )
    }

    /// Keeps server-computed protocols when present; otherwise preserves caller-supplied strings (e.g. GPP).
    private static func mergingProtocols(from status: ConsentStatus, fallback: ConsentUpdate) -> ConsentStatus {
        guard let callerProtocols = fallback.protocols, !callerProtocols.isEmpty else {
            return status
        }
        if let responseProtocols = status.protocols, !responseProtocols.isEmpty {
            return status
        }
        return ConsentStatus(
            purposes: status.purposes,
            vendors: status.vendors,
            protocols: callerProtocols
        )
    }
}

// MARK: - Request payloads

private struct ConsentConfigPayload: Encodable {
    let organizationCode: String
    let propertyCode: String
    let environmentCode: String
    let jurisdictionCode: String
    let identities: [String: String]
    let purposes: [String: KetchSDK.ConsentConfig.PurposeLegalBasis]

    init(config: KetchSDK.ConsentConfig) {
        organizationCode = config.organizationCode
        propertyCode = config.propertyCode
        environmentCode = config.environmentCode
        jurisdictionCode = config.jurisdictionCode
        identities = config.identities
        purposes = config.purposes
    }
}

private struct SetConsentPayload: Encodable {
    let organizationCode: String
    let propertyCode: String
    let environmentCode: String
    let identities: [String: String]
    let jurisdictionCode: String
    let migrationOption: KetchSDK.ConsentUpdate.MigrationOption
    let purposes: [String: KetchSDK.ConsentUpdate.PurposeAllowedLegalBasis]
    let vendors: [String]?

    init(update: KetchSDK.ConsentUpdate) {
        organizationCode = update.organizationCode
        propertyCode = update.propertyCode
        environmentCode = update.environmentCode
        identities = update.identities
        jurisdictionCode = update.jurisdictionCode
        migrationOption = update.migrationOption
        purposes = update.purposes
        vendors = update.vendors
    }
}

extension KetchSDK.KetchError {
    fileprivate init(with error: ApiClientError) {
        self.init(with: error as Error)
    }
}

private struct IdentityConfigurationResponse: Decodable {
    let identities: [String: KetchSDK.IdentityDefinition]?
}
