//
//  NetworkEngine.swift
//  Ketch
//
//  Created by Aleksey Bodnya on 3/25/20.
//  Copyright © 2020 Switchbit. All rights reserved.
//

import UIKit

/// This class is responsible for creating specific network tasks for Ketch API
protocol NetworkEngine {

    /// Creates tasks for retrieveing BootstrapConfiguration
    /// - Returns: Network task that provides `BootstrapConfiguration` object or network error as a result
    func getBootstrapConfiguration() -> NetworkTask<BootstrapConfiguration, BootstrapConfiguration>

    /// Creates tasks for retrieveing Configuration for specific environment and region
    /// - Parameter bootstrapConfiguration: The configuration that was retrieved by `getBootstrapConfiguration()` task
    /// - Parameter environmentCode: The code of requried environment. The environment must exist in provided `bootstrapConfiguration`
    /// - Parameter countryCode: The code of country needed for configuration, will be used to find appropriate `policyScopeCode` in `bootstrapConfiguration`
    /// - Parameter regionCode: The code of USA region needed for configuration, will be used to find appropriate `policyScopeCode` in `bootstrapConfiguration`
    /// - Parameter languageCode: The short language code
    /// - Returns: Network task that provides `Configuration` object or network error as a result
    func getFullConfiguration(bootstrapConfiguration: BootstrapConfiguration, environmentCode: String, countryCode: String, regionCode: String?, languageCode: String) -> NetworkTask<Configuration, Configuration>

    /// Creates task for retrieveing location according to sender's IP address
    /// - Parameter bootstrapConfiguration: The configuration that was retrieved by `getBootstrapConfiguration()` task
    /// - Returns: Network task that provides `Location` object or network error as a result
    func getLocation(bootstrapConfiguration: BootstrapConfiguration) -> NetworkTask<GetLocationResponse, Location>

    /// Creates task for retrieveing Consent Statuses for provided parameters
    /// - Parameter configuration: The configuration that was retrieved by `getFullConfiguration()` task
    /// - Parameter identities: The map of identities in format `[<identitySpaceCode>, <identityValue>]`. Must be not empty
    /// - Parameter purposes: The map of purposes in format `[<code>: <legalBasisCode>]`. Each `<code>` must exist in `configuration.purposes`.
    /// - Returns: Network task that provides map `[<code>: ConsentStatus]` map or network error as a result
    func getConsentStatus(configuration: Configuration, identities: [String: String], purposes: [String: String]) -> NetworkTask<GetConsentStatusResponse, [String: ConsentStatus]>

    /// Creates task for settings Consent Statuses with provided parameters
    /// - Parameter configuration: The configuration that was retrieved by `getFullConfiguration()` task
    /// - Parameter identities: The map of identities in format `[<identitySpaceCode>, <identityValue>]`. Must be not empty
    /// - Parameter consents: The map of consent statuses in format `[<code>: ConsentStatus]`. Each `<code>` must exist in `configuration.purposes`.
    /// - Returns: Network task that indicates result of opetation: success of network error
    func setConsentStatus(configuration: Configuration, identities: [String: String], consents: [String: ConsentStatus], migrationOption: MigrationOption) -> NetworkTask<EmptyResponse, Void>

    /// Creates task for invoking rights with provided parameters
    /// - Parameter configuration: The configuration that was retrieved by `getFullConfiguration()` task
    /// - Parameter identities: The map of identities in format `[<identitySpaceCode>, <identityValue>]`. Must be not empty
    /// - Parameter rights: The array of rights to invoke in format `[<rightCode>]`. Each `<rightCode>` must exist in `configuration.rights`.
    /// - Parameter userData: The user's data
    /// - Returns: Network task that indicates result of opetation: success of network error
    func invokeRights(configuration: Configuration, identities: [String: String], rights: [String], userData: UserData) -> NetworkTask<EmptyResponse, Void>
}

// MARK: -

class NetworkEngineImpl: NetworkEngine {

    // MARK: Initializer

    /// Initializer
    /// - Parameter settings: Settings for API which contains `organizationId` and `applicationId`
    /// - Parameter session: URLSession used to send network requests
    /// - Parameter cachingEngine: Engine for caching network responses
    init(settings: Settings, session: URLSession, cachingEngine: CacheEngine, printDebugInfo: Bool = false) {
        self.settings = settings
        self.session = session
        self.cacheStore = CacheStore(settings: settings, engine: cachingEngine)
        self.printDebugInfo = printDebugInfo
    }

    // MARK: Requests

    /// Creates tasks for retrieveing BootstrapConfiguration
    /// - Returns: Network task that provides `BootstrapConfiguration` object or network error as a result
    func getBootstrapConfiguration() -> NetworkTask<BootstrapConfiguration, BootstrapConfiguration> {
        let request = GetBootstrapConfigurationRequest(
            session: session,
            organizationCode: settings.organizationCode,
            applicationCode: settings.applicationCode
        )
        let cacheRetrieve: () -> BootstrapConfiguration? = { [weak self] in
            return self?.cacheStore.bootstrapConfiguration
        }
        let cacheSave: (BootstrapConfiguration) -> () = { [weak self] config in
            self?.cacheStore.bootstrapConfiguration = config
        }
        return createTask(request: request, handler: ResponseHandlerCopyObject(), cacheRetrieve: cacheRetrieve, cacheSave: cacheSave)
    }

    /// Creates tasks for retrieveing Configuration for specific environment and region
    /// - Parameter bootstrapConfiguration: The configuration that was retrieved by `getBootstrapConfiguration()` task
    /// - Parameter environmentCode: The code of requried environment. The environment must exist in provided `bootstrapConfiguration`
    /// - Parameter countryCode: The code of country needed for configuration, will be used to find appropriate `policyScopeCode` in `bootstrapConfiguration`
    /// - Parameter regionCode: The code of USA region needed for configuration, will be used to find appropriate `policyScopeCode` in `bootstrapConfiguration`
    /// - Parameter languageCode: The short language code
    /// - Returns: Network task that provides `Configuration` object or network error as a result
    func getFullConfiguration(bootstrapConfiguration: BootstrapConfiguration, environmentCode: String, countryCode: String, regionCode: String?, languageCode: String) -> NetworkTask<Configuration, Configuration> {
        guard let supercargoHost = bootstrapConfiguration.services?.supercargo else {
            return .failed(error: GetFullConfigurationValidationError.supercargoHostNotSpecified)
        }
        guard let supercargoURL = URL(string: supercargoHost) else {
            return .failed(error: GetFullConfigurationValidationError.supercargoHostInvalid(supercargoHost))
        }
        let environments = bootstrapConfiguration.environments ?? []
        let matchedEnvironment = environments.first(where: { environment in
            guard let patternBase64 = environment.pattern, let pattern = patternBase64.base64Decode, let regexp = try? NSRegularExpression(pattern: pattern, options: .init()) else {
                return false
            }
            let match = regexp.firstMatch(in: environmentCode, options: .init(), range: NSRange(location: 0, length: (environmentCode as NSString).length))
            return match != nil
        })
        let productionEnvironment = environments.first(where: { $0.code == "production" })
        guard let environment = matchedEnvironment ?? productionEnvironment else {
            return .failed(error: GetFullConfigurationValidationError.cannotFindEnvironment(environmentCode))
        }
        let usedEnvironmentCode = environment.code ?? ""
        guard let environmentHash = environment.hash else {
            return .failed(error: GetFullConfigurationValidationError.environmentMissedHash(usedEnvironmentCode))
        }
        var locationCode = countryCode.uppercased()
        if countryCode == "US", let regionCode = regionCode?.uppercased() {
            locationCode += "-" + regionCode
        }
        let scopes = bootstrapConfiguration.policyScope?.scopes ?? [:]
        let defaultScopeCode = bootstrapConfiguration.policyScope?.defaultScopeCode ?? ""
        let policyScopeCode = scopes[locationCode] ?? defaultScopeCode

        let request = GetFullConfigurationRequest(
            session: session,
            supercargoHost: supercargoURL,
            organizationCode: settings.organizationCode,
            applicationCode: settings.applicationCode,
            environmentCode: usedEnvironmentCode,
            environmentHash: environmentHash,
            policyScopeCode: policyScopeCode,
            languageCode: languageCode
        )
        let cacheRetrieve: () -> Configuration? = { [weak self] in
            return self?.cacheStore.configuration(environmentCode: usedEnvironmentCode, policyScopeCode: policyScopeCode, languageCode: languageCode)
        }
        let cacheSave: (Configuration) -> () = { [weak self] config in
            self?.cacheStore.setConfiguration(configuration: config, environmentCode: usedEnvironmentCode, policyScopeCode: policyScopeCode, languageCode: languageCode)
        }
        return createTask(request: request, handler: ResponseHandlerCopyObject(), cacheRetrieve: cacheRetrieve, cacheSave: cacheSave)
    }

    /// Creates task for retrieveing location according to sender's IP address
    /// - Parameter bootstrapConfiguration: The configuration that was retrieved by `getBootstrapConfiguration()` task
    /// - Returns: Network task that provides `Location` object or network error as a result
    func getLocation(bootstrapConfiguration: BootstrapConfiguration) -> NetworkTask<GetLocationResponse, Location> {
        guard let astrolabeHost = bootstrapConfiguration.services?.astrolabe else {
            return .failed(error: GetLocationValidationError.astrolabeHostNotSpecified)
        }
        guard let astrolabeURL = URL(string: astrolabeHost) else {
            return .failed(error: GetLocationValidationError.astrolabeHostInvalid(astrolabeHost))
        }

        let request = GetLocationRequest(session: session, astrolabeHost: astrolabeURL)
        let handler = GetLocationResponseHandler()
        return createTask(request: request, handler: handler)
    }

    /// Creates task for retrieveing Consent Statuses for provided parameters
    /// - Parameter configuration: The configuration that was retrieved by `getFullConfiguration()` task
    /// - Parameter identities: The map of identities in format `[<identitySpaceCode>, <identityValue>]`. Must be not empty
    /// - Parameter purposes: The map of purposes in format `[<code>: <legalBasisCode>]`. Each `<code>` must exist in `configuration.purposes`.
    /// - Returns: Network task that provides map `[<code>: ConsentStatus]` map or network error as a result
    func getConsentStatus(configuration: Configuration, identities: [String: String], purposes: [String: String]) -> NetworkTask<GetConsentStatusResponse, [String: ConsentStatus]> {
        guard let wheelhouseHost = configuration.services?.wheelhouse else {
            return .failed(error: GetConsentStatusValidationError.wheelhouseHostNotSpecified)
        }
        guard let wheelhouseURL = URL(string: wheelhouseHost) else {
            return .failed(error: GetConsentStatusValidationError.wheelhouseHostInvalid(wheelhouseHost))
        }
        guard identities.count > 0 else {
            return .failed(error: GetConsentStatusValidationError.noIdentities)
        }
        guard purposes.count > 0 else {
            return .failed(error: GetConsentStatusValidationError.noPurposes)
        }
        let existingPurposes = configuration.purposes ?? []
        for (code, _) in purposes {
            guard existingPurposes.first(where: { $0.code == code }) != nil else {
                return .failed(error: GetConsentStatusValidationError.purposeIsNotFoundInConfig(code))
            }
        }
        guard let environmentCode = configuration.environment?.code else {
            return .failed(error: GetConsentStatusValidationError.environmentCodeNotSpecified)
        }

        let request = GetConsentStatusRequest(
            session: session,
            wheelhouseHost: wheelhouseURL,
            organizationCode: settings.organizationCode,
            applicationCode: settings.applicationCode,
            environmentCode: environmentCode,
            identities: identities,
            purposes: purposes
        )
        let handler = GetConsentStatusResponseHandler(purposes: purposes)
        let cacheRetrieve: () -> [String: ConsentStatus]? = { [weak self] in
            return self?.cacheStore.consentStatus(environmentCode: environmentCode, identities: identities, purposes: purposes)
        }
        let cacheSave: ([String: ConsentStatus]) -> () = { [weak self] consentStatus in
            self?.cacheStore.setConsentStatus(consentStatus: consentStatus, environmentCode: environmentCode, identities: identities, purposes: purposes)
        }
        return createTask(request: request, handler: handler, cacheRetrieve: cacheRetrieve, cacheSave: cacheSave)
    }

    /// Creates task for settings Consent Statuses with provided parameters
    /// - Parameter configuration: The configuration that was retrieved by `getFullConfiguration()` task
    /// - Parameter identities: The map of identities in format `[<identitySpaceCode>, <identityValue>]`. Must be not empty
    /// - Parameter consents: The map of consent statuses in format `[<code>: ConsentStatus]`. Each `<code>` must exist in `configuration.purposes`.
    /// - Returns: Network task that indicates result of opetation: success of network error
    func setConsentStatus(configuration: Configuration, identities: [String: String], consents: [String: ConsentStatus], migrationOption: MigrationOption) -> NetworkTask<EmptyResponse, Void> {
        guard let wheelhouseHost = configuration.services?.wheelhouse else {
            return .failed(error: SetConsentStatusValidationError.wheelhouseHostNotSpecified)
        }
        guard let wheelhouseURL = URL(string: wheelhouseHost) else {
            return .failed(error: SetConsentStatusValidationError.wheelhouseHostInvalid(wheelhouseHost))
        }
        guard identities.count > 0 else {
            return .failed(error: SetConsentStatusValidationError.noIdentities)
        }
        guard consents.count > 0 else {
            return .failed(error: SetConsentStatusValidationError.noConsents)
        }
        let existingPurposes = configuration.purposes ?? []
        for (code, _) in consents {
            guard existingPurposes.first(where: { $0.code == code }) != nil else {
                return .failed(error: SetConsentStatusValidationError.purposeIsNotFoundInConfig(code))
            }
        }
        guard let environmentCode = configuration.environment?.code else {
            return .failed(error: SetConsentStatusValidationError.environmentCodeNotSpecified)
        }
        guard let policyScopeCode = configuration.policyScope?.code else {
            return .failed(error: SetConsentStatusValidationError.policyScopeCodeNotSpecified)
        }

        let request = SetConsentStatusRequest(
            session: session,
            wheelhouseHost: wheelhouseURL,
            organizationCode: settings.organizationCode,
            applicationCode: settings.applicationCode,
            environmentCode: environmentCode,
            policyScopeCode: policyScopeCode,
            identities: identities,
            consents: consents,
            migrationOption: migrationOption
        )
        return createTask(request: request, handler: nil)
    }

    /// Creates task for invoking rights with provided parameters
    /// - Parameter configuration: The configuration that was retrieved by `getFullConfiguration()` task
    /// - Parameter identities: The map of identities in format `[<identitySpaceCode>, <identityValue>]`. Must be not empty
    /// - Parameter rights: The array of rights to invoke in format `[<rightCode>]`. Each `<rightCode>` must exist in `configuration.rights`.
    /// - Parameter userData: The user's data
    /// - Returns: Network task that indicates result of opetation: success of network error
    func invokeRights(configuration: Configuration, identities: [String: String], rights: [String], userData: UserData) -> NetworkTask<EmptyResponse, Void> {
        guard let gangplankHost = configuration.services?.gangplank else {
            return .failed(error: InvokeRightsValidationError.gangplankHostNotSpecified)
        }
        guard let gangplankURL = URL(string: gangplankHost) else {
            return .failed(error: InvokeRightsValidationError.gangplankHostInvalid(gangplankHost))
        }
        guard identities.count > 0 else {
            return .failed(error: InvokeRightsValidationError.noIdentities)
        }
        guard rights.count > 0 else {
            return .failed(error: InvokeRightsValidationError.noRights)
        }
        let configurationRights = configuration.rights ?? []
        for code in rights {
            guard configurationRights.contains(where: { $0.code == code }) else {
                return .failed(error: InvokeRightsValidationError.rightIsNotFoundInConfig(code))
            }
        }
        guard let environmentCode = configuration.environment?.code else {
            return .failed(error: InvokeRightsValidationError.environmentCodeNotSpecified)
        }
        guard let policyScopeCode = configuration.policyScope?.code else {
            return .failed(error: InvokeRightsValidationError.policyScopeCodeNotSpecified)
        }

        let request = InvokeRightsRequest(
            session: session,
            gangplankHost: gangplankURL,
            organizationCode: settings.organizationCode,
            applicationCode: settings.applicationCode,
            environmentCode: environmentCode,
            policyScopeCode: policyScopeCode,
            identities: identities,
            rights: rights,
            userData: userData
        )
        return createTask(request: request, handler: nil)
    }

    // MARK: Private

    /// Settings for API which contains `organizationId` and `applicationId`
    private let settings: Settings

    /// URLSession used to send network requests
    private let session: URLSession

    /// Store that is responsible to save and retrieve cache of network responses
    private let cacheStore: CacheStore

    /// Dedicated Queue to add and remove tasks thread-safety
    private let tasksUpdateQueue = DispatchQueue(label: "NetworkEngine")

    /// Map of active tasks
    private var tasks = [String: Any]()

    /// Property to print debug info.
    private let printDebugInfo: Bool

    /// Adds task in the map `tasks` and removes it when it is completed in thread-safe way
    private func add<ResponseType: Codable, ResultType>(task: NetworkTask<ResponseType, ResultType>) {
        tasksUpdateQueue.sync { [weak self] in
            task.onComplete = {
                self?.remove(task: task)
            }
            self?.tasks[task.identifier] = task
        }
    }

    /// Removes task from the map `tasks` in thread-safe way
    private func remove<ResponseType: Codable, ResultType>(task: NetworkTask<ResponseType, ResultType>) {
        tasksUpdateQueue.sync { [weak self] in
            _ = self?.tasks.removeValue(forKey: task.identifier)
        }
    }

    /// Creates a task and add it in `tasks` map
    private func createTask<ResponseType: Codable, ResultType>(request: NetworkRequest, handler: ResponseHandler<ResponseType, ResultType>?, cacheRetrieve: NetworkTask<ResponseType, ResultType>.CacheRetrieve? = nil, cacheSave: NetworkTask<ResponseType, ResultType>.CacheSave? = nil) -> NetworkTask<ResponseType, ResultType> {
        let task = NetworkTask(request: request, handler: handler, cacheRetrieve: cacheRetrieve, cacheSave: cacheSave)
        task.printDebugInfo = printDebugInfo
        add(task: task)
        return task
    }
}
