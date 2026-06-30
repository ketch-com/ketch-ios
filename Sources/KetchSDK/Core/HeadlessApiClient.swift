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
    private let session: URLSession

    init(
        dataCenter: KetchDataCenter = .us,
        apiClient: ApiClient = DefaultApiClient(),
        session: URLSession = .shared
    ) {
        self.baseURL = dataCenter.baseURL
        self.apiClient = apiClient
        self.session = session
    }

    func fetchLocation() -> AnyPublisher<KetchSDK.LocationResponse, KetchError> {
        get(path: "/ip")
            .decode(type: KetchSDK.LocationResponse.self, decoder: JSONDecoder())
            .mapError(KetchError.init)
            .eraseToAnyPublisher()
    }

    func fetchBootstrapConfiguration(
        organization: String,
        property: String
    ) -> AnyPublisher<Configuration, KetchError> {
        get(path: "/config/\(organization)/\(property)/boot.json")
            .decode(type: Configuration.self, decoder: JSONDecoder())
            .mapError(KetchError.init)
            .eraseToAnyPublisher()
    }

    func fetchFullConfiguration(
        request: KetchSDK.FullConfigurationRequest
    ) -> AnyPublisher<Configuration, KetchError> {
        var path = "/config/\(request.organizationCode)/\(request.propertyCode)"
        let languageInPath = request.environmentCode != nil
            && request.jurisdictionCode != nil
            && request.languageCode != nil
        if let env = request.environmentCode,
           let jurisdiction = request.jurisdictionCode,
           let language = request.languageCode {
            path += "/\(env)/\(jurisdiction)/\(language)"
        }
        path += "/config.json"
        var query: [URLQueryItem] = []
        if let hash = request.hash {
            query.append(URLQueryItem(name: "hash", value: hash))
        }
        if !languageInPath, let language = request.languageCode {
            query.append(URLQueryItem(name: "language", value: language))
        }
        return get(path: path, queryItems: query)
            .decode(type: Configuration.self, decoder: JSONDecoder())
            .mapError(KetchError.init)
            .eraseToAnyPublisher()
    }

    func fetchConsent(config: ConsentConfig) -> AnyPublisher<ConsentStatus, KetchError> {
        let path = "/consent/\(config.organizationCode)/get"
        guard let body = try? JSONEncoder().encode(ConsentConfigPayload(config: config)) else {
            return Fail(error: KetchError.requestError).eraseToAnyPublisher()
        }
        return postConsent(path: path, body: body, config: config)
    }

    func fetchProtocols(config: ConsentConfig) -> AnyPublisher<ConsentStatus, KetchError> {
        fetchConsent(config: config)
            .map { response in
                guard let protocols = response.protocols, !protocols.isEmpty else {
                    return ConsentStatus(
                        purposes: response.purposes,
                        vendors: response.vendors,
                        protocols: nil
                    )
                }
                return ConsentStatus(
                    purposes: response.purposes,
                    vendors: response.vendors,
                    protocols: protocols
                )
            }
            .eraseToAnyPublisher()
    }

    /// Returns server consent including computed `protocols`; omits `protocols` from request body.
    func setConsent(update: ConsentUpdate) -> AnyPublisher<ConsentStatus, KetchError> {
        let path = "/consent/\(update.organizationCode)/update"
        guard let body = try? JSONEncoder().encode(SetConsentPayload(update: update)) else {
            return Fail(error: KetchError.requestError).eraseToAnyPublisher()
        }
        return postSetConsent(path: path, body: body, fallback: update)
    }

    // MARK: - Legacy v3 endpoints (used by existing KetchApiRequest)

    func fetchConfig(organization: String, property: String) -> AnyPublisher<Configuration, KetchError> {
        fetchFullConfiguration(
            request: .init(
                organizationCode: organization,
                propertyCode: property,
                languageCode: Locale.preferredLanguages[0]
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
        fetchFullConfiguration(
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

    func getConsent(config: ConsentConfig) -> AnyPublisher<ConsentStatus, KetchError> {
        fetchConsent(config: config)
    }

    func updateConsent(update: ConsentUpdate) -> AnyPublisher<ConsentStatus, KetchError> {
        setConsent(update: update)
    }

    func invokeRight(request: KetchSDK.InvokeRightRequest) -> AnyPublisher<Void, KetchError> {
        let path = "/rights/\(request.organizationCode)/invoke"
        guard let body = try? JSONEncoder().encode(request) else {
            return Fail(error: KetchError.requestError).eraseToAnyPublisher()
        }
        return postVoid(path: path, body: body)
    }

    func getProfile(request: KetchSDK.GetProfileRequest) -> AnyPublisher<KetchSDK.GetProfileResponse, KetchError> {
        let path = "/profile/\(request.organizationCode)/get"
        guard let body = try? JSONEncoder().encode(request) else {
            return Fail(error: KetchError.requestError).eraseToAnyPublisher()
        }
        return post(path: path, body: body)
            .decode(type: KetchSDK.GetProfileResponse.self, decoder: JSONDecoder())
            .mapError(KetchError.init)
            .eraseToAnyPublisher()
    }

    func putProfile(request: KetchSDK.PutProfileRequest) -> AnyPublisher<Void, KetchError> {
        let path = "/profile/\(request.organizationCode)/put"
        guard let body = try? JSONEncoder().encode(request) else {
            return Fail(error: KetchError.requestError).eraseToAnyPublisher()
        }
        return postVoid(path: path, body: body)
    }

    func getSubscriptions(
        request: KetchSDK.SubscriptionsRequest
    ) -> AnyPublisher<KetchSDK.SubscriptionsResponse, KetchError> {
        let path = "/subscriptions/\(request.organizationCode)/get"
        guard let body = try? JSONEncoder().encode(request) else {
            return Fail(error: KetchError.requestError).eraseToAnyPublisher()
        }
        return post(path: path, body: body)
            .decode(type: KetchSDK.SubscriptionsResponse.self, decoder: JSONDecoder())
            .mapError(KetchError.init)
            .eraseToAnyPublisher()
    }

    func setSubscriptions(request: KetchSDK.SubscriptionsRequest) -> AnyPublisher<Void, KetchError> {
        let path = "/subscriptions/\(request.organizationCode)/update"
        guard let body = try? JSONEncoder().encode(request) else {
            return Fail(error: KetchError.requestError).eraseToAnyPublisher()
        }
        return postVoid(path: path, body: body)
    }

    func invokeRights(organization: String, config: KetchSDK.InvokeRightConfig) -> AnyPublisher<Void, KetchError> {
        invokeRight(request: .init(organizationCode: organization, config: config))
    }

    func fetchSubscriptionsConfiguration(
        request: KetchSDK.SubscriptionConfigurationRequest
    ) -> AnyPublisher<KetchSDK.SubscriptionConfiguration, KetchError> {
        let path = "/config/\(request.organizationCode)/\(request.propertyCode)/\(request.languageCode)/\(request.experienceCode)/subscriptions.json"
        return get(path: path)
            .decode(type: KetchSDK.SubscriptionConfiguration.self, decoder: JSONDecoder())
            .mapError(KetchError.init)
            .eraseToAnyPublisher()
    }

    func preferenceQRUrl(request: KetchSDK.PreferenceQRRequest) -> URL? {
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

    func webReport(channel: String, request: KetchSDK.WebReportRequest) -> AnyPublisher<Void, KetchError> {
        let path = "/report/\(channel)"
        guard let body = try? JSONEncoder().encode(request) else {
            return Fail(error: KetchError.requestError).eraseToAnyPublisher()
        }
        return postVoid(path: path, body: body)
    }

    func getVendors() -> AnyPublisher<KetchSDK.Vendors, KetchError> {
        get(path: "/gvl/vendor-list.json")
            .decode(type: KetchSDK.Vendors.self, decoder: JSONDecoder())
            .mapError(KetchError.init)
            .eraseToAnyPublisher()
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
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.httpBody = body
        applyJSONHeaders(&urlRequest)

        return session.dataTaskPublisher(for: urlRequest)
            .tryMap { output -> Void in
                if let http = output.response as? HTTPURLResponse,
                   !(200..<300).contains(http.statusCode) {
                    throw URLError(.badServerResponse)
                }
                return ()
            }
            .mapError(KetchError.init)
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
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.httpBody = body
        applyJSONHeaders(&urlRequest)

        return session.dataTaskPublisher(for: urlRequest)
            .tryMap { output -> ConsentStatus in
                let data = output.data
                if let http = output.response as? HTTPURLResponse,
                   !(200..<300).contains(http.statusCode) {
                    throw URLError(.badServerResponse)
                }
                if data.isEmpty || String(data: data, encoding: .utf8) == "null" {
                    return Self.emptyConsentStatus(for: config)
                }
                if let decoded = try? JSONDecoder().decode(ConsentStatus.self, from: data),
                   Self.hasUsableConsentFields(decoded) {
                    return decoded
                }
                return Self.emptyConsentStatus(for: config)
            }
            .mapError(KetchError.init)
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
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.httpBody = body
        applyJSONHeaders(&urlRequest)

        return session.dataTaskPublisher(for: urlRequest)
            .tryMap { output -> ConsentStatus in
                let data = output.data
                if let http = output.response as? HTTPURLResponse,
                   !(200..<300).contains(http.statusCode) {
                    throw URLError(.badServerResponse)
                }
                if let decoded = try? JSONDecoder().decode(ConsentStatus.self, from: data),
                   Self.hasUsableConsentFields(decoded) {
                    return Self.mergingProtocols(from: decoded, fallback: fallback)
                }
                return Self.consentStatus(from: fallback)
            }
            .mapError(KetchError.init)
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

    private func applyJSONHeaders(_ request: inout URLRequest) {
        request.setValue(
            ApiRequest.HeaderValue.applicationJson,
            forHTTPHeaderField: ApiRequest.HeaderField.accept
        )
        request.setValue(
            ApiRequest.HeaderValue.contentTypeJson,
            forHTTPHeaderField: ApiRequest.HeaderField.contentType
        )
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
