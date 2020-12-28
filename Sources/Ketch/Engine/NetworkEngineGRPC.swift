//
//  NetworkEngineGRPC.swift
//  Ketch
//
//  Created by Andrii Andreiev on 04.12.2020.
//  Copyright © 2020 Switchbit. All rights reserved.
//

import Foundation
import GRPC
import NIO

protocol NetworkEngineGRPC {
    
    /// Creates tasks for retrieveing Configuration for specific environment and region
    /// - Parameter environmentCode: The code of requried environment. The environment must exist in provided `bootstrapConfiguration`
    /// - Parameter countryCode: The code of country needed for configuration
    /// - Parameter regionCode: The code of USA region needed for configuration
    /// - Parameter ip: The `ip` address of the user. The alternative to `countyCode` + `regionCode` for retrieving configuration.
    /// - Parameter languageCode: The short language code
    /// - Parameter completion: The block with `Configuration` or error called when the request is completed.
    func getFullConfiguration(environmentCode: String, countryCode: String, regionCode: String?, ip: String, languageCode: String, completion:@escaping (NetworkTaskResult<Configuration>)->())

    /// Creates task for retrieveing Consent Statuses for provided parameters
    /// - Parameter configuration: The configuration that was retrieved by `getFullConfiguration()` task
    /// - Parameter identities: The map of identities in format `[<identitySpaceCode>, <identityValue>]`. Must be not empty
    /// - Parameter purposes: The map of purposes in format `[<code>: <legalBasisCode>]`. Each `<code>` must exist in `configuration.purposes`.
    /// - Parameter completion: The block with map `[<code>: ConsentStatus]` or error called when the request is completed.
    func getConsentStatus(configuration: Configuration, identities: [String: String], purposes: [String: String], completion: @escaping (NetworkTaskResult<[String: ConsentStatus]>)->())
    
    /// Creates task for settings Consent Statuses with provided parameters
    /// - Parameter configuration: The configuration that was retrieved by `getFullConfiguration()` task
    /// - Parameter identities: The map of identities in format `[<identitySpaceCode>, <identityValue>]`. Must be not empty
    /// - Parameter consents: The map of consent statuses in format `[<code>: ConsentStatus]`. Each `<code>` must exist in `configuration.purposes`.
    /// - Parameter completion: The block with void result called when the request is completed.
    func setConsentStatus(configuration: Configuration, identities: [String: String], consents: [String: ConsentStatus], migrationOption: MigrationOption, completion: @escaping (NetworkTaskResult<Void>)->())
    
    /// Creates task for invoking rights with provided parameters
    /// - Parameter configuration: The configuration that was retrieved by `getFullConfiguration()` task
    /// - Parameter identities: The map of identities in format `[<identitySpaceCode>, <identityValue>]`. Must be not empty
    /// - Parameter right: The right to invoke in format `<rightCode>`. `<rightCode>` must exist in `configuration.rights`.
    /// - Parameter userData: The user's data
    /// - Parameter completion: The block with void result called when the request is completed.
    func invokeRight(configuration: Configuration, identities: [String: String], right: String, userData: UserData, completion: @escaping (NetworkTaskResult<Void>)->())
    
}

class NetworkEngineGRPCImpl: NetworkEngineGRPC {
    
    // MARK: Initializer
    
    /// Initializer
    /// - Parameter settings: Settings for API which contains `organizationId` and `applicationId`
    /// - Parameter session: URLSession used to send network requests
    /// - Parameter cachingEngine: Engine for caching network responses
    init(settings: Settings, cachingEngine: CacheEngine, printDebugInfo: Bool = false) {
        self.settings = settings
        self.cacheStore = CacheStore(settings: settings, engine: cachingEngine)
        self.printDebugInfo = printDebugInfo
        self.channel = ClientConnection.secure(group: MultiThreadedEventLoopGroup(numberOfThreads: 1)).connect(host: "mobile.dev.b10s.io", port: 443)
        self.client = Mobile_MobileClient(channel: channel)
    }

    init(settings: Settings, cachingEngine: CacheEngine, printDebugInfo: Bool = false, client: Mobile_MobileClientProtocol) {
        self.settings = settings
        self.cacheStore = CacheStore(settings: settings, engine: cachingEngine)
        self.printDebugInfo = printDebugInfo
        self.channel = ClientConnection.secure(group: MultiThreadedEventLoopGroup(numberOfThreads: 1)).connect(host: "mobile.dev.b10s.io", port: 443)
        self.client = client
    }
    
    /// Performs a call for retrieveing Configuration for specific environment and region
    /// - Parameter environmentCode: The code of requried environment.
    /// - Parameter countryCode: The code of country needed for configuration
    /// - Parameter regionCode: The code of USA region needed for configuration
    /// - Parameter ip: The IP address of the user. The alternative to `countyCode` + `regionCode` for retrieving configuration.
    /// - Parameter languageCode: The short language code
    /// - Returns: Network task that provides `Configuration` object or network error as a result
    func getFullConfiguration(environmentCode: String, countryCode: String, regionCode: String?, ip: String, languageCode: String, completion:@escaping (NetworkTaskResult<Configuration>)->()) {
        
        let options: Mobile_GetConfigurationRequest = .with {
            $0.organizationCode = self.settings.organizationCode
            $0.applicationCode = self.settings.applicationCode
            $0.applicationEnvironmentCode = environmentCode
            $0.countryCode = countryCode
            $0.regionCode = regionCode ?? ""
            $0.languageCode = languageCode
            $0.ip = ip
        }
        
        let call = client.getConfiguration(options)
        
        call.response.whenSuccess { [weak self] configurationResponse in
            self?.printDebugInfoIfNeeded(configurationResponse)

            DispatchQueue.main.async {
                let configuration = Configuration(response: configurationResponse)
                self?.cacheStore.setConfiguration(configuration: configuration, environmentCode: environmentCode, languageCode: languageCode)
                completion(.success(configuration))
            }
        }
        
        call.response.whenFailure { [weak self] error in
            self?.printDebugInfoIfNeeded(error)

            DispatchQueue.main.async {
                if let configuration = self?.cacheStore.configuration(environmentCode: environmentCode, languageCode: languageCode) {
                    completion(.cache(configuration))
                } else {
                    completion(.failure(error.networkTaskError))
                }
            }
        }
    }
    
    func getConsentStatus(configuration: Configuration, identities: [String: String], purposes: [String: String], completion: @escaping (NetworkTaskResult<[String: ConsentStatus]>)->()) {
        guard identities.count > 0 else {
            completion(.failure(.validationError(error: GetConsentStatusValidationError.noIdentities)))
            return
        }
        guard purposes.count > 0 else {
            completion(.failure(.validationError(error: GetConsentStatusValidationError.noPurposes)))
            return
        }
        let existingPurposes = configuration.purposes ?? []
        for (code, _) in purposes {
            guard existingPurposes.first(where: { $0.code == code }) != nil else {
                completion(.failure(.validationError(error: GetConsentStatusValidationError.purposeIsNotFoundInConfig(code))))
                return
            }
        }
        guard let environmentCode = configuration.environment?.code else {
            completion(.failure(.validationError(error: GetConsentStatusValidationError.environmentCodeNotSpecified)))
            return
        }
        
        let options: Mobile_GetConsentRequest = .with {
            $0.context = .with {
                $0.application = settings.applicationCode
                $0.environment = environmentCode
            }
            $0.identities = identities.map { dict in
                return .with {
                    $0.identitySpace = dict.key
                    $0.identityValue = dict.value
                }
            }
            $0.organizationID = settings.organizationCode
            $0.purposes = purposes.map { dict in
                return .with {
                    $0.purpose = dict.key
                    $0.legalBasis = dict.value
                }
            }
        }
        
        let call = client.getConsent(options)
        
        call.response.whenSuccess { [weak self] response in
            self?.printDebugInfoIfNeeded(response)

            let consentStatus = response.consents.reduce(into: [String: ConsentStatus]()) { (result, consent) in
                result[consent.purpose] = ConsentStatus(allowed: consent.allowed, legalBasisCode: consent.legalBasis)
            }

            DispatchQueue.main.async {
                self?.cacheStore.setConsentStatus(consentStatus: consentStatus, environmentCode: environmentCode, identities: identities, purposes: purposes)
                completion(.success(consentStatus))
            }
        }
        
        call.response.whenFailure { [weak self] error in
            self?.printDebugInfoIfNeeded(error)

            DispatchQueue.main.async {
                if let consents = self?.cacheStore.consentStatus(environmentCode: environmentCode, identities: identities, purposes: purposes) {
                    completion(.cache(consents))
                } else {
                    completion(.failure(error.networkTaskError))
                }
            }
        }
    }
    
    func setConsentStatus(configuration: Configuration, identities: [String: String], consents: [String: ConsentStatus], migrationOption: MigrationOption, completion: @escaping (NetworkTaskResult<Void>)->()) {
        guard identities.count > 0 else {
            completion(.failure(.validationError(error: SetConsentStatusValidationError.noIdentities)))
            return
        }
        guard consents.count > 0 else {
            completion(.failure(.validationError(error: SetConsentStatusValidationError.noConsents)))
            return
        }
        let existingPurposes = configuration.purposes ?? []
        for (code, _) in consents {
            guard existingPurposes.first(where: { $0.code == code }) != nil else {
                completion(.failure(.validationError(error: SetConsentStatusValidationError.purposeIsNotFoundInConfig(code))))
                return
            }
        }
        guard let environmentCode = configuration.environment?.code else {
            completion(.failure(.validationError(error: SetConsentStatusValidationError.environmentCodeNotSpecified)))
            return
        }
        guard let policyScopeCode = configuration.policyScope?.code else {
            completion(.failure(.validationError(error: SetConsentStatusValidationError.policyScopeCodeNotSpecified)))
            return
        }
        guard let organizationCode = configuration.organization?.code else {
            completion(.failure(.validationError(error: SetConsentStatusValidationError.organizationCodeNotSpecified)))
            return
        }
        
        let options: Mobile_SetConsentRequest = .with {
            $0.context = .with {
                $0.application = settings.applicationCode
                $0.environment = environmentCode
            }
            $0.policyScope = policyScopeCode
            $0.consents = consents.map { dict in
                return .with {
                    $0.purpose = dict.key
                    $0.legalBasis = dict.value.legalBasisCode!
                    $0.allowed = dict.value.allowed!
                }
            }
            $0.identities = identities.map { dict in
                return .with {
                    $0.identitySpace = dict.key
                    $0.identityValue = dict.value
                }
            }
            $0.organization = .with {
                $0.name = configuration.organization?.name ?? ""
                $0.id = organizationCode
            }
            $0.collectedTime = Int64(Date().timeIntervalSince1970)
        }
        
        let call = client.setConsent(options)
        
        call.response.whenSuccess { [weak self] response in
            self?.printDebugInfoIfNeeded(response)

            DispatchQueue.main.async {
                completion(.success)
            }
        }

        call.response.whenFailure { [weak self] error in
            self?.printDebugInfoIfNeeded(error)

            DispatchQueue.main.async {
                completion(.failure(error.networkTaskError))
            }
        }
    }
    
    /// Creates task for invoking rights with provided parameters
    /// - Parameter configuration: The configuration that was retrieved by `getFullConfiguration()` task
    /// - Parameter identities: The map of identities in format `[<identitySpaceCode>, <identityValue>]`. Must be not empty
    /// - Parameter right: The right to invoke in format `<rightCode>`. `<rightCode>` must exist in `configuration.rights`.
    /// - Parameter userData: The user's data
    func invokeRight(configuration: Configuration, identities: [String: String], right: String, userData: UserData, completion: @escaping (NetworkTaskResult<Void>)->()) {
        guard identities.count > 0 else {
            completion(.failure(.validationError(error: InvokeRightsValidationError.noIdentities)))
            return
        }
        let configurationRights = configuration.rights ?? []
        guard configurationRights.contains(where: { $0.code == right }) else {
            completion(.failure(.validationError(error: InvokeRightsValidationError.rightIsNotFoundInConfig(right))))
            return
        }
        guard let environmentCode = configuration.environment?.code else {
            completion(.failure(.validationError(error: InvokeRightsValidationError.environmentCodeNotSpecified)))
            return
        }
        guard let policyScopeCode = configuration.policyScope?.code else {
            completion(.failure(.validationError(error: InvokeRightsValidationError.policyScopeCodeNotSpecified)))
            return
        }
        guard let organizationCode = configuration.organization?.code else {
            completion(.failure(.validationError(error: InvokeRightsValidationError.organizationCodeNotSpecified)))
            return
        }
        guard let applicationCode = configuration.application?.code else {
            completion(.failure(.validationError(error: InvokeRightsValidationError.applicationCodeNotSpecified)))
            return
        }

        let options: Mobile_InvokeRightRequest = .with {
            $0.policyScope = policyScopeCode
            $0.right = right

            $0.identities = identities.map { dict in
                return .with {
                    $0.identitySpace = dict.key
                    $0.identityValue = dict.value
                }
            }
            $0.dataSubject = .with {
                $0.first = userData.first
                $0.last = userData.last
                $0.country = userData.country
                $0.region = userData.region
                $0.email = userData.email
            }
            $0.organization = .with {
                $0.name = configuration.organization?.name ?? ""
                $0.id = organizationCode
            }
            $0.submittedTime = Int64(Date().timeIntervalSince1970)
            $0.context = .with {
                $0.collectedFrom = "phone"
                $0.application = applicationCode
                $0.environment = environmentCode
            }
        }

        let call = client.invokeRight(options)

        call.response.whenSuccess { [weak self] response in
            self?.printDebugInfoIfNeeded(response)

            DispatchQueue.main.async {
                completion(.success)
            }
        }

        call.response.whenFailure { [weak self] error in
            self?.printDebugInfoIfNeeded(error)

            DispatchQueue.main.async {
                completion(.failure(error.networkTaskError))
            }
        }
    }

    private func printDebugInfoIfNeeded(_ item: Any) {
        if printDebugInfo {
            print(item)
        }
    }
    
    // MARK: Private
    
    /// GRPCChannel used to sync network requests
    private let channel: GRPCChannel
    
    /// Client object generated for sending gRPC requests
    private let client: Mobile_MobileClientProtocol!
    
    /// Settings for API which contains `organizationId` and `applicationId`
    private let settings: Settings
    
    /// Store that is responsible to save and retrieve cache of network responses
    private let cacheStore: CacheStore
    
    /// Dedicated Queue to add and remove tasks thread-safety
    private let tasksUpdateQueue = DispatchQueue(label: "NetworkEngine")
    
    /// Map of active tasks
    private var tasks = [String: Any]()
    
    /// Property to print debug info.
    private let printDebugInfo: Bool
    
}

fileprivate extension Error {
    var networkTaskError: NetworkTaskError {
        if let grpcStatus = self as? GRPCStatus {
            return .grpc(statusCode: grpcStatus.code.rawValue, message: grpcStatus.message)
        } else {
            return .other(self)
        }
    }
}
