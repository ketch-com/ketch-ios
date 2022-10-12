import XCTest
import Combine
@testable import KetchSDK

class Tests: XCTestCase {
    var sut: KetchApiRequest!
    var ketchApiRequestPublisher = PassthroughSubject<[String: Any], ApiClientError>()
    var subscriptions = Set<AnyCancellable>()

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.

        sut = KetchApiRequest(apiClient: ApiClientMock(publisher: ketchApiRequestPublisher))
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testInvokeRights() {
        let expectation = expectation(description: "")

        sut.invokeRights(
            config: InvokeRightConfig(
                organizationCode: "transcenda",
                controllerCode: "my_controller",
                propertyCode: "website_smart_tag",
                environmentCode: "production",
                identities: ["idfa" : "00000000-0000-0000-0000-000000000000"],
                invokedAt: nil,
                jurisdictionCode: "default",
                rightCode: "gdpr_portability",
                user: InvokeRightConfig.User(
                    email: "user@email.com",
                    first: "FirstName",
                    last: "LastName",
                    country: nil,
                    stateRegion: nil,
                    description: nil,
                    phone: nil,
                    postalCode: nil,
                    addressLine1: nil,
                    addressLine2: nil
                )
            )
        )
        .sink { error in

        } receiveValue: { value in
            expectation.fulfill()
        }
        .store(in: &subscriptions)

        ketchApiRequestPublisher.send([:])

        waitForExpectations(timeout: 0.1)
    }

    func testSetConsent() {
        let expectation = expectation(description: "")

        sut.updateConsent(
            update: ConsentUpdate(
                organizationCode: "transcenda",
                controllerCode: "my_controller",
                propertyCode: "website_smart_tag",
                environmentCode: "production",
                identities: ["idfa" : "00000000-0000-0000-0000-000000000000"],
                collectedAt: nil,
                jurisdictionCode: "default",
                migrationOption: .migrateDefault,
                purposes: [
                    "essential_services": ConsentUpdate.PurposeAllowedLegalBasis(allowed: true, legalBasisCode: "disclosure"),
                    "analytics": ConsentUpdate.PurposeAllowedLegalBasis(allowed: true, legalBasisCode: "disclosure"),
                    "behavioral_advertising": ConsentUpdate.PurposeAllowedLegalBasis(allowed: true, legalBasisCode: "disclosure"),
                    "email_marketing": ConsentUpdate.PurposeAllowedLegalBasis(allowed: true, legalBasisCode: "disclosure"),
                    "tcf.purpose_1": ConsentUpdate.PurposeAllowedLegalBasis(allowed: true, legalBasisCode: "consent_optin"),
                    "somepurpose_key": ConsentUpdate.PurposeAllowedLegalBasis(allowed: true, legalBasisCode: "consent_optin")
                ],
                vendors: nil
            )
        )
        .sink { error in

        } receiveValue: { value in
            expectation.fulfill()
        }
        .store(in: &subscriptions)

        ketchApiRequestPublisher.send([:])

        waitForExpectations(timeout: 0.1)
    }

    func testGetConsent() {
        let expectation = expectation(description: "")

        sut.getConsent(
            config: ConsentConfig(
                organizationCode: "transcenda",
                controllerCode: "my_controller",
                propertyCode: "website_smart_tag",
                environmentCode: "production",
                jurisdictionCode: "default",
                identities: ["idfa" : "00000000-0000-0000-0000-000000000000"],
                purposes: [
                    "essential_services": ConsentConfig.PurposeLegalBasis(legalBasisCode: "disclosure"),
                    "analytics": ConsentConfig.PurposeLegalBasis(legalBasisCode: "disclosure"),
                    "behavioral_advertising": ConsentConfig.PurposeLegalBasis(legalBasisCode: "disclosure"),
                    "email_marketing": ConsentConfig.PurposeLegalBasis(legalBasisCode: "disclosure"),
                    "tcf.purpose_1": ConsentConfig.PurposeLegalBasis(legalBasisCode: "consent_optin"),
                    "somepurpose_key": ConsentConfig.PurposeLegalBasis(legalBasisCode: "consent_optin")
                ]
            )
        )
        .sink { error in

        } receiveValue: { value in
            expectation.fulfill()
        }
        .store(in: &subscriptions)

        ketchApiRequestPublisher.send(
            [
                "purposes": [
                    "tcf.purpose_1": true,
                    "behavioral_advertising": true,
                    "email_marketing": true,
                    "essential_services": true,
                    "analytics": true,
                    "somepurpose_key": true
                ]
            ]
        )

        waitForExpectations(timeout: 0.1)
    }

    func testFetchBootConfig() {
        let expectation = expectation(description: "")

        sut.fetchBootConfig()
        .sink { error in

        } receiveValue: { value in
            expectation.fulfill()
        }
        .store(in: &subscriptions)

        ketchApiRequestPublisher.send(
            [
                "v": 1,
                "organization": [
                    "code": "transcenda"
                ],
                "app": [
                    "code": "website_smart_tag",
                    "name": "Website Smart Tag",
                    "platform": "WEB"
                ],
                "environments": [
                    [
                        "code": "production",
                        "pattern": "Lio=",
                        "hash": "13742211039722691379"
                    ]
                ],
                "policyScope": [
                    "defaultScopeCode": "default",
                    "scopes": [
                        "DK": "gdpr",
                        "GG": "gdpr",
                        "GP": "gdpr",
                        "US-CA": "ccpa",
                        "IE": "gdpr",
                        "IS": "gdpr",
                        "GB": "gdpr",
                        "MF": "gdpr",
                        "YT": "gdpr",
                        "SE": "gdpr",
                        "BE": "gdpr",
                        "BG": "gdpr",
                        "NO": "gdpr",
                        "LI": "gdpr",
                        "NL": "gdpr",
                        "SJ": "gdpr",
                        "RE": "gdpr",
                        "JE": "gdpr",
                        "GF": "gdpr",
                        "SK": "gdpr",
                        "LV": "gdpr",
                        "AT": "gdpr",
                        "GR": "gdpr",
                        "FI": "gdpr",
                        "HU": "gdpr",
                        "HR": "gdpr",
                        "RO": "gdpr",
                        "ES": "gdpr",
                        "FR": "gdpr",
                        "UA": "gdpr",
                        "IT": "gdpr",
                        "PT": "gdpr",
                        "PL": "gdpr",
                        "LT": "gdpr",
                        "MT": "gdpr",
                        "LU": "gdpr",
                        "FO": "gdpr",
                        "IM": "gdpr",
                        "EE": "gdpr",
                        "MQ": "gdpr",
                        "DE": "gdpr",
                        "CZ": "gdpr",
                        "SI": "gdpr",
                        "CY": "gdpr"
                    ]
                ],
                "identities": [
                    "swb_website_smart_tag": [
                        "type": "managedCookie",
                        "variable": "_swb",
                        "jwtKey": nil,
                        "jwtLocation": nil
                    ]
                ],
                "scripts": [
                    "https://global.ketchcdn.com/transom/route/switchbit/semaphore/transcenda/semaphore.js",
                    "https://global.ketchcdn.com/transom/route/switchbit/tcf/transcenda/tcf.js",
                    "https://global.ketchcdn.com/transom/route/switchbit/ccpa/transcenda/ccpa.js"
                ],
                "languages": [
                    [
                        "code": "uk",
                        "englishName": "Ukrainian (uk)",
                        "nativeName": nil
                    ],
                    [
                        "code": "en",
                        "englishName": "English",
                        "nativeName": "English"
                    ]
                ],
                "services": [
                    "shoreline": "https://global.ketchcdn.com/web/v2/",
                    "lanyard": "https://global.ketchcdn.com/transom/route/switchbit/lanyard/transcenda/lanyard.js"
                ],
                "options": [
                    "migration": 1,
                    "localStorage": 1
                ],
                "optionsNew": [
                    "localStorage": "1",
                    "migration": "1",
                    "appDivs": "hubspot-messages-iframe-container"
                ],
                "property": [
                    "code": "website_smart_tag",
                    "name": "Website Smart Tag",
                    "platform": "WEB"
                ],
                "jurisdiction": [
                    "defaultScopeCode": "default",
                    "scopes": [
                        "LU": "gdpr",
                        "MT": "gdpr",
                        "CZ": "gdpr",
                        "NL": "gdpr",
                        "YT": "gdpr",
                        "LV": "gdpr",
                        "GR": "gdpr",
                        "IT": "gdpr",
                        "GF": "gdpr",
                        "BG": "gdpr",
                        "UA": "gdpr",
                        "IS": "gdpr",
                        "DK": "gdpr",
                        "FR": "gdpr",
                        "JE": "gdpr",
                        "ES": "gdpr",
                        "HU": "gdpr",
                        "MF": "gdpr",
                        "IM": "gdpr",
                        "US-CA": "ccpa",
                        "SE": "gdpr",
                        "MQ": "gdpr",
                        "IE": "gdpr",
                        "SJ": "gdpr",
                        "NO": "gdpr",
                        "SK": "gdpr",
                        "GB": "gdpr",
                        "EE": "gdpr",
                        "GG": "gdpr",
                        "BE": "gdpr",
                        "SI": "gdpr",
                        "FO": "gdpr",
                        "LI": "gdpr",
                        "PL": "gdpr",
                        "CY": "gdpr",
                        "RO": "gdpr",
                        "GP": "gdpr",
                        "HR": "gdpr",
                        "LT": "gdpr",
                        "FI": "gdpr",
                        "AT": "gdpr",
                        "PT": "gdpr",
                        "RE": "gdpr",
                        "DE": "gdpr"
                    ]
                ]
            ]
        )

        waitForExpectations(timeout: 0.1)
    }

//    func testFetchConfig() {
//        let expectation = expectation(description: "")
//
//        sut.fetchConfig()
//        .sink { error in
//
//        } receiveValue: { value in
//            expectation.fulfill()
//        }
//        .store(in: &subscriptions)
//
//        ketchApiRequestPublisher.send(
//            [
//                language: "en",
//                organization: KetchSDK.Configuration.Organization(code: "transcenda"))), property: KetchSDK.Configuration.Property(code: "website_smart_tag"), name: "Website Smart Tag"), platform: "WEB"))), environments: [KetchSDK.Configuration.Environment(code: "production"), pattern: nil, hash: "13742211039722691379"))]), jurisdiction: KetchSDK.Configuration.Jurisdiction(code: "default"), defaultJurisdictionCode: "default"), variable: nil, jurisdictions: nil)), identities: ["swb_website_smart_tag": KetchSDK.Configuration.Identity(type: "managedCookie"), variable: "_swb"), jwtKey: nil, jwtLocation: nil)]), scripts: nil, environment: KetchSDK.Configuration.Environment(code: "production"), pattern: nil, hash: "13742211039722691379"))), deployment: KetchSDK.Configuration.Deployment(code: "default_deployment_plan"), version: 1662711181))), privacyPolicy: KetchSDK.Configuration.Policy(code: nil, version: nil, url: nil)), termsOfService: KetchSDK.Configuration.Policy(code: nil, version: nil, url: nil)), rights: [KetchSDK.Configuration.Right(code: "cmn_delete"), name: "Data Deletion"), description: "Right to have data deleted")), KetchSDK.Configuration.Right(code: "cmn_access"), name: "Data Access"), description: "Right to be provided with a copy of data")), KetchSDK.Configuration.Right(code: "cmn_port"), name: "Data Portability"), description: "Right to obtain and request transfer of data")), KetchSDK.Configuration.Right(code: "cmn_correction"), name: "Data Correction"), description: "Right to have inaccurate personal information corrected"))]), regulations: ["default"]), theme: KetchSDK.Configuration.Theme(code: "default"), name: "Default"), description: "Ketch default theme"), bannerBackgroundColor: "#01090E"), lightboxRibbonColor: nil, formHeaderColor: nil, statusColor: nil, highlightColor: nil, feedbackColor: nil, font: nil, buttonBorderRadius: 5), bannerContentColor: "#ffffff"), bannerButtonColor: "#ffffff"), modalHeaderBackgroundColor: "#f6f6f6"), modalHeaderContentColor: nil, modalContentColor: "#071a24"), modalButtonColor: "#071a24"), formHeaderBackgroundColor: "#071a24"), formHeaderContentColor: nil, formContentColor: "#071a24"), formButtonColor: "#071a24"), bannerPosition: 1), modalPosition: 1))), experience: nil, purposes: [KetchSDK.Configuration.Purpose(code: "essential_services", name: "Essential Services"), description: "Collection and processing of personal data to enable functionality that is essential to providing our services, including security activities, debugging, authentication, and fraud prevention, as well as contacting you with information related to products/services you have used or purchased; we may set essential cookies or other trackers for these purposes."), legalBasisCode: "disclosure", requiresPrivacyPolicy: true), requiresOptIn: nil, allowsOptOut: nil, requiresDisplay: true), categories: nil, tcfType: nil, tcfID: nil, canonicalPurposeCode: "essential_services"), legalBasisName: "Disclosure"), legalBasisDescription: "Data subject has been provided with adequate disclosure regarding the processing")), KetchSDK.Configuration.Purpose(code: "analytics", name: "Analytics"), description: "Collection and analysis of personal data to further our business goals; for example, analysis of behavior of website visitors, creation of target lists for marketing and sales, and measurement of advertising performance."), legalBasisCode: "disclosure", requiresPrivacyPolicy: true), requiresOptIn: nil, allowsOptOut: nil, requiresDisplay: true), categories: nil, tcfType: nil, tcfID: nil, canonicalPurposeCode: "analytics"), legalBasisName: "Disclosure"), legalBasisDescription: "Data subject has been provided with adequate disclosure regarding the processing")), KetchSDK.Configuration.Purpose(code: "behavioral_advertising", name: "Behavioral Advertising"), description: "Creation and activation of advertisements based on a profile informed by the collection and analysis of behavioral and personal characteristics; we may set cookies or other trackers for this purpose."), legalBasisCode: "disclosure", requiresPrivacyPolicy: true), requiresOptIn: nil, allowsOptOut: nil, requiresDisplay: true), categories: nil, tcfType: nil, tcfID: nil, canonicalPurposeCode: "behavioral_advertising"), legalBasisName: "Disclosure"), legalBasisDescription: "Data subject has been provided with adequate disclosure regarding the processing")), KetchSDK.Configuration.Purpose(code: "email_marketing", name: "Email Marketing"), description: "Marketing of our products/services to customers by email."), legalBasisCode: "disclosure", requiresPrivacyPolicy: true), requiresOptIn: nil, allowsOptOut: nil, requiresDisplay: true), categories: nil, tcfType: nil, tcfID: nil, canonicalPurposeCode: "email_mktg"), legalBasisName: "Disclosure"), legalBasisDescription: "Data subject has been provided with adequate disclosure regarding the processing")), KetchSDK.Configuration.Purpose(code: "tcf.purpose_1", name: "Store and/or access information on a device"), description: "Cookies, device identifiers, or other information can be stored or accessed on your device for the purposes presented to you."), legalBasisCode: "consent_optin", requiresPrivacyPolicy: true), requiresOptIn: true), allowsOptOut: true), requiresDisplay: true), categories: nil, tcfType: "purpose"), tcfID: "1"), canonicalPurposeCode: "analytics"), legalBasisName: "Consent - Opt In"), legalBasisDescription: "Data subject has affirmatively and unambiguously consented to the processing for one or more specific purposes")), KetchSDK.Configuration.Purpose(code: "somepurpose_key", name: "Some Purpose"), description: "Description"), legalBasisCode: "consent_optin", requiresPrivacyPolicy: true), requiresOptIn: true), allowsOptOut: true), requiresDisplay: true), categories: nil, tcfType: nil, tcfID: nil, canonicalPurposeCode: "analytics"), legalBasisName: "Consent - Opt In"), legalBasisDescription: "Data subject has affirmatively and unambiguously consented to the processing for one or more specific purposes"))]), canonicalPurposes: ["analytics": KetchSDK.Configuration.CanonicalPurpose(code: "analytics"), name: "analytics"), purposeCodes: ["analytics", "tcf.purpose_1", "somepurpose_key"])), "behavioral_advertising": KetchSDK.Configuration.CanonicalPurpose(code: "behavioral_advertising"), name: "behavioral_advertising"), purposeCodes: ["behavioral_advertising"])), "email_mktg": KetchSDK.Configuration.CanonicalPurpose(code: "email_mktg"), name: "email_mktg"), purposeCodes: ["email_marketing"])), "essential_services": KetchSDK.Configuration.CanonicalPurpose(code: "essential_services"), name: "essential_services"), purposeCodes: ["essential_services"]))]), services: ["lanyard": "https://global.ketchcdn.com/transom/route/switchbit/lanyard/transcenda/lanyard.js", "shoreline": "https://global.ketchcdn.com/web/v2/"]), options: ["appDivs": "hubspot-messages-iframe-container", "migration": "1", "localStorage": "1"]), legalBases: nil, vendors: nil
//            ]
//        )
//
//        waitForExpectations(timeout: 0.1)
//    }
}
