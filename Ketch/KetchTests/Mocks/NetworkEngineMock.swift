//
//  NetworkEngineMock.swift
//  KetchTests
//
//  Created by Aleksey Bodnya on 4/7/20.
//  Copyright © 2020 Switchbit. All rights reserved.
//

import UIKit

@testable import Ketch

class NetworkEngineMock: NetworkEngine {

    enum Error: ValidationError {
        case didNotProvideMock
        var description: String {
            return "Did Not Provide Mock"
        }
    }

    var bootstrapConfigurationTask: NetworkTask<BootstrapConfiguration, BootstrapConfiguration>?
    var bootstrapConfigurationCalled = false
    func getBootstrapConfiguration() -> NetworkTask<BootstrapConfiguration, BootstrapConfiguration> {
        bootstrapConfigurationCalled = true
        return bootstrapConfigurationTask ?? .failed(error: Error.didNotProvideMock)
    }

    var fullConfigurationTask: NetworkTask<Configuration, Configuration>?
    var fullConfigurationCalled = false
    var fullConfigurationBootstrapConfig: BootstrapConfiguration?
    var fullConfigurationEnvironmentCode: String?
    var fullConfigurationCountryCode: String?
    var fullConfigurationRegionCode: String?
    var fullConfigurationLanguageCode: String?
    func getFullConfiguration(bootstrapConfiguration: BootstrapConfiguration, environmentCode: String, countryCode: String, regionCode: String?, languageCode: String) -> NetworkTask<Configuration, Configuration> {
        fullConfigurationCalled = true
        fullConfigurationBootstrapConfig = bootstrapConfiguration
        fullConfigurationEnvironmentCode = environmentCode
        fullConfigurationCountryCode = countryCode
        fullConfigurationRegionCode = regionCode
        fullConfigurationLanguageCode = languageCode
        return fullConfigurationTask ?? .failed(error: Error.didNotProvideMock)
    }

    var locationTask: NetworkTask<GetLocationResponse, Location>?
    var locationCalled = false
    var locationBootstrapConfig: BootstrapConfiguration?
    func getLocation(bootstrapConfiguration: BootstrapConfiguration) -> NetworkTask<GetLocationResponse, Location> {
        locationCalled = true
        locationBootstrapConfig = bootstrapConfiguration
        return locationTask ?? .failed(error: Error.didNotProvideMock)
    }

    var consentStatusTask: NetworkTask<GetConsentStatusResponse, [String : ConsentStatus]>?
    var consentStatusCalled = false
    var consentStatusConfig: Configuration?
    var consentStatusIdentities: [String : String]?
    var consentStatusPurposes: [String : String]?
    func getConsentStatus(configuration: Configuration, identities: [String : String], purposes: [String : String]) -> NetworkTask<GetConsentStatusResponse, [String : ConsentStatus]> {
        consentStatusCalled = true
        consentStatusConfig = configuration
        consentStatusIdentities = identities
        consentStatusPurposes = purposes
        return consentStatusTask ?? .failed(error: Error.didNotProvideMock)
    }

    var setConsentStatusTask: NetworkTask<EmptyResponse, Void>?
    var setConsentStatusCalled = false
    var setConsentStatusConfig: Configuration?
    var setConsentStatusIdentities: [String : String]?
    var setConsentStatusConsents: [String : ConsentStatus]?
    var setConsentStatusMigrationOption: MigrationOption?
    func setConsentStatus(configuration: Configuration, identities: [String : String], consents: [String : ConsentStatus], migrationOption: MigrationOption) -> NetworkTask<EmptyResponse, Void> {
        setConsentStatusCalled = true
        setConsentStatusConfig = configuration
        setConsentStatusIdentities = identities
        setConsentStatusConsents = consents
        setConsentStatusMigrationOption = migrationOption
        return setConsentStatusTask ?? .failed(error: Error.didNotProvideMock)
    }

    var invokeRightsTask: NetworkTask<EmptyResponse, Void>?
    var invokeRightsCalled = false
    var invokeRightsConfig: Configuration?
    var invokeRightsIdentities: [String : String]?
    var invokeRightsRights: [String]?
    var invokeRightsUserData: UserData?
    func invokeRights(configuration: Configuration, identities: [String : String], rights: [String], userData: UserData) -> NetworkTask<EmptyResponse, Void> {
        invokeRightsCalled = true
        invokeRightsConfig = configuration
        invokeRightsIdentities = identities
        invokeRightsRights = rights
        invokeRightsUserData = userData
        return invokeRightsTask ?? .failed(error: Error.didNotProvideMock)
    }

}
