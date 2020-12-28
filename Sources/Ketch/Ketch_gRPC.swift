//
//  Ketch_gRPC.swift
//  Ketch
//
//  Created by Andrii Andreiev on 06.12.2020.
//  Copyright © 2020 Switchbit. All rights reserved.
//

import Foundation
import CoreLocation

public class Ketch_gRPC {
    
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
        shared = Ketch_gRPC(organizationCode: organizationCode, applicationCode: applicationCode)
    }

    /// Retrieve `Configuration` from network request or cache if network request failed.
    /// - Parameter environmentCode: The code of requried environment.
    /// - Parameter countryCode: The code of country needed for configuration.
    /// - Parameter regionCode: The code of USA region needed for configuration
    /// - Parameter ip: The `ip` address of the user. The alternative way to `countyCode` + `regionCode` for retrieving configuration.
    /// - Parameter languageCode: The short language code. By default used iOS language code from current locale
    /// - Parameter completion: The block with `Configuration` or error called when the request is completed. If `setup` is not called,  completion will be called immediately with `KetchError.haveNotSetupYet` error.
    public static func getFullConfiguration(environmentCode: String, countryCode: String, regionCode: String?, ip: String = "", languageCode: String = NSLocale.preferredLanguages.first!.uppercased(), completion: @escaping (NetworkTaskResult<Configuration>) -> Void) {
        obtainInstance(completion: completion) {
            $0.getFullConfiguration(environmentCode: environmentCode, countryCode: countryCode, regionCode: regionCode, ip: ip, languageCode: languageCode, completion: completion)
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
    public static func setConsentStatus(configuration: Configuration, identities: [String: String], consents: [String: ConsentStatus], migrationOption: MigrationOption, completion: @escaping (NetworkTaskVoidResult) -> ()) {
        obtainInstance(completion: completion) {
            $0.setConsentStatus(configuration: configuration, identities: identities, consents: consents, migrationOption: migrationOption, completion: { completion($0.toVoidResult()) })
        }
    }

    /// Invokes rights on back-end with provided parameters
    /// - Parameter configuration: The configuration that was retrieved by `getFullConfiguration()` task
    /// - Parameter identities: The map of identities in format `[<identitySpaceCode>, <identityValue>]`. Must be not empty
    /// - Parameter rights: The array of rights to invoke in format `[<rightCode>]`. Each `<rightCode>` must exist in `configuration.rights`.
    /// - Parameter userData: The user's data
    /// - Parameter completion: The block with void result called when the request is completed. If `setup` is not called,  completion will be called immediately with `KetchError.haveNotSetupYet` error.
    public static func invokeRight(configuration: Configuration, identities: [String: String], right: String, userData: UserData, completion: @escaping (NetworkTaskVoidResult) -> Void) {
        obtainInstance(completion: completion) {
            $0.invokeRight(configuration: configuration, identities: identities, right: right, userData: userData, completion: { completion($0.toVoidResult()) })
        }
    }
    
    // MARK: - Private

    // MARK: Initializer

    /// Initializer
    /// - Parameter organizationCode: The code of organization
    /// - Parameter applicationCode: The code of application
    private init(organizationCode: String, applicationCode: String) {
        settings = Settings(organizationCode: organizationCode, applicationCode: applicationCode)
        let printDebugInfo = false // Change to `true` if you need to debug new requests
        let cacheEngine = FileCacheEngine(settings: settings, printDebugInfo: printDebugInfo)
        networkEngine = NetworkEngineGRPCImpl(settings: settings, cachingEngine: cacheEngine, printDebugInfo: printDebugInfo)
    }

    /// Initializer. Designed to be used ONLY for test purposes!
    private init(organizationCode: String, applicationCode: String, networkEngine: NetworkEngineGRPC) {
        self.settings = Settings(organizationCode: organizationCode, applicationCode: applicationCode)
        self.networkEngine = networkEngine
    }

    // MARK: Inernal Methods

    /// This method setup Ketch framework with provided parameters. This method must be called before using request methods.
    /// The method is designed to be called ONLY for test purposes!
    /// - Parameter organizationCode: The code of organization
    /// - Parameter applicationCode: The code of application
    /// - Parameter networkEngine: The networking engine
    /// - Throws: `KetchError` in case if `setup` failed or called more than once
    internal static func setup(organizationCode: String, applicationCode: String, networkEngine: NetworkEngineGRPC) throws {
        guard shared == nil else {
            throw KetchError.alreadySetup
        }
        shared = Ketch_gRPC(organizationCode: organizationCode, applicationCode: applicationCode, networkEngine: networkEngine)
    }

    /// Reset shared instance.
    /// The method is designed to be called ONLY for test purposes!
    internal static func reset() {
        shared = nil
    }
    
    // MARK: - Methods
    
    /// Convenient method to obtain shared instance for executing `NetworkTaskResult` with result`NetworkTaskResult<T>`
    private static func obtainInstance<T>(completion: @escaping (NetworkTaskResult<T>) -> Void, _ block: (Ketch_gRPC) -> Void) {
        obtainInstance(failure: { (error) in
            completion(.failure(.validationError(error: error)))
        }, block)
    }

    /// Convenient method to obtain shared instance for executing `NetworkTaskResult` with result`NetworkTaskVoidResult`
    private static func obtainInstance(completion: @escaping (NetworkTaskVoidResult) -> Void, _ block: (Ketch_gRPC) -> Void) {
        obtainInstance(failure: { (error) in
            completion(.failure(.validationError(error: error)))
        }, block)
    }

    /// Convenient method to obtain shared instance with providing all the validation logic inside
    private static func obtainInstance(failure: (KetchError) -> Void, _ block: (Ketch_gRPC) -> Void) {
        guard let shared = shared else {
            failure(.haveNotSetupYet)
            return
        }
        block(shared)
    }
    
    private func getFullConfiguration(environmentCode: String, countryCode: String, regionCode: String?, ip: String, languageCode: String, completion: @escaping (NetworkTaskResult<Configuration>) -> Void) {
        networkEngine.getFullConfiguration(environmentCode: environmentCode, countryCode: countryCode, regionCode: regionCode, ip: ip, languageCode: languageCode, completion: completion)
    }
    
    private func getConsentStatus(configuration: Configuration, identities: [String: String], purposes: [String: String], completion: @escaping (NetworkTaskResult<[String: ConsentStatus]>) -> Void) {
        networkEngine.getConsentStatus(configuration: configuration, identities: identities, purposes: purposes, completion: completion)
    }
        
    private func setConsentStatus(configuration: Configuration, identities: [String: String], consents: [String: ConsentStatus], migrationOption: MigrationOption, completion: @escaping (NetworkTaskResult<Void>) -> ()) {
        networkEngine.setConsentStatus(configuration: configuration, identities: identities, consents: consents, migrationOption: migrationOption, completion: completion)
    }
    
    private func invokeRight(configuration: Configuration, identities: [String: String], right: String, userData: UserData, completion: @escaping (NetworkTaskResult<Void>) -> Void) {
        networkEngine.invokeRight(configuration: configuration, identities: identities, right: right, userData: userData, completion: completion)
    }

    // MARK: Properties

    /// Settings for API which contains `organizationId` and `applicationId`
    private let settings: Settings

    /// Engine used to create and hold network tasks
    private let networkEngine: NetworkEngineGRPC

    /// Lock used to access to shared instace of the framework
    private static let lock = NSLock()

    /// Not thread-safe shared instance of the framework
    private static var _shared: Ketch_gRPC?

    /// Thread-safe shared instance of the framework
    private static var shared: Ketch_gRPC? {
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
}
