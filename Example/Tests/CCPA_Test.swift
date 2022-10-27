//
//  CCPA_Test.swift
//  KetchSDK_Tests
//
//  Created by Anton Lyfar on 25.10.2022.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import XCTest
@testable import KetchSDK

class CCPA_Test: XCTestCase {
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

        XCTAssertNoThrow(try CCPA(with: testConfiguration1))

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

        XCTAssertNoThrow(try CCPA(with: testConfiguration2))
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

        XCTAssertThrowsError(
            try CCPA(with: testConfiguration_notApplicable_1),
            "Error on CCPA init. CCPA is not applied to config"
        ) { error in
            XCTAssertNotNil(error as? PolicyPluginError)
        }

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

        XCTAssertThrowsError(
            try CCPA(with: testConfiguration_notApplicable_2),
            "Error on CCPA init. CCPA is not applied to config"
        ) { error in
            XCTAssertNotNil(error as? PolicyPluginError)
        }

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

        XCTAssertThrowsError(
            try CCPA(with: testConfiguration_notApplicable_3),
            "Error on CCPA init. CCPA is not applied to config"
        ) { error in
            XCTAssertNotNil(error as? PolicyPluginError)
        }
    }

    func test_CCPA_consentChanged() {
        let testDefaults = UserDefaults()
        let ccpa = try? CCPA(with: Self.testConfiguration, userDefaults: testDefaults)
        XCTAssertNotNil(ccpa)

        ccpa?.consentChanged(consent: Self.testConsent)

        let USPrivacy_String_Key = "IABUSPrivacy_String"
        let USPrivacy_Applied_Key = "IABUSPrivacy_Applied"

        let privacy_String = testDefaults.value(forKey: USPrivacy_String_Key) as? String
        XCTAssertEqual(privacy_String, "1NYN")

        let privacy_Applied = testDefaults.value(forKey: USPrivacy_Applied_Key) as? Bool
        XCTAssertNotNil(privacy_Applied)
        XCTAssert(privacy_Applied!)
    }

    func test_CCPA_encoding() {
        let ccpa = try? CCPA(with: Self.testConfiguration)
        XCTAssertNotNil(ccpa)

        let encodedString = ccpa?.encode(with: Self.testConsent, notice: true, lspa: true)

        XCTAssertEqual(encodedString, "1YYY")
    }

    func test_TCF_encoding() {
        let tcf = try? TCF(with: Self.testConfiguration, vendorListVersion: 128)
        XCTAssertNotNil(tcf)

        let encodedString = tcf?.encode(with: Self.testConsent)

        XCTAssertEqual(encodedString, "1YYY")
    }
}

private extension KetchSDK.ConsentStatus {
    init(
        purposes: [String: Bool],
        vendors: [String]?
    ) {
        self.purposes = purposes
        self.vendors = vendors
    }
}

extension CCPA_Test {
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
