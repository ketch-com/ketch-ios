//
//  Ketch.swift
//  Ketch
//
//  Created by Aleksey Bodnya on 3/24/20.
//  Copyright © 2020 Switchbit. All rights reserved.
//

import Foundation
import CoreLocation

public class Ketch {

    // MARK: - Public

    /// This method setup Ketch framework with provided parameters. This method must be called before using request methods.
    /// - Parameter organizationCode: The code of organization
    /// - Parameter applicationCode: The code of application
    /// - Parameter session: The URLSession used to send network requests. By defult, shared session is used.
    /// - Throws: `KetchError` in case if `setup` failed or called more than once
    public static func setup(organizationCode: String, applicationCode: String, session: URLSession = URLSession.shared) throws {
        guard shared == nil else {
            throw KetchError.alreadySetup
        }
        shared = Ketch(organizationCode: organizationCode, applicationCode: applicationCode, session: session)
    }

    // MARK: Requests

    /// Retrieve `BootstrapConfiguration` from network request or cache if network request failed
    /// - Parameter completion: The block with `BootstrapConfiguration` or error called when the request is completed. If `setup` is not called,  completion will be called immediately with `KetchError.haveNotSetupYet` error.
    public static func getBootstrapConfiguration(completion: @escaping (NetworkTaskResult<BootstrapConfiguration>) -> Void) {
        obtainInstance(completion: completion) {
            $0.getBootstrapConfiguration(completion: completion)
        }
    }

    /// Retrieve `Configuration` from network request or cache if network request failed.
    /// The configuration is associated with `policyScope` associated with provided `coordinate`
    /// - Parameter bootstrapConfiguration: The configuration that was retrieved by `getBootstrapConfiguration()` task
    /// - Parameter environmentCode: The code of requried environment. The environment must exist in provided `bootstrapConfiguration`
    /// - Parameter coordinate: The geographic coordinate of the user
    /// - Parameter languageCode: The short language code. By default used iOS language code from current locale
    /// - Parameter completion: The block with `Configuration` or error called when the request is completed. If `setup` is not called,  completion will be called immediately with `KetchError.haveNotSetupYet` error.
    public static func getFullConfiguration(bootstrapConfiguration: BootstrapConfiguration, environmentCode: String, coordinate: CLLocationCoordinate2D, languageCode: String = NSLocale.preferredLanguages.first!.uppercased(), completion: @escaping (NetworkTaskResult<Configuration>) -> Void) {
        obtainInstance(completion: completion) {
            $0.getFullConfiguration(bootstrapConfiguration: bootstrapConfiguration, environmentCode: environmentCode, coordinate: coordinate, languageCode: languageCode, completion: completion)
        }
    }

    /// Retrieve `Configuration` from network request or cache if network request failed.
    /// The configuration is associated with `policyScope` associated with user's coordinate according to his IP address.
    /// - Parameter bootstrapConfiguration: The configuration that was retrieved by `getBootstrapConfiguration()` task
    /// - Parameter environmentCode: The code of requried environment. The environment must exist in provided `bootstrapConfiguration`
    /// - Parameter languageCode: The short language code. By default used iOS language code from current locale
    /// - Parameter completion: The block with `Configuration` or error called when the request is completed. If `setup` is not called,  completion will be called immediately with `KetchError.haveNotSetupYet` error.
    public static func getFullConfiguration(bootstrapConfiguration: BootstrapConfiguration, environmentCode: String, languageCode: String = NSLocale.preferredLanguages.first!.uppercased(), completion: @escaping (NetworkTaskResult<Configuration>) -> Void) {
        obtainInstance(completion: completion) {
            $0.getFullConfiguration(bootstrapConfiguration: bootstrapConfiguration, environmentCode: environmentCode, languageCode: languageCode, completion: completion)
        }
    }

    /// Retrieve `Configuration` from network request or cache if network request failed.
    /// The configuration is associated with `policyScope` associated with provided `countryCode` and `regionCode`
    /// - Parameter bootstrapConfiguration: The configuration that was retrieved by `getBootstrapConfiguration()` task
    /// - Parameter environmentCode: The code of requried environment. The environment must exist in provided `bootstrapConfiguration`
    /// - Parameter countryCode: The code of country needed for configuration, will be used to find appropriate `policyScopeCode` in `bootstrapConfiguration`
    /// - Parameter regionCode: The code of USA region needed for configuration, will be used to find appropriate `policyScopeCode` in `bootstrapConfiguration`
    /// - Parameter languageCode: The short language code. By default used iOS language code from current locale
    /// - Parameter completion: The block with `Configuration` or error called when the request is completed. If `setup` is not called,  completion will be called immediately with `KetchError.haveNotSetupYet` error.
    public static func getFullConfiguration(bootstrapConfiguration: BootstrapConfiguration, environmentCode: String, countryCode: String, regionCode: String?, languageCode: String = NSLocale.preferredLanguages.first!.uppercased(), completion: @escaping (NetworkTaskResult<Configuration>) -> Void) {
        obtainInstance(completion: completion) {
            $0.getFullConfiguration(bootstrapConfiguration: bootstrapConfiguration, environmentCode: environmentCode, countryCode: countryCode, regionCode: regionCode, languageCode: languageCode, completion: completion)
        }
    }

    /// Retrieve Consent Statuses from network request or cache if network request failed.
    /// - Parameter configuration: The configuration that was retrieved by `getFullConfiguration()` task
    /// - Parameter identities: The map of identities in format `[<identitySpaceCode>, <identityValue>]`. Must be not empty
    /// - Parameter purposes: The map of purposes in format `[<code>: <legalBasisCode>]`. Each `<code>` must exist in `configuration.purposes`.
    /// - Parameter completion: The block with map `[<code>: ConsentStatus]` or error called when the request is completed. If `setup` is not called,  completion will be called immediately with `KetchError.haveNotSetupYet` error.
    public static func getConsentStatus(configuration: Configuration, identities: [String: String], purposes: [String: String], completion: @escaping (NetworkTaskResult<[String: ConsentStatus]>) -> Void) {
        obtainInstance(completion: completion) {
            $0.getConsentStatus(configuration: configuration, identities: identities, purposes: purposes, completion: completion)
        }
    }

    /// Updates Consent Statuses on back-end with provided parameters
    /// - Parameter configuration: The configuration that was retrieved by `getFullConfiguration()` task
    /// - Parameter identities: The map of identities in format `[<identitySpaceCode>, <identityValue>]`. Must be not empty
    /// - Parameter consents: The map of consent statuses in format `[<code>: ConsentStatus]`. Each `<code>` must exist in `configuration.purposes`.
    /// - Parameter completion: The block with void result called when the request is completed. If `setup` is not called,  completion will be called immediately with `KetchError.haveNotSetupYet` error.
    public static func setConsentStatus(configuration: Configuration, identities: [String: String], consents: [String: ConsentStatus], migrationOption: MigrationOption, completion: @escaping (NetworkTaskVoidResult) -> Void) {
        obtainInstance(completion: completion) {
            $0.setConsentStatus(configuration: configuration, identities: identities, consents: consents, migrationOption: migrationOption, completion: completion)
        }
    }

    /// Invokes rights on back-end with provided parameters
    /// - Parameter configuration: The configuration that was retrieved by `getFullConfiguration()` task
    /// - Parameter identities: The map of identities in format `[<identitySpaceCode>, <identityValue>]`. Must be not empty
    /// - Parameter rights: The array of rights to invoke in format `[<rightCode>]`. Each `<rightCode>` must exist in `configuration.rights`.
    /// - Parameter userData: The user's data
    /// - Parameter completion: The block with void result called when the request is completed. If `setup` is not called,  completion will be called immediately with `KetchError.haveNotSetupYet` error.
    public static func invokeRights(configuration: Configuration, identities: [String: String], rights: [String], userData: UserData, completion: @escaping (NetworkTaskVoidResult) -> Void) {
        obtainInstance(completion: completion) {
            $0.invokeRights(configuration: configuration, identities: identities, rights: rights, userData: userData, completion: completion)
        }
    }

    // MARK: - Private

    // MARK: Initializer

    /// Initializer
    /// - Parameter organizationCode: The code of organization
    /// - Parameter applicationCode: The code of application
    /// - Parameter session: URLSession used to send network requests
    private init(organizationCode: String, applicationCode: String, session: URLSession) {
        settings = Settings(organizationCode: organizationCode, applicationCode: applicationCode)
        let printDebugInfo = false // Change to `true` if you need to debug new requests
        let cacheEngine = FileCacheEngine(settings: settings, printDebugInfo: printDebugInfo)
        networkEngine = NetworkEngineImpl(settings: settings, session: session, cachingEngine: cacheEngine, printDebugInfo: printDebugInfo)
    }

    /// Initializer. Designed to be used ONLY for test purposes!
    private init(organizationCode: String, applicationCode: String, networkEngine: NetworkEngine) {
        self.settings = Settings(organizationCode: organizationCode, applicationCode: applicationCode)
        self.networkEngine = networkEngine
    }

    // MARK: Properties

    /// Settings for API which contains `organizationId` and `applicationId`
    private let settings: Settings

    /// Engine used to create and hold network tasks
    private let networkEngine: NetworkEngine

    /// Engine used to geocode coordinate to `Location` instance
    private let geoCoder = CLGeocoder()

    /// Lock used to access to shared instace of the framework
    private static let lock = NSLock()

    /// Not thread-safe shared instance of the framework
    private static var _shared: Ketch?

    /// Thread-safe shared instance of the framework
    private static var shared: Ketch? {
        get {
            lock.lock()
            let value = _shared
            lock.unlock()
            return value
        }
        set {
            lock.lock()
            _shared = newValue
            lock.unlock()
        }
    }

    // MARK: Inernal Methods

    /// This method setup Ketch framework with provided parameters. This method must be called before using request methods.
    /// The method is designed to be called ONLY for test purposes!
    /// - Parameter organizationCode: The code of organization
    /// - Parameter applicationCode: The code of application
    /// - Parameter session: The URLSession used to send network requests. By defult, shared session is used.
    /// - Throws: `KetchError` in case if `setup` failed or called more than once
    internal static func setup(organizationCode: String, applicationCode: String, networkEngine: NetworkEngine) throws {
        guard shared == nil else {
            throw KetchError.alreadySetup
        }
        shared = Ketch(organizationCode: organizationCode, applicationCode: applicationCode, networkEngine: networkEngine)
    }

    /// Reset shared instance.
    /// The method is designed to be called ONLY for test purposes!
    internal static func reset() {
        shared = nil
    }

    // MARK: Methods

    /// Convenient method to obtain shared instance for executing `NetworkTaskResult` with result`NetworkTaskResult<T>`
    private static func obtainInstance<T>(completion: @escaping (NetworkTaskResult<T>) -> Void, _ block: (Ketch) -> Void) {
        obtainInstance(failure: { (error) in
            completion(.failure(.validationError(error: error)))
        }, block)
    }

    /// Convenient method to obtain shared instance for executing `NetworkTaskResult` with result`NetworkTaskVoidResult`
    private static func obtainInstance(completion: @escaping (NetworkTaskVoidResult) -> Void, _ block: (Ketch) -> Void) {
        obtainInstance(failure: { (error) in
            completion(.failure(.validationError(error: error)))
        }, block)
    }

    /// Convenient method to obtain shared instance with providing all the validation logic inside
    private static func obtainInstance(failure: (KetchError) -> Void, _ block: (Ketch) -> Void) {
        guard let shared = shared else {
            failure(.haveNotSetupYet)
            return
        }
        block(shared)
    }

    // MARK: Requests

    /// Retrieve `BootstrapConfiguration` from network request or cache if network request failed
    /// - Parameter completion: The block with `BootstrapConfiguration` or error called when the request is completed
    private func getBootstrapConfiguration(completion: @escaping (NetworkTaskResult<BootstrapConfiguration>) -> Void) {
        let task = networkEngine.getBootstrapConfiguration()
        task.onResult = completion
        task.schedule()
    }

    /// Retrieve `Configuration` from network request or cache if network request failed.
    /// The configuration is associated with `policyScope` associated with provided `coordinate`
    /// - Parameter bootstrapConfiguration: The configuration that was retrieved by `getBootstrapConfiguration()` task
    /// - Parameter environmentCode: The code of requried environment. The environment must exist in provided `bootstrapConfiguration`
    /// - Parameter coordinate: The geographic coordinate of the user
    /// - Parameter languageCode: The short language code
    /// - Parameter completion: The block with `Configuration` or error called when the request is completed
    private func getFullConfiguration(bootstrapConfiguration: BootstrapConfiguration, environmentCode: String, coordinate: CLLocationCoordinate2D, languageCode: String, completion: @escaping (NetworkTaskResult<Configuration>) -> Void) {
        geoCoder.reverseCoordinate(coordinate) { [weak self] (location, error) in
            guard let self = self, let location = location else {
                completion(.failure(.validationError(error: GetFullConfigurationValidationError.cannotRetrieveLocation(error))))
                return
            }
            self.getFullConfiguration(bootstrapConfiguration: bootstrapConfiguration, environmentCode: environmentCode, countryCode: location.countryCode, regionCode: location.regionCode, languageCode: languageCode, completion: completion)
        }
    }

    /// Retrieve `Configuration` from network request or cache if network request failed.
    /// The configuration is associated with `policyScope` associated with user's coordinate according to his IP address.
    /// - Parameter bootstrapConfiguration: The configuration that was retrieved by `getBootstrapConfiguration()` task
    /// - Parameter environmentCode: The code of requried environment. The environment must exist in provided `bootstrapConfiguration`
    /// - Parameter languageCode: The short language code
    /// - Parameter completion: The block with `Configuration` or error called when the request is completed
    private func getFullConfiguration(bootstrapConfiguration: BootstrapConfiguration, environmentCode: String, languageCode: String, completion: @escaping (NetworkTaskResult<Configuration>) -> Void) {
        let task = networkEngine.getLocation(bootstrapConfiguration: bootstrapConfiguration)
        task.onResult = { [weak self] result in
            switch result {
            case .success(let location), .cache(let location):
                guard let self = self, let location = location else {
                    completion(.failure(.validationError(error: GetFullConfigurationValidationError.cannotRetrieveLocation(nil))))
                    return
                }
                self.getFullConfiguration(bootstrapConfiguration: bootstrapConfiguration, environmentCode: environmentCode, countryCode: location.countryCode, regionCode: location.regionCode, languageCode: languageCode, completion: completion)
            case .failure(let error):
                completion(.failure(error))
            }

        }
        task.schedule()
    }

    /// Retrieve `Configuration` from network request or cache if network request failed.
    /// The configuration is associated with `policyScope` associated with provided `countryCode` and `regionCode`
    /// - Parameter bootstrapConfiguration: The configuration that was retrieved by `getBootstrapConfiguration()` task
    /// - Parameter environmentCode: The code of requried environment. The environment must exist in provided `bootstrapConfiguration`
    /// - Parameter countryCode: The code of country needed for configuration, will be used to find appropriate `policyScopeCode` in `bootstrapConfiguration`
    /// - Parameter regionCode: The code of USA region needed for configuration, will be used to find appropriate `policyScopeCode` in `bootstrapConfiguration`
    /// - Parameter languageCode: The short language code
    /// - Parameter completion: The block with `Configuration` or error called when the request is completed
    private func getFullConfiguration(bootstrapConfiguration: BootstrapConfiguration, environmentCode: String, countryCode: String, regionCode: String?, languageCode: String, completion: @escaping (NetworkTaskResult<Configuration>) -> Void) {
        let task = networkEngine.getFullConfiguration(bootstrapConfiguration: bootstrapConfiguration, environmentCode: environmentCode, countryCode: countryCode, regionCode: regionCode, languageCode: languageCode)
        task.onResult = completion
        task.schedule()
    }

    /// Retrieve Consent Statuses from network request or cache if network request failed.
    /// - Parameter configuration: The configuration that was retrieved by `getFullConfiguration()` task
    /// - Parameter identities: The map of identities in format `[<identitySpaceCode>, <identityValue>]`. Must be not empty
    /// - Parameter purposes: The map of purposes in format `[<code>: <legalBasisCode>]`. Each `<code>` must exist in `configuration.purposes`.
    /// - Parameter completion: The block with map `[<code>: ConsentStatus]` or error called when the request is completed
    private func getConsentStatus(configuration: Configuration, identities: [String: String], purposes: [String: String], completion: @escaping (NetworkTaskResult<[String: ConsentStatus]>) -> Void) {
        let task = networkEngine.getConsentStatus(configuration: configuration, identities: identities, purposes: purposes)
        task.onResult = completion
        task.schedule()
    }

    /// Updates Consent Statuses on back-end with provided parameters
    /// - Parameter configuration: The configuration that was retrieved by `getFullConfiguration()` task
    /// - Parameter identities: The map of identities in format `[<identitySpaceCode>, <identityValue>]`. Must be not empty
    /// - Parameter consents: The map of consent statuses in format `[<code>: ConsentStatus]`. Each `<code>` must exist in `configuration.purposes`.
    /// - Parameter completion: The block with void result called when the request is completed
    private func setConsentStatus(configuration: Configuration, identities: [String: String], consents: [String: ConsentStatus], migrationOption: MigrationOption, completion: @escaping (NetworkTaskVoidResult) -> Void) {
        let task = networkEngine.setConsentStatus(configuration: configuration, identities: identities, consents: consents, migrationOption: migrationOption)
        task.onResult = { completion($0.toVoidResult()) }
        task.schedule()
    }

    /// Updates Consent Statuses on back-end with provided parameters
    /// - Parameter configuration: The configuration that was retrieved by `getFullConfiguration()` task
    /// - Parameter identities: The map of identities in format `[<identitySpaceCode>, <identityValue>]`. Must be not empty
    /// - Parameter consents: The map of consent statuses in format `[<code>: ConsentStatus]`. Each `<code>` must exist in `configuration.purposes`.
    /// - Parameter completion: The block with void result called when the request is completed
    private func invokeRights(configuration: Configuration, identities: [String: String], rights: [String], userData: UserData, completion: @escaping (NetworkTaskVoidResult) -> Void) {
        let task = networkEngine.invokeRights(configuration: configuration, identities: identities, rights: rights, userData: userData)
        task.onResult = { completion($0.toVoidResult()) }
        task.schedule()
    }
}