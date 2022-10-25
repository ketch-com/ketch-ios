import XCTest
import Combine
@testable import KetchSDK

class KetchTests: XCTestCase {
    var sut: KetchApiRequest!
    var ketchApiRequestPublisher = PassthroughSubject<[String: Any],
                         ApiClientError>()
    var subscriptions = Set<AnyCancellable>()

    override func setUp() {
        super.setUp()

        sut = KetchApiRequest(apiClient: ApiClientMock(publisher: ketchApiRequestPublisher))
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testInvokeRights() {
        let expectation = expectation(description: "")

        sut.invokeRights(
            config: .init(
                organizationCode: "transcenda",
                controllerCode: "my_controller",
                propertyCode: "website_smart_tag",
                environmentCode: "production",
                identities: ["idfa" : "00000000-0000-0000-0000-000000000000"],
                invokedAt: nil,
                jurisdictionCode: "default",
                rightCode: "gdpr_portability",
                user: .init(
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
            update: .init(
                organizationCode: "transcenda",
                controllerCode: "my_controller",
                propertyCode: "website_smart_tag",
                environmentCode: "production",
                identities: ["idfa" : "00000000-0000-0000-0000-000000000000"],
                collectedAt: nil,
                jurisdictionCode: "default",
                migrationOption: .migrateDefault,
                purposes: [
                    "essential_services": .init(allowed: true, legalBasisCode: "disclosure"),
                    "analytics": .init(allowed: true, legalBasisCode: "disclosure"),
                    "behavioral_advertising": .init(allowed: true, legalBasisCode: "disclosure"),
                    "email_marketing": .init(allowed: true, legalBasisCode: "disclosure"),
                    "tcf.purpose_1": .init(allowed: true, legalBasisCode: "consent_optin"),
                    "somepurpose_key": .init(allowed: true, legalBasisCode: "consent_optin")
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
            config: .init(
                organizationCode: "transcenda",
                controllerCode: "my_controller",
                propertyCode: "website_smart_tag",
                environmentCode: "production",
                jurisdictionCode: "default",
                identities: ["idfa" : "00000000-0000-0000-0000-000000000000"],
                purposes: [
                    "essential_services": .init(legalBasisCode: "disclosure"),
                    "analytics": .init(legalBasisCode: "disclosure"),
                    "behavioral_advertising": .init(legalBasisCode: "disclosure"),
                    "email_marketing": .init(legalBasisCode: "disclosure"),
                    "tcf.purpose_1": .init(legalBasisCode: "consent_optin"),
                    "somepurpose_key": .init(legalBasisCode: "consent_optin")
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

    func testFetchConfig() {
        let expectation = expectation(description: "")

        sut.fetchConfig(organization: "transcenda", property: "website_smart_tag")
        .sink { error in

        } receiveValue: { value in
            expectation.fulfill()
        }
        .store(in: &subscriptions)

        ketchApiRequestPublisher.send(testConfig)

        waitForExpectations(timeout: 0.1)
    }

    private var testConfig: [String: Any] {
        [
            "canonicalPurposes": [
                "analytics": [
                    "code": "analytics",
                    "name": "analytics",
                    "purposeCodes": [
                        "analytics",
                        "tcf.purpose_1",
                        "somepurpose_key"
                    ]
                ],
                "behavioral_advertising": [
                    "code": "behavioral_advertising",
                    "name": "behavioral_advertising",
                    "purposeCodes": [
                        "behavioral_advertising"
                    ]
                ],
                "email_mktg": [
                    "code": "email_mktg",
                    "name": "email_mktg",
                    "purposeCodes": [
                        "email_marketing"
                    ]
                ],
                "essential_services": [
                    "code": "essential_services",
                    "name": "essential_services",
                    "purposeCodes": [
                        "essential_services"
                    ]
                ]
            ],
            "deployment": [
                "code": "default_deployment_plan",
                "version": 1662711181
            ],
            "environment": [
                "code": "production",
                "hash": "10131461971991911401"
            ],
            "environments": [
                [
                    "code": "production",
                    "hash": "10131461971991911401"
                ]
            ],
            "experiences": [
                "consent": [
                    "banner": [
                        "buttonText": "I understand",
                        "footerDescription": "Welcome! We’re glad you’re here and want you to know that we respect your privacy and your right to control how we collect, use, and share your personal data.",
                        "primaryButtonAction": 1,
                        "secondaryButtonDestination": 2,
                        "title": "Your Privacy"
                    ],
                    "code": "default_consent___disclosure",
                    "experienceDefault": 1,
                    "jit": [
                        "acceptButtonText": "Save choices",
                        "bodyDescription": "Please indicate whether you consent to our collection and use of your data in order to perform the operation(s) you’ve requested.",
                        "declineButtonText": "Cancel",
                        "moreInfoDestination": 1,
                        "title": "Your Privacy"
                    ],
                    "modal": [
                        "bodyDescription": "Welcome! We’re glad you're here and want you to know that we respect your privacy and your right to control how we collect, use, and share your personal data. Listed below are the purposes for which we process your data--please indicate whether you consent to such processing.",
                        "buttonText": "Save choices",
                        "title": "Your Privacy"
                    ],
                    "version": 1663598228
                ],
                "preference": [
                    "code": "default_preference_management",
                    "consents": [
                        "bodyDescription": "We collect and use data--including, where applicable, your personal data--for the purposes listed below. Please indicate whether or not that's ok with you by toggling the switches below.",
                        "bodyTitle": "Choose how we use your data",
                        "buttonText": "Submit",
                        "tabName": "Preferences"
                    ],
                    "overview": [
                        "bodyDescription": "Welcome! We're glad you're here and want you to know that we respect your privacy and your right to control how we collect, use, and store your personal data.",
                        "tabName": "Overview"
                    ],
                    "rights": [
                        "bodyDescription": "Applicable privacy laws give you certain rights with respect to our collection, use, and storage of your personal data, and we welcome your exercise of those rights. Please complete the form below so that we can validate and fulfill your request.",
                        "bodyTitle": "Exercise your rights",
                        "buttonText": "Submit",
                        "tabName": "Your Rights"
                    ],
                    "title": "Your Privacy",
                    "version": 1662711180
                ]
            ],
            "identities": [
                "swb_website_smart_tag": [
                    "type": "managedCookie",
                    "variable": "_swb"
                ]
            ],
            "jurisdiction": [
                "code": "gdpr",
                "defaultJurisdictionCode": "default"
            ],
            "language": "en",
            "options": [
                "appDivs": "hubspot-messages-iframe-container",
                "localStorage": "1",
                "migration": "1"
            ],
            "organization": [
                "code": "transcenda"
            ],
            "privacyPolicy": [:],
            "property": [
                "code": "website_smart_tag",
                "name": "Website Smart Tag",
                "platform": "WEB"
            ],
            "purposes": [
                [
                    "canonicalPurposeCode": "essential_services",
                    "code": "essential_services",
                    "description": "Collection and processing of personal data to enable functionality that is essential to providing our services, including security activities, debugging, authentication, and fraud prevention, as well as contacting you with information related to products/services you have used or purchased; we may set essential cookies or other trackers for these purposes.",
                    "legalBasisCode": "legitimateinterest",
                    "legalBasisDescription": "Necessary for the purposes of the legitimate interests pursued by the controller or by a third party, except where such interests are overridden by the interests or fundamental rights and freedoms of the data subject",
                    "legalBasisName": "Legitimate Interest - Non-Objectable",
                    "name": "Essential Services",
                    "requiresDisplay": true,
                    "requiresPrivacyPolicy": true
                ],
                [
                    "allowsOptOut": true,
                    "canonicalPurposeCode": "analytics",
                    "code": "analytics",
                    "description": "Collection and analysis of personal data to further our business goals; for example, analysis of behavior of website visitors, creation of target lists for marketing and sales, and measurement of advertising performance.",
                    "legalBasisCode": "consent_optin",
                    "legalBasisDescription": "Data subject has affirmatively and unambiguously consented to the processing for one or more specific purposes",
                    "legalBasisName": "Consent - Opt In",
                    "name": "Analytics",
                    "requiresDisplay": true,
                    "requiresOptIn": true,
                    "requiresPrivacyPolicy": true
                ],
                [
                    "allowsOptOut": true,
                    "canonicalPurposeCode": "behavioral_advertising",
                    "code": "behavioral_advertising",
                    "description": "Creation and activation of advertisements based on a profile informed by the collection and analysis of behavioral and personal characteristics; we may set cookies or other trackers for this purpose.",
                    "legalBasisCode": "consent_optin",
                    "legalBasisDescription": "Data subject has affirmatively and unambiguously consented to the processing for one or more specific purposes",
                    "legalBasisName": "Consent - Opt In",
                    "name": "Behavioral Advertising",
                    "requiresDisplay": true,
                    "requiresOptIn": true,
                    "requiresPrivacyPolicy": true
                ],
                [
                    "allowsOptOut": true,
                    "canonicalPurposeCode": "email_mktg",
                    "code": "email_marketing",
                    "description": "Marketing of our products/services to customers by email.",
                    "legalBasisCode": "consent_optin",
                    "legalBasisDescription": "Data subject has affirmatively and unambiguously consented to the processing for one or more specific purposes",
                    "legalBasisName": "Consent - Opt In",
                    "name": "Email Marketing",
                    "requiresDisplay": true,
                    "requiresOptIn": true,
                    "requiresPrivacyPolicy": true
                ],
                [
                    "allowsOptOut": true,
                    "canonicalPurposeCode": "analytics",
                    "code": "tcf.purpose_1",
                    "description": "Cookies, device identifiers, or other information can be stored or accessed on your device for the purposes presented to you.",
                    "legalBasisCode": "consent_optin",
                    "legalBasisDescription": "Data subject has affirmatively and unambiguously consented to the processing for one or more specific purposes",
                    "legalBasisName": "Consent - Opt In",
                    "name": "Store and/or access information on a device",
                    "requiresDisplay": true,
                    "requiresOptIn": true,
                    "requiresPrivacyPolicy": true,
                    "tcfID": "1",
                    "tcfType": "purpose"
                ],
                [
                    "allowsOptOut": true,
                    "canonicalPurposeCode": "analytics",
                    "code": "somepurpose_key",
                    "description": "Description",
                    "legalBasisCode": "consent_optin",
                    "legalBasisDescription": "Data subject has affirmatively and unambiguously consented to the processing for one or more specific purposes",
                    "legalBasisName": "Consent - Opt In",
                    "name": "Some Purpose",
                    "requiresDisplay": true,
                    "requiresOptIn": true,
                    "requiresPrivacyPolicy": true
                ]
            ],
            "regulations": [
                "gdpreu",
                "eprivacy"
            ],
            "rights": [
                [
                    "code": "gdpr_access",
                    "description": "Right to be provided with a copy of personal data (and certain other information) being processed",
                    "name": "Right of Access (GDPR)"
                ],
                [
                    "code": "gdpr_rectification",
                    "description": "Right to have inaccurate personal data rectified or, in certain cases, completed",
                    "name": "Right to Rectification (GDPR)"
                ],
                [
                    "code": "gdpr_delete",
                    "description": "Right to have personal data erased",
                    "name": "Right to Erasure (GDPR)"
                ],
                [
                    "code": "gdpr_restrictprocessing",
                    "description": "Right to limit the way a controller uses personal data",
                    "name": "Right to Restrict Processing (GDPR)"
                ],
                [
                    "code": "gdpr_portability",
                    "description": "Right to obtain and request transfer of personal data in a structured, commonly used, and machine-readable format",
                    "name": "Right to Data Portability (GDPR)"
                ],
                [
                    "code": "gdpr_object",
                    "description": "Right to stop the processing of personal data, including an absolute right where the use is direct marketing",
                    "name": "Right to Object (GDPR)"
                ]
            ],
            "services": [
                "lanyard": "https://global.ketchcdn.com/transom/route/switchbit/lanyard/transcenda/lanyard.js",
                "shoreline": "https://global.ketchcdn.com/web/v2/"
            ],
            "termsOfService": [:],
            "theme": [
                "bannerBackgroundColor": "#01090E",
                "bannerButtonColor": "#ffffff",
                "bannerContentColor": "#ffffff",
                "bannerPosition": 1,
                "buttonBorderRadius": 5,
                "code": "default",
                "description": "Ketch default theme",
                "formButtonColor": "#071a24",
                "formContentColor": "#071a24",
                "formHeaderBackgroundColor": "#071a24",
                "modalButtonColor": "#071a24",
                "modalContentColor": "#071a24",
                "modalHeaderBackgroundColor": "#f6f6f6",
                "modalPosition": 1,
                "name": "Default"
            ],
            "vendors": [
                [
                    "cookieMaxAgeSeconds": 34164000,
                    "features": [
                        [
                            "legalBasis": "Disclosure",
                            "name": "Receive and use automatically-sent device characteristics for identification"
                        ]
                    ],
                    "id": "1000",
                    "name": "NETILUM (AFFILAE)",
                    "policyUrl": "https://affilae.com/en/privacy-cookie-policy",
                    "purposes": [
                        [
                            "legalBasis": "Consent - Opt In",
                            "name": "Store and/or access information on a device"
                        ],
                        [
                            "legalBasis": "Consent - Opt In",
                            "name": "Measure ad performance"
                        ],
                        [
                            "legalBasis": "Consent - Opt In",
                            "name": "Measure content performance"
                        ]
                    ],
                    "specialFeatures": [
                        [
                            "legalBasis": "Consent - Opt In",
                            "name": "Actively scan device characteristics for identification"
                        ]
                    ],
                    "usesCookies": true
                ],
                [
                    "features": [
                        [
                            "legalBasis": "Disclosure",
                            "name": "Match and combine offline data sources"
                        ]
                    ],
                    "id": "1001",
                    "name": "wetter.com GmbH",
                    "policyUrl": "https://www.wetter.com/internal/news/datenschutzhinweise_aid_607698849b8ecf79e21584fa.html",
                    "purposes": [
                        [
                            "legalBasis": "Consent - Opt In",
                            "name": "Store and/or access information on a device"
                        ],
                        [
                            "legalBasis": "Consent - Opt In",
                            "name": "Select basic ads"
                        ],
                        [
                            "legalBasis": "Consent - Opt In",
                            "name": "Create a personalised ads profile"
                        ],
                        [
                            "legalBasis": "Consent - Opt In",
                            "name": "Select personalised ads"
                        ],
                        [
                            "legalBasis": "Consent - Opt In",
                            "name": "Create a personalised content profile"
                        ],
                        [
                            "legalBasis": "Consent - Opt In",
                            "name": "Select personalised content"
                        ],
                        [
                            "legalBasis": "Consent - Opt In",
                            "name": "Measure ad performance"
                        ],
                        [
                            "legalBasis": "Consent - Opt In",
                            "name": "Measure content performance"
                        ],
                        [
                            "legalBasis": "Consent - Opt In",
                            "name": "Apply market research to generate audience insights"
                        ],
                        [
                            "legalBasis": "Consent - Opt In",
                            "name": "Develop and improve products"
                        ]
                    ],
                    "specialFeatures": [
                        [
                            "legalBasis": "Consent - Opt In",
                            "name": "Use precise geolocation data"
                        ]
                    ],
                    "usesCookies": true,
                    "usesNonCookieAccess": true
                ],
                [
                    "cookieMaxAgeSeconds": 63072000,
                    "features": [
                        [
                            "legalBasis": "Disclosure",
                            "name": "Link different devices"
                        ]
                    ],
                    "id": "1002",
                    "name": "Extreme Reach, Inc",
                    "policyUrl": "https://extremereach.com/privacy-policies/",
                    "purposes": [
                        [
                            "legalBasis": "Consent - Opt In",
                            "name": "Store and/or access information on a device"
                        ],
                        [
                            "legalBasis": "Consent - Opt In",
                            "name": "Select basic ads"
                        ],
                        [
                            "legalBasis": "Consent - Opt In",
                            "name": "Measure ad performance"
                        ],
                        [
                            "legalBasis": "Consent - Opt In",
                            "name": "Develop and improve products"
                        ]
                    ],
                    "usesCookies": true
                ],
                [
                    "id": "1003",
                    "name": "Mobility-Ads GmbH",
                    "policyUrl": "https://mobility-ads.de/datenschutz/",
                    "purposes": [
                        [
                            "legalBasis": "Consent - Opt In",
                            "name": "Store and/or access information on a device"
                        ],
                        [
                            "legalBasis": "Legitimate Interest - Objectable",
                            "name": "Measure ad performance"
                        ]
                    ],
                    "specialPurposes": [
                        [
                            "legalBasis": "Legitimate Interest - Non-Objectable",
                            "name": "Ensure security, prevent fraud, and debug"
                        ],
                        [
                            "legalBasis": "Legitimate Interest - Non-Objectable",
                            "name": "Technically deliver ads or content"
                        ]
                    ]
                ],
                [
                    "cookieMaxAgeSeconds": 31536000,
                    "features": [
                        [
                            "legalBasis": "Disclosure",
                            "name": "Link different devices"
                        ],
                        [
                            "legalBasis": "Disclosure",
                            "name": "Receive and use automatically-sent device characteristics for identification"
                        ]
                    ],
                    "id": "1004",
                    "name": "VUUKLE DMCC",
                    "policyUrl": "https://docs.vuukle.com/privacy-and-policy/",
                    "purposes": [
                        [
                            "legalBasis": "Consent - Opt In",
                            "name": "Store and/or access information on a device"
                        ],
                        [
                            "legalBasis": "Legitimate Interest - Objectable",
                            "name": "Select basic ads"
                        ],
                        [
                            "legalBasis": "Legitimate Interest - Objectable",
                            "name": "Select personalised ads"
                        ],
                        [
                            "legalBasis": "Legitimate Interest - Objectable",
                            "name": "Create a personalised content profile"
                        ],
                        [
                            "legalBasis": "Legitimate Interest - Objectable",
                            "name": "Select personalised content"
                        ],
                        [
                            "legalBasis": "Legitimate Interest - Objectable",
                            "name": "Measure ad performance"
                        ],
                        [
                            "legalBasis": "Legitimate Interest - Objectable",
                            "name": "Measure content performance"
                        ],
                        [
                            "legalBasis": "Legitimate Interest - Objectable",
                            "name": "Apply market research to generate audience insights"
                        ],
                        [
                            "legalBasis": "Legitimate Interest - Objectable",
                            "name": "Develop and improve products"
                        ]
                    ],
                    "specialFeatures": [
                        [
                            "legalBasis": "Consent - Opt In",
                            "name": "Use precise geolocation data"
                        ],
                        [
                            "legalBasis": "Consent - Opt In",
                            "name": "Actively scan device characteristics for identification"
                        ]
                    ],
                    "specialPurposes": [
                        [
                            "legalBasis": "Legitimate Interest - Non-Objectable",
                            "name": "Ensure security, prevent fraud, and debug"
                        ],
                        [
                            "legalBasis": "Legitimate Interest - Non-Objectable",
                            "name": "Technically deliver ads or content"
                        ]
                    ],
                    "usesCookies": true,
                    "usesNonCookieAccess": true
                ]
            ]
        ]
    }
}
