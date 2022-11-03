//
//  TCF_Tests.swift
//  KetchSDK_Tests
//
//  Created by Anton Lyfar on 01.11.2022.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import XCTest
@testable import KetchSDK

class TCF_Tests: XCTestCase {
    func test_isTCF_aplicable() {
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
            regulations: ["gdpreu", "some_other"],
            theme: nil,
            experience: nil,
            purposes: nil,
            canonicalPurposes: nil,
            services: nil,
            options: nil,
            legalBases: nil,
            vendors: nil
        )

        XCTAssertNoThrow(try TCF(with: testConfiguration1, vendorListVersion: 128))

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
            regulations: ["gdpreu"],
            theme: nil,
            experience: nil,
            purposes: nil,
            canonicalPurposes: nil,
            services: nil,
            options: nil,
            legalBases: nil,
            vendors: nil
        )

        XCTAssertNoThrow(try TCF(with: testConfiguration2, vendorListVersion: 128))
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
            try TCF(with: testConfiguration_notApplicable_1, vendorListVersion: 128),
            "Error on TCF init. TCF is not applied to config"
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
            try TCF(with: testConfiguration_notApplicable_2, vendorListVersion: 128),
            "Error on TCF init. TCF is not applied to config"
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
            try TCF(with: testConfiguration_notApplicable_3, vendorListVersion: 128),
            "Error on TCF init. TCF is not applied to config"
        ) { error in
            XCTAssertNotNil(error as? PolicyPluginError)
        }
    }

    func test_CCPA_consentChanged() {
        let testDefaults = UserDefaults()
        let tcf = try? TCF(with: Self.testConfiguration, vendorListVersion: 128, userDefaults: testDefaults)
        XCTAssertNotNil(tcf)

        tcf?.consentChanged(consent: Self.testConsent)

        let TCF_TCString_Key = "IABTCF_TCString"
        let TCF_gdprApplies_Key = "IABTCF_gdprApplies"

        let privacy_String = testDefaults.value(forKey: TCF_TCString_Key) as? String
        XCTAssertNotNil(privacy_String)
        let startIndex = privacy_String!.index(privacy_String!.startIndex, offsetBy: 1)
        let endIndex = privacy_String!.index(privacy_String!.startIndex, offsetBy: 12)
        let dateFieldOmittedEncodedString = privacy_String!.replacingCharacters(in: startIndex...endIndex, with: "___")
        XCTAssertEqual(dateFieldOmittedEncodedString, "C___ACABAENCAAgAAAAAAAAACiQH2QAYH0AfYB9kAGB9AH2AAA")

        let privacy_Applied = testDefaults.value(forKey: TCF_gdprApplies_Key) as? Bool
        XCTAssertNotNil(privacy_Applied)
        XCTAssert(privacy_Applied!)
    }

    func test_TCF_encoding() {
        let tcf = try? TCF(with: Self.testConfiguration, vendorListVersion: 128)
        XCTAssertNotNil(tcf)

        let encodedString = tcf?.encode(with: Self.testConsent)

        let startIndex = encodedString!.index(encodedString!.startIndex, offsetBy: 1)
        let endIndex = encodedString!.index(encodedString!.startIndex, offsetBy: 12)
        let dateFieldOmittedEncodedString = encodedString!.replacingCharacters(in: startIndex...endIndex, with: "___")

        XCTAssertEqual(dateFieldOmittedEncodedString, "C___ACABAENCAAgAAAAAAAAACiQH2QAYH0AfYB9kAGB9AH2AAA")
    }

    func test_TCFencoder_encoding() {
        let dateFormatter = DateFormatter()
          dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"

        let created = "2020-02-20T23:57:39.300Z"
        let updated = "2020-02-20T23:57:39.300Z"
        let dateCreated = dateFormatter.date(from:created)!
        let dateUpdated = dateFormatter.date(from:updated)!

        let encoder = TCStringEncoderV2(
            version: 2,
            created: dateCreated,
            updated: dateUpdated,
            cmpId: 27,
            cmpVersion: 0,
            consentLanguage: "EN",
            vendorListVersion: 15,
            purposesConsent: [1, 2, 3],
            vendorsConsent: Set([2, 6, 8]),
            tcfPolicyVersion: 2,
            isServiceSpecific: false,
            useNonStandardStacks: false,
            specialFeatureOptIns: [],
            purposesLITransparency: [],
            publisherCC: "AA",
            vendorLegitimateInterest: Set([2, 6, 8]),
            vendors: []
        )

        let encodedString = try! encoder.encode()

        XCTAssertEqual(encodedString, "COvFyGBOvFyGBAbAAAENAPCAAOAAAAAAAAAAAEEUACCKAAA")
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

extension TCF_Tests {
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
        vendors: [
            .init(
                id: "1000",
                name: "NETILUM (AFFILAE)",
                purposes: [
                    .init(name: "Store and/or access information on a device", legalBasis: "Consent - Opt In"),
                    .init(name: "Measure ad performance", legalBasis: "Consent - Opt In"),
                    .init(name: "Measure content performance", legalBasis: "Consent - Opt In")
                ],
                specialPurposes: nil,
                features: [
                    .init(name: "Disclosure", legalBasis: "Receive and use automatically-sent device characteristics for identification")
                ],
                specialFeatures: [
                    .init(name: "Consent - Opt In", legalBasis: "Actively scan device characteristics for identification")
                ],
                policyUrl: "https://affilae.com/en/privacy-cookie-policy",
                cookieMaxAgeSeconds: 34164000,
                usesCookies: true,
                usesNonCookieAccess: nil
            ),
            .init(
                id: "1001",
                name: "wetter.com GmbH",
                purposes: [
                    .init(name: "Store and/or access information on a device", legalBasis: "Consent - Opt In"),
                    .init(name: "Select basic ads", legalBasis: "Consent - Opt In"),
                    .init(name: "Create a personalised ads profile", legalBasis: "Consent - Opt In"),
                    .init(name: "Select personalised ads", legalBasis: "Consent - Opt In"),
                    .init(name: "Create a personalised content profile", legalBasis: "Consent - Opt In"),
                    .init(name: "Select personalised content", legalBasis: "Consent - Opt In"),
                    .init(name: "Measure ad performance", legalBasis: "Consent - Opt In"),
                    .init(name: "Measure content performance", legalBasis: "Consent - Opt In"),
                    .init(name: "Apply market research to generate audience insights", legalBasis: "Consent - Opt In"),
                    .init(name: "Develop and improve products", legalBasis: "Consent - Opt In")
                ],
                specialPurposes: nil,
                features: [
                    .init(name: "Match and combine offline data sources", legalBasis: "Disclosure")
                ],
                specialFeatures: [
                    .init(name: "Use precise geolocation data", legalBasis: "Consent - Opt In")
                ],
                policyUrl: "https://www.wetter.com/internal/news/datenschutzhinweise_aid_607698849b8ecf79e21584fa.html",
                cookieMaxAgeSeconds: nil,
                usesCookies: true,
                usesNonCookieAccess: true
            ),
            .init(
                id: "1002",
                name: "Extreme Reach, Inc",
                purposes: [
                    .init(name: "Consent - Opt In", legalBasis: "Store and/or access information on a device"),
                    .init(name: "Consent - Opt In", legalBasis: "Select basic ads"),
                    .init(name: "Consent - Opt In", legalBasis: "Measure ad performance"),
                    .init(name: "Consent - Opt In", legalBasis: "Develop and improve products")
                ],
                specialPurposes: nil,
                features: [
                    .init(name: "Link different devices", legalBasis: "Disclosure")
                ],
                specialFeatures: nil,
                policyUrl: "https://extremereach.com/privacy-policies/",
                cookieMaxAgeSeconds: 63072000,
                usesCookies: true,
                usesNonCookieAccess: nil
            ),
            .init(
                id: "1003",
                name: "Mobility-Ads GmbH",
                purposes: [
                    .init(name: "Store and/or access information on a device", legalBasis: "Consent - Opt In"),
                    .init(name: "Measure ad performance", legalBasis: "Legitimate Interest - Objectable")
                ],
                specialPurposes: [
                    .init(name: "Ensure security, prevent fraud, and debug", legalBasis: "Legitimate Interest - Non-Objectable"),
                    .init(name: "Technically deliver ads or content", legalBasis: "Legitimate Interest - Non-Objectable")
                ],
                features: nil,
                specialFeatures: nil,
                policyUrl: "https://mobility-ads.de/datenschutz/",
                cookieMaxAgeSeconds: nil,
                usesCookies: nil,
                usesNonCookieAccess: nil
            ),
            .init(
                id: "1004",
                name: "VUUKLE DMCC",
                purposes: [
                    .init(name: "Store and/or access information on a device", legalBasis: "Consent - Opt In"),
                    .init(name: "Select basic ads", legalBasis: "Legitimate Interest - Objectable"),
                    .init(name: "Select personalised ads", legalBasis: "Legitimate Interest - Objectable"),
                    .init(name: "Create a personalised content profile", legalBasis: "Legitimate Interest - Objectable"),
                    .init(name: "Select personalised content", legalBasis: "Legitimate Interest - Objectable"),
                    .init(name: "Measure ad performance", legalBasis: "Legitimate Interest - Objectable"),
                    .init(name: "Measure content performance", legalBasis: "Legitimate Interest - Objectable"),
                    .init(name: "Apply market research to generate audieinsights", legalBasis: "Legitimate Interest - Objectable"),
                    .init(name: "Develop and improve products", legalBasis: "Legitimate Interest - Objectable")
                ],
                specialPurposes: [
                    .init(name: "Ensure security, prevent fraud, and debug", legalBasis: "Ensure security, prevent fraud, and debug"),
                    .init(name: "Technically deliver ads or content", legalBasis: "Ensure security, prevent fraud, and debug")
                ],
                features: [
                    .init(name: "Link different devices", legalBasis: "Disclosure"),
                    .init(name: "Receive and use automatically-sent device characteristics for identification", legalBasis: "Disclosure")
                ],
                specialFeatures: [
                    .init(name: "Use precise geolocation data", legalBasis: "Consent - Opt In"),
                    .init(name: "Actively scan device characteristics for identification", legalBasis: "Consent - Opt In")
                ],
                policyUrl: "https://docs.vuukle.com/privacy-and-policy/",
                cookieMaxAgeSeconds: 31536000,
                usesCookies: true,
                usesNonCookieAccess: true
            )
        ]
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
        vendors: ["1000", "1001", "1002", "1003", "1004"]
    )
}
