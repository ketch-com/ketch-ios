//
//  CacheStore.swift
//  Ketch
//
//  Created by Aleksey Bodnya on 3/25/20.
//  Copyright © 2020 Switchbit. All rights reserved.
//

import UIKit

/// Store that is responsible to save and retrieve cache of network responses
class CacheStore {

    // MARK: Initializer

    /// Initializer
    /// - Parameter settings: Settings for API which contains `organizationId` and `applicationId`
    /// - Parameter engine: Engine for caching network responses
    init(settings: Settings, engine: CacheEngine) {
        self.settings = settings
        self.engine = engine
    }

    // MARK: Public

    /// Retrieves cache of `configuration` associated with provided paramers
    /// - Parameter environmentCode: The code of `Environment` associated with `configuration`
    /// - Parameter languageCode: The short language code associated with `configuration`
    /// - Returns: cached version of `Configuration` or nil if cache is missed
    func configuration(environmentCode: String, languageCode: String) -> `Configuration`? {
        let key = configurationKey(environmentCode: environmentCode, languageCode: languageCode)
        return engine.retrieve(key: key)
    }

    /// Saves cache of `configuration` associated with provided paramers
    /// - Parameter configuration: The configuration to save in the cache
    /// - Parameter environmentCode: The code of `Environment` associated with `configuration`
    /// - Parameter policyScopeCode: The code of `PolicyScope` associated with `configuration`
    /// - Parameter languageCode: The short language code associated with `configuration`
    func setConfiguration(configuration: Configuration, environmentCode: String, languageCode: String) {
        let key = configurationKey(environmentCode: environmentCode, languageCode: languageCode)
        engine.save(key: key, object: configuration)
    }

    /// Retrieves cache of `consentStatus` map associated with provided paramers
    /// - Parameter environmentCode: The code of `Environment` associated with Configuration
    /// - Parameter identities: The map of identities in format `[<identitySpaceCode>, <identityValue>]`
    /// - Parameter purposes: The map of purposes in format `[<code>: <legalBasisCode>]`
    /// - Returns: cached version of map `[<code>: ConsentStatus]` or nil if cache is missed
    func consentStatus(environmentCode: String, identities: [String: String], purposes: [String: String]) -> [String: ConsentStatus]? {
        let key = consentStatusKey(environmentCode: environmentCode, identities: identities, purposes: purposes)
        return engine.retrieve(key: key)
    }

    /// Saves cache of `consentStatus` map associated with provided paramers
    /// - Parameter consentStatus: The map `[<code>: ConsentStatus]` to save in the cache
    /// - Parameter environmentCode: The code of `Environment` associated with Configuration
    /// - Parameter identities: The map of identities in format `[<identitySpaceCode>, <identityValue>]`
    /// - Parameter purposes: The map of purposes in format `[<code>: <legalBasisCode>]`
    func setConsentStatus(consentStatus: [String: ConsentStatus], environmentCode: String, identities: [String: String], purposes: [String: String]) {
        let key = consentStatusKey(environmentCode: environmentCode, identities: identities, purposes: purposes)
        engine.save(key: key, object: consentStatus)
    }

    // MARK: Private

    /// Settings for API which contains `organizationId` and `applicationId`
    private let settings: Settings

    /// Engine for caching network responses
    private let engine: CacheEngine

    /// Convenient func to create a string key to persist `configuration` associated with provided parameters
    /// - Parameter environmentCode: The code of `Environment` associated with `configuration`
    /// - Parameter policyScopeCode: The code of `PolicyScope` associated with `configuration`
    /// - Parameter languageCode: The short language code associated with `configuration`
    /// - Returns: string key to persist `configuration` associated with provided parameters as SHA256 hash
    private func configurationKey(environmentCode: String, languageCode: String) -> String {
        return "configuration_" + [environmentCode, languageCode].joined(separator: ";").sha256
    }

    /// Convenient func to create a string key to persist `consentStatus` map associated with provided parameters
    /// - Parameter environmentCode: The code of `Environment` associated with Configuration
    /// - Parameter identities: The map of identities in format `[<identitySpaceCode>, <identityValue>]`
    /// - Parameter purposes: The map of purposes in format `[<code>: <legalBasisCode>]`
    /// - Returns: string key to persist `consentStatus` map associated with provided parameters as SHA256 hash
    private func consentStatusKey(environmentCode: String, identities: [String: String], purposes: [String: String]) -> String {
        return "consentStatus_" + [
            environmentCode,
            identities.map { "\($0):\($1)" }.sorted().joined(separator: ","),
            purposes.map { "\($0):\($1)" }.sorted().joined(separator: ",")
        ].joined(separator: ";").sha256
    }
}
