//
//  CCPA_Tests.swift
//  KetchSDK_Tests
//
//  Created by Anton Lyfar on 25.10.2022.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import XCTest
@testable import KetchSDK

class CCPA_Tests: XCTestCase {
    func test_isCCPA_aplicable() {
        let testConfiguration1 = KetchSDK.Configuration(
            language: nil,
            organization: nil,
            property: nil,
            environments: nil,
            jurisdiction: nil,
            identities: nil,
            scripts: nil,
            environment: nil,
            deployment: nil,
            privacyPolicy: nil,
            termsOfService: nil,
            rights: nil,
            regulations: ["ccpaca", "some_other"],
            theme: nil,
            experience: nil,
            purposes: nil,
            canonicalPurposes: nil,
            services: nil,
            options: nil,
            legalBases: nil,
            vendors: nil
        )

        let ccpa = CCPA()
        ccpa.configLoaded(testConfiguration1)
        XCTAssert(ccpa.isApplied)

        let testConfiguration2 = KetchSDK.Configuration(
            language: nil,
            organization: nil,
            property: nil,
            environments: nil,
            jurisdiction: nil,
            identities: nil,
            scripts: nil,
            environment: nil,
            deployment: nil,
            privacyPolicy: nil,
            termsOfService: nil,
            rights: nil,
            regulations: ["ccpaca"],
            theme: nil,
            experience: nil,
            purposes: nil,
            canonicalPurposes: nil,
            services: nil,
            options: nil,
            legalBases: nil,
            vendors: nil
        )

        let ccpa2 = CCPA()
        ccpa2.configLoaded(testConfiguration2)
        XCTAssert(ccpa2.isApplied)
    }

    func test_isCCPA_notAplicable() {
        let testConfiguration_notApplicable_1 = KetchSDK.Configuration(
            language: nil,
            organization: nil,
            property: nil,
            environments: nil,
            jurisdiction: nil,
            identities: nil,
            scripts: nil,
            environment: nil,
            deployment: nil,
            privacyPolicy: nil,
            termsOfService: nil,
            rights: nil,
            regulations: ["some_other"],
            theme: nil,
            experience: nil,
            purposes: nil,
            canonicalPurposes: nil,
            services: nil,
            options: nil,
            legalBases: nil,
            vendors: nil
        )

        let ccpa = CCPA()
        ccpa.configLoaded(testConfiguration_notApplicable_1)
        XCTAssertFalse(ccpa.isApplied)

        let testConfiguration_notApplicable_2 = KetchSDK.Configuration(
            language: nil,
            organization: nil,
            property: nil,
            environments: nil,
            jurisdiction: nil,
            identities: nil,
            scripts: nil,
            environment: nil,
            deployment: nil,
            privacyPolicy: nil,
            termsOfService: nil,
            rights: nil,
            regulations: [],
            theme: nil,
            experience: nil,
            purposes: nil,
            canonicalPurposes: nil,
            services: nil,
            options: nil,
            legalBases: nil,
            vendors: nil
        )

        let ccpa2 = CCPA()
        ccpa2.configLoaded(testConfiguration_notApplicable_2)
        XCTAssertFalse(ccpa2.isApplied)

        let testConfiguration_notApplicable_3 = KetchSDK.Configuration(
            language: nil,
            organization: nil,
            property: nil,
            environments: nil,
            jurisdiction: nil,
            identities: nil,
            scripts: nil,
            environment: nil,
            deployment: nil,
            privacyPolicy: nil,
            termsOfService: nil,
            rights: nil,
            regulations: nil,
            theme: nil,
            experience: nil,
            purposes: nil,
            canonicalPurposes: nil,
            services: nil,
            options: nil,
            legalBases: nil,
            vendors: nil
        )

        let ccpa3 = CCPA()
        ccpa3.configLoaded(testConfiguration_notApplicable_3)
        XCTAssertFalse(ccpa3.isApplied)
    }

    func test_CCPA_consentChanged() {
        let testDefaults = UserDefaults()
        let ccpa = CCPA(userDefaults: testDefaults)
        ccpa.configLoaded(Self.testConfiguration)
        ccpa.consentChanged(Self.testConsent)

        let USPrivacy_String_Key = "IABUSPrivacy_String"
        let USPrivacy_Applied_Key = "IABUSPrivacy_Applied"

        let privacy_String = testDefaults.value(forKey: USPrivacy_String_Key) as? String
        XCTAssertEqual(privacy_String, "1NYN")

        let privacy_Applied = testDefaults.value(forKey: USPrivacy_Applied_Key) as? Bool
        XCTAssertNotNil(privacy_Applied)
        XCTAssert(privacy_Applied!)
    }

    func test_CCPA_encoding() {
        let ccpa = CCPA()
        ccpa.configLoaded(Self.testConfiguration)

        let encodedString = ccpa.encode(with: Self.testConsent, notice: true, lspa: true)

        XCTAssertEqual(encodedString, "1YYY")
    }
}

extension CCPA_Tests {
    static let testConfiguration = KetchSDK.Configuration(
        language: nil,
        organization: .init(code: "transcenda"),
        property: .init(code: "property", name: "property", platform: "iOS"),
        environments: [.init(code: "stage", pattern: nil, hash: "1333812840345508246")],
        jurisdiction: .init(code: "default", defaultJurisdictionCode: "default", variable: nil, jurisdictions: nil),
        identities: ["swb_prop": .init(type: "managedCookie", variable: "_swb", jwtKey: nil, jwtLocation: nil)],
        scripts: nil,
        environment: .init(code: "stage", pattern: nil, hash: "1333812840345508246"),
        deployment: .init(code: "default_deployment_plan", version: 1662711181),
        privacyPolicy: .init(code: nil, version: 0, url: nil),
        termsOfService: .init(code: nil, version: 0, url: nil),
        rights: nil,
        regulations: ["gdpreu", "ccpaca", "some_other"],
        theme: nil,
        experience: nil,
        purposes: [
            .init(
                code: "essential_services",
                name: "Essential Services",
                description: "Collection and processing of personal data to enable functionality that is essential to providing our services, including security activities, debugging, authentication, and fraud prevention, as well as contacting you with information related to products/services you have used or purchased; we may set essential cookies or other trackers for these purposes.",
                legalBasisCode: "disclosure",
                requiresPrivacyPolicy: true,
                requiresOptIn: true,
                allowsOptOut: nil,
                requiresDisplay: true,
                categories: nil,
                tcfType: "purpose",
                tcfID: "1",
                canonicalPurposeCode: "essential_services",
                legalBasisName: "Disclosure",
                legalBasisDescription: "Data subject has been provided with adequate disclosure regarding the processing"
            )
        ],
        canonicalPurposes: [
            "analytics": .init(
                code: "analytics",
                name: "analytics",
                purposeCodes: ["analytics", "tcf.purpose_1", "somepurpose_key"]
            ),
            "behavioral_advertising": .init(
                code: "behavioral_advertising",
                name: "behavioral_advertising",
                purposeCodes: ["behavioral_advertising", "tcf.purpose_1", "somepurpose_key"]
            ),
            "data_broking": .init(
                code: "data_broking",
                name: "data_broking",
                purposeCodes: ["data_broking", "tcf.purpose_1", "somepurpose_key"]
            )
        ],
        services: ["lanyard": "https://global.ketchcdn.com/transom/route/switchbit/lanyard/transcenda/lanyard.js"],
        options: ["appDivs": "hubspot-messages-iframe-container"],
        legalBases: nil,
        vendors: nil
    )

    static let testConsent = KetchSDK.ConsentStatus(
        purposes: [
            "analytics": true,
            "behavioral_advertising": true,
            "data_broking": true,
            "email_marketing": true,
            "essential_services": true,
            "somepurpose_key": true,
            "tcf.purpose_1": true
        ],
        vendors: nil
    )
}
