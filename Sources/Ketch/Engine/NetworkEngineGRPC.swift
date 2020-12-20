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
    /// - Parameter bootstrapConfiguration: The configuration that was retrieved by `getBootstrapConfiguration()` task
    /// - Parameter environmentCode: The code of requried environment. The environment must exist in provided `bootstrapConfiguration`
    /// - Parameter countryCode: The code of country needed for configuration, will be used to find appropriate `policyScopeCode` in `bootstrapConfiguration`
    /// - Parameter regionCode: The code of USA region needed for configuration, will be used to find appropriate `policyScopeCode` in `bootstrapConfiguration`
    /// - Parameter languageCode: The short language code
    /// - Returns: Network task that provides `Configuration` object or network error as a result
    func getFullConfiguration(environmentCode: String, countryCode: String, regionCode: String?, languageCode: String, completion:@escaping (NetworkTaskResult<Configuration>)->())
    
    func getConsentStatus(configuration: Configuration, identities: [String: String], purposes: [String: String], completion: @escaping (NetworkTaskResult<[String: ConsentStatus]>)->())
    
    /// Creates task for settings Consent Statuses with provided parameters
    /// - Parameter configuration: The configuration that was retrieved by `getFullConfiguration()` task
    /// - Parameter identities: The map of identities in format `[<identitySpaceCode>, <identityValue>]`. Must be not empty
    /// - Parameter consents: The map of consent statuses in format `[<code>: ConsentStatus]`. Each `<code>` must exist in `configuration.purposes`.
    func setConsentStatus(configuration: Configuration, identities: [String: String], consents: [String: ConsentStatus], migrationOption: MigrationOption, completion: @escaping (NetworkTaskVoidResult)->())
    
    /// Creates task for invoking rights with provided parameters
    /// - Parameter configuration: The configuration that was retrieved by `getFullConfiguration()` task
    /// - Parameter identities: The map of identities in format `[<identitySpaceCode>, <identityValue>]`. Must be not empty
    /// - Parameter rights: The array of rights to invoke in format `[<rightCode>]`. Each `<rightCode>` must exist in `configuration.rights`.
    /// - Parameter userData: The user's data
    func invokeRights(configuration: Configuration, identities: [String: String], rights: [String], userData: UserData, completion: @escaping (NetworkTaskResult<Void>)->())
    
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
    
    /// Performs a call for retrieveing Configuration for specific environment and region
    /// - Parameter environmentCode: The code of requried environment.
    /// - Parameter countryCode: The code of country needed for configuration
    /// - Parameter regionCode: The code of USA region needed for configuration
    /// - Parameter languageCode: The short language code
    /// - Returns: Network task that provides `Configuration` object or network error as a result
    func getFullConfiguration(environmentCode: String, countryCode: String, regionCode: String?, languageCode: String, completion:@escaping (NetworkTaskResult<Configuration>)->()) {
        
        let options: Mobile_GetConfigurationRequest = .with {
            $0.organizationCode = self.settings.organizationCode
            $0.applicationCode = self.settings.applicationCode
            $0.applicationEnvironmentCode = environmentCode
            $0.countryCode = countryCode
            $0.regionCode = regionCode ?? ""
            $0.languageCode = languageCode
        }
        
        let call = client.getConfiguration(options)
        
        call.response.whenSuccess { [weak self] configuratoionResponse in
            let configuration = Configuration(response: configuratoionResponse)
            self?.cacheStore.setConfiguration(configuration: configuration, environmentCode: environmentCode, languageCode: languageCode)
            completion(.success(configuration))
        }
        
        call.response.whenFailure { [weak self] error in
            if let configuration = self?.cacheStore.configuration(environmentCode: environmentCode, languageCode: languageCode) {
                completion(.cache(configuration))
            } else {
                completion(.failure(.serverNotReachable))
            }
        }
    }
    
    func getConsentStatus(configuration: Configuration, identities: [String: String], purposes: [String: String], completion: @escaping (NetworkTaskResult<[String: ConsentStatus]>)->()) {
        guard let wheelhouseHost = configuration.services?.wheelhouse else {
            completion(.failure(.validationError(error: GetConsentStatusValidationError.wheelhouseHostNotSpecified)))
            return
        }
        guard let wheelhouseURL = URL(string: wheelhouseHost) else {
            completion(.failure(.validationError(error: GetConsentStatusValidationError.wheelhouseHostInvalid(wheelhouseHost))))
            return
        }
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
        
        call.response.whenSuccess { [weak self] consents in
            print(consents)
//            let configuration = Configuration(response: configuratoionResponse)
//            self?.cacheStore.setConfiguration(configuration: configuration, environmentCode: environmentCode, languageCode: languageCode)
//            completion(.success(configuration))
        }
        
        call.response.whenFailure { [weak self] error in
            print(error)
//            if let configuration = self?.cacheStore.configuration(environmentCode: environmentCode, languageCode: languageCode) {
//                completion(.cache(configuration))
//            } else {
//                completion(.failure(.serverNotReachable))
//            }
        }
        
        //            return self?.cacheStore.consentStatus(environmentCode: environmentCode, identities: identities, purposes: purposes)
        //            self?.cacheStore.setConsentStatus(consentStatus: consentStatus, environmentCode: environmentCode, identities: identities, purposes: purposes)
    }
    
    
    func setConsentStatus(configuration: Configuration, identities: [String: String], consents: [String: ConsentStatus], migrationOption: MigrationOption, completion: @escaping (NetworkTaskVoidResult)->()) {
        guard let wheelhouseHost = configuration.services?.wheelhouse else {
            completion(.failure(.validationError(error: SetConsentStatusValidationError.wheelhouseHostNotSpecified)))
            return
        }
        guard let wheelhouseURL = URL(string: wheelhouseHost) else {
            completion(.failure(.validationError(error: SetConsentStatusValidationError.wheelhouseHostInvalid(wheelhouseHost))))
            return
        }
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
        
        let options: Mobile_SetConsentRequest = .with{
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
                $0.name = configuration.organization!.name!  //TODO: refactor force unwrapping
                $0.id = configuration.organization!.code!
            }
            $0.collectedTime = Int64(Date().timeIntervalSince1970)
        }
        
        let call = client.setConsent(options)
        
        call.response.whenSuccess { consentResponse in
            completion(.success)
        }
        
        call.response.whenFailure { error in
            completion(.failure(.serverNotReachable))
        }
        
    }
    
    /// Creates task for invoking rights with provided parameters
    /// - Parameter configuration: The configuration that was retrieved by `getFullConfiguration()` task
    /// - Parameter identities: The map of identities in format `[<identitySpaceCode>, <identityValue>]`. Must be not empty
    /// - Parameter rights: The array of rights to invoke in format `[<rightCode>]`. Each `<rightCode>` must exist in `configuration.rights`.
    /// - Parameter userData: The user's data
    func invokeRights(configuration: Configuration, identities: [String: String], rights: [String], userData: UserData, completion: @escaping (NetworkTaskResult<Void>)->()) {
        guard let gangplankHost = configuration.services?.gangplank else {
            completion(.failure(.validationError(error: InvokeRightsValidationError.gangplankHostNotSpecified)))
            return
        }
        guard let gangplankURL = URL(string: gangplankHost) else {
            completion(.failure(.validationError(error: InvokeRightsValidationError.gangplankHostInvalid(gangplankHost))))
            return
        }
        guard identities.count > 0 else {
            completion(.failure(.validationError(error: InvokeRightsValidationError.noIdentities)))
            return
        }
        guard rights.count > 0 else {
            completion(.failure(.validationError(error: InvokeRightsValidationError.noRights)))
            return
        }
        let configurationRights = configuration.rights ?? []
        for code in rights {
            guard configurationRights.contains(where: { $0.code == code }) else {
                completion(.failure(.validationError(error: InvokeRightsValidationError.rightIsNotFoundInConfig(code))))
                return
            }
        }
        guard let environmentCode = configuration.environment?.code else {
            completion(.failure(.validationError(error: InvokeRightsValidationError.environmentCodeNotSpecified)))
            return
        }
        guard let policyScopeCode = configuration.policyScope?.code else {
            completion(.failure(.validationError(error: InvokeRightsValidationError.policyScopeCodeNotSpecified)))
            return
        }
        
        //        let request = InvokeRightsRequest(
        //            session: session,
        //            gangplankHost: gangplankURL,
        //            organizationCode: settings.organizationCode,
        //            applicationCode: settings.applicationCode,
        //            environmentCode: environmentCode,
        //            policyScopeCode: policyScopeCode,
        //            identities: identities,
        //            rights: rights,
        //            userData: userData
        //        )
        //        return createTask(request: request, handler: nil)
    }
    
    // MARK: Private
    
    /// GRPCChannel used to sync network requests
    private let channel: GRPCChannel
    
    /// Client object generated for sending gRPC requests
    private let client: Mobile_MobileClient!
    
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
