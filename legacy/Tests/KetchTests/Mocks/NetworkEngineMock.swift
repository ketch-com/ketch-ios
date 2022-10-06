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

    var fullConfigurationCalled = false
    var fullConfigurationEnvironmentCode: String?
    var fullConfigurationCountryCode: String?
    var fullConfigurationRegionCode: String?
    var fullConfigurationLanguageCode: String?
    var fullConfigurationIP: String?
    func getFullConfiguration(environmentCode: String, countryCode: String, regionCode: String?, ip: String, languageCode: String, completion: @escaping (NetworkTaskResult<Configuration>) -> ()) {
        fullConfigurationCalled = true
        fullConfigurationEnvironmentCode = environmentCode
        fullConfigurationCountryCode = countryCode
        fullConfigurationRegionCode = regionCode
        fullConfigurationLanguageCode = languageCode
        fullConfigurationIP = ip
    }

    var consentStatusCalled = false
    var consentStatusConfig: Configuration?
    var consentStatusIdentities: [String : String]?
    var consentStatusPurposes: [String : String]?
    func getConsentStatus(configuration: Configuration, identities: [String : String], purposes: [String : String], completion: @escaping (NetworkTaskResult<[String : ConsentStatus]>) -> ()) {
        consentStatusCalled = true
        consentStatusConfig = configuration
        consentStatusIdentities = identities
        consentStatusPurposes = purposes
    }

    var setConsentStatusCalled = false
    var setConsentStatusConfig: Configuration?
    var setConsentStatusIdentities: [String : String]?
    var setConsentStatusConsents: [String : ConsentStatus]?
    var setConsentStatusMigrationOption: MigrationOption?
    func setConsentStatus(configuration: Configuration, identities: [String : String], consents: [String : ConsentStatus], migrationOption: MigrationOption, completion: @escaping (NetworkTaskResult<Void>) -> ()) {
        setConsentStatusCalled = true
        setConsentStatusConfig = configuration
        setConsentStatusIdentities = identities
        setConsentStatusConsents = consents
        setConsentStatusMigrationOption = migrationOption
    }

    var invokeRightsCalled = false
    var invokeRightsConfig: Configuration?
    var invokeRightsIdentities: [String : String]?
    var invokeRightsRight: String?
    var invokeRightsUserData: UserData?
    func invokeRight(configuration: Configuration, identities: [String : String], right: String, userData: UserData, completion: @escaping (NetworkTaskResult<Void>) -> ()) {
        invokeRightsCalled = true
        invokeRightsConfig = configuration
        invokeRightsIdentities = identities
        invokeRightsRight = right
        invokeRightsUserData = userData
    }

}
