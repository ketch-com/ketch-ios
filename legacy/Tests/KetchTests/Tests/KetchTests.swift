//
//  KetchTests.swift
//  KetchTests
//
//  Created by Aleksey Bodnya on 4/7/20.
//  Copyright © 2020 Switchbit. All rights reserved.
//

import XCTest

@testable import Ketch

class KetchTests: XCTestCase {

    let organizationCode = "foo"
    let applicationCode = "bar"
    var networkEngine: NetworkEngineMock!

    override func setUp() {
        networkEngine = NetworkEngineMock()
        try! Ketch.setup(organizationCode: organizationCode, applicationCode: applicationCode, networkEngine: networkEngine)
    }

    override func tearDown() {
        Ketch.reset()
    }

    func testSetup() {
        Ketch.reset()
        XCTAssertNoThrow(try Ketch.setup(organizationCode: "a", applicationCode: "b"))
        XCTAssertThrowsError(try Ketch.setup(organizationCode: "b", applicationCode: "c")) { error in
            guard let ketchError = error as? KetchError, case .alreadySetup = ketchError else {
                XCTFail("Error is invalid")
                return
            }
        }
    }

    func testGetFullConfigurationCodes() {
        let environmentCode = "abcd"
        let countryCode = "US"
        let regionCode = "CA"
        let ip = "194.156.251.41"
        Ketch.getFullConfiguration(environmentCode: environmentCode, countryCode: countryCode, regionCode: regionCode, ip: ip) { _ in }
        XCTAssertTrue(networkEngine.fullConfigurationCalled)
        XCTAssertEqual(networkEngine.fullConfigurationEnvironmentCode, environmentCode)
        XCTAssertEqual(networkEngine.fullConfigurationCountryCode, "US")
        XCTAssertEqual(networkEngine.fullConfigurationRegionCode, "CA")
        XCTAssertEqual(networkEngine.fullConfigurationLanguageCode, "EN")
        XCTAssertEqual(networkEngine.fullConfigurationIP, "194.156.251.41")

        Ketch.reset()
        Ketch.getFullConfiguration(environmentCode: environmentCode, countryCode: countryCode, regionCode: regionCode, ip: "") { result in
            guard case .failure(let error) = result,
                case .validationError(let validationError) = error,
                let ketchError = validationError as? KetchError,
                case .haveNotSetupYet = ketchError else {

                XCTFail("Error is invalid")
                return
            }
        }
    }

    func testGetConsentStatus() {
        let config = Configuration.mock()
        let identities = ["abc": "def"]
        let purposes = ["123": "456"]
        Ketch.getConsentStatus(configuration: config, identities: identities, purposes: purposes, completion: { _ in })
        XCTAssertTrue(networkEngine.consentStatusCalled)
        XCTAssertEqual(networkEngine.consentStatusIdentities, identities)
        XCTAssertEqual(networkEngine.consentStatusPurposes, purposes)

        Ketch.reset()
        Ketch.getConsentStatus(configuration: config, identities: identities, purposes: purposes) { result in
            guard case .failure(let error) = result,
                case .validationError(let validationError) = error,
                let ketchError = validationError as? KetchError,
                case .haveNotSetupYet = ketchError else {

                XCTFail("Error is invalid")
                return
            }
        }
    }

    func testSetConsentStatus() {
        let config = Configuration.mock()
        let identities = ["abc": "def"]
        let consents = ["123": ConsentStatus(allowed: true, legalBasisCode: "456")]
        let migrationOption: MigrationOption = .fromAllow
        Ketch.setConsentStatus(configuration: config, identities: identities, consents: consents, migrationOption: migrationOption, completion: { _ in })
        XCTAssertTrue(networkEngine.setConsentStatusCalled)
        XCTAssertEqual(networkEngine.setConsentStatusIdentities, identities)
        XCTAssertEqual(networkEngine.setConsentStatusConsents, consents)
        XCTAssertEqual(networkEngine.setConsentStatusMigrationOption, migrationOption)

        Ketch.reset()
        Ketch.setConsentStatus(configuration: config, identities: identities, consents: consents, migrationOption: migrationOption) { result in
            guard case .failure(let error) = result,
                case .validationError(let validationError) = error,
                let ketchError = validationError as? KetchError,
                case .haveNotSetupYet = ketchError else {

                XCTFail("Error is invalid")
                return
            }
        }
    }

    func testInvokeRights() {
        let config = Configuration.mock()
        let identities = ["abc": "def"]
        let right = "123"
        let userData = UserData(email: "abc@domain.com", firstName: "first", lastName: "last", country: "country", region: "region")
        Ketch.invokeRight(configuration: config, identities: identities, right: right, userData: userData, completion: { _ in })
        XCTAssertTrue(networkEngine.invokeRightsCalled)
        XCTAssertEqual(networkEngine.invokeRightsIdentities, identities)
        XCTAssertEqual(networkEngine.invokeRightsRight, right)
        XCTAssertEqual(networkEngine.invokeRightsUserData?.email, userData.email)

        Ketch.reset()
        Ketch.invokeRight(configuration: config, identities: identities, right: right, userData: userData) { result in
            guard case .failure(let error) = result,
                case .validationError(let validationError) = error,
                let ketchError = validationError as? KetchError,
                case .haveNotSetupYet = ketchError else {

                XCTFail("Error is invalid")
                return
            }
        }
    }
}
