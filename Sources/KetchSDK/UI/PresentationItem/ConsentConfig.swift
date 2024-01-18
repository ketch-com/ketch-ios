//
//  ConsentConfig.swift
//  iOS Ketch Pref Center using SwiftUI
//

import Foundation
import WebKit

struct WebConfig {
    let orgCode: String
    let propertyName: String
    let advertisingIdentifier: UUID
    let htmlFileName: String
    var params = [String: String]()
    var configWebApp: WKWebView?

    init(
        orgCode: String,
        propertyName: String,
        advertisingIdentifier: UUID,
        htmlFileName: String = "index"
    ) {
        self.propertyName = propertyName
        self.orgCode = orgCode
        self.advertisingIdentifier = advertisingIdentifier
        self.htmlFileName = htmlFileName
    }

    static func configure(
        orgCode: String,
        propertyName: String,
        advertisingIdentifier: UUID,
        htmlFileName: String = "index"
    ) -> Self {
        var config = WebConfig(
            orgCode: orgCode,
            propertyName: propertyName,
            advertisingIdentifier: advertisingIdentifier,
            htmlFileName: htmlFileName
        )

        DispatchQueue.main.async {
            config.configWebApp = config.preferencesWebView(with: WebHandler(onEvent: { _, _ in }))
        }

        return config
    }

    private var fileUrl: URL? {
        let url = Bundle.ketchUIfiles!.url(forResource: htmlFileName, withExtension: "html")!
        var urlComponents = URLComponents(string: url.absoluteString)
        urlComponents?.queryItems = queryItems

        return urlComponents?.url
    }

    private var queryItems: [URLQueryItem] {
        var defaultQuery = [
            URLQueryItem(name: "propertyName", value: propertyName),
            URLQueryItem(name: "orgCode", value: orgCode),
            URLQueryItem(name: "idfa", value: advertisingIdentifier.uuidString),
            URLQueryItem(name: "ketch_lang", value: "en")
        ]
        
        params.forEach {
            defaultQuery.append(URLQueryItem(name: $0, value: $1))
        }
        
        return defaultQuery
    }

    func preferencesWebView(with webHandler: WebHandler) -> WKWebView {
        let preferences = WKWebpagePreferences()
        preferences.allowsContentJavaScript = true

        let configuration = WKWebViewConfiguration()
        configuration.defaultWebpagePreferences = preferences

        WebHandler.Event.allCases.forEach { event in
            configuration.userContentController.add(webHandler, name: event.rawValue)
        }

        let webView = WKWebView(frame: .zero, configuration: configuration)

        if let fileUrl = fileUrl {
            webView.load(URLRequest(url: fileUrl))
        }

        return webView
    }
}

extension WebConfig: Identifiable {
    var id: String {
        orgCode + propertyName + advertisingIdentifier.uuidString
    }
}

//    “language”:“en”,
//    “organization”:{
//       “code”:“bluebird”
//    },
//    “environments”:[
//       {
//          “code”:“production”,
//          “pattern”:“Lio=“,
//          “hash”:“10818724372400718716"
//       }
//    ],
//    “identities”:{
//       “aaid”:{
//          “type”:“queryString”,
//          “variable”:“aaid”,
//          “format”:“string”,
//          “priority”:2
//       },
//       “idfa”:{
//          “type”:“queryString”,
//          “variable”:“idfa”,
//          “format”:“string”,
//          “priority”:2
//       },
//       “swb_mobile”:{
//          “type”:“managedCookie”,
//          “variable”:“_swb”
//       }
//    },
//    “environment”:{
//       “code”:“production”,
//       “pattern”:“Lio=“,
//       “hash”:“10818724372400718716"
//    },
//    “deployment”:{
//       “code”:“bluebird”,
//       “version”:1705496895
//    },
//    “privacyPolicy”:{
//       “code”:“df468006-5063-4249-b07f-aa23d3cd6f2b”,
//       “version”:1704819714,
//       “url”:“https://ketch.com”
//    },
//    “termsOfService”:{
//       “code”:“0f696f06-f1d1-4932-960e-81f4663aa908”,
//       “version”:1705477775
//    },
//    “regulations”:[
//       “default”
//    ],
//    “experiences”:{
//       “consent”:{
//          “experienceDefault”:1
//       },
//       “preference”:{
//          “code”:“preference”
//       }
//    },
//    “purposes”:[
//       {
//          “code”:“analytics”,
//          “name”:“Analytics”,
//          “description”:“Collection and analysis of personal data to further our business goals; for example, analysis of behavior of website visitors, creation of target lists for marketing and sales, and measurement of advertising performance.“,
//          “legalBasisCode”:“disclosure”,
//          “requiresPrivacyPolicy”:true,
//          “requiresDisplay”:true,
//          “canonicalPurposeCode”:“analytics”,
//          “legalBasisName”:“Disclosure”,
//          “legalBasisDescription”:“Data subject has been provided with adequate disclosure regarding the processing”,
//          “dataSubjectTypeCodes”:[
//             “customer”
//          ],
//          “canonicalPurposeCodes”:[
//             “analytics”
//          ]
//       },
//       {
//          “code”:“behavioral_advertising”,
//          “name”:“Behavioral Advertising”,
//          “description”:“Creation and activation of advertisements based on a profile informed by the collection and analysis of behavioral and personal characteristics; we may set cookies or other trackers for this purpose.“,
//          “legalBasisCode”:“disclosure”,
//          “requiresPrivacyPolicy”:true,
//          “requiresDisplay”:true,
//          “canonicalPurposeCode”:“behavioral_advertising”,
//          “legalBasisName”:“Disclosure”,
//          “legalBasisDescription”:“Data subject has been provided with adequate disclosure regarding the processing”,
//          “dataSubjectTypeCodes”:[
//             “customer”
//          ],
//          “canonicalPurposeCodes”:[
//             “behavioral_advertising”
//          ]
//       },
//       {
//          “code”:“essential_services”,
//          “name”:“Essential Services”,
//          “description”:“Collection and processing of personal data to enable functionality that is essential to providing our services, including security activities, debugging, authentication, and fraud prevention, as well as contacting you with information related to products/services you have used or purchased; we may set essential cookies or other trackers for these purposes.“,
//          “legalBasisCode”:“disclosure”,
//          “requiresPrivacyPolicy”:true,
//          “requiresDisplay”:true,
//          “canonicalPurposeCode”:“essential_services”,
//          “legalBasisName”:“Disclosure”,
//          “legalBasisDescription”:“Data subject has been provided with adequate disclosure regarding the processing”,
//          “dataSubjectTypeCodes”:[
//             “customer”
//          ],
//          “canonicalPurposeCodes”:[
//             “essential_services”
//          ]
//       }
//    ],
//    “services”:{
//       “lanyard”:“https://cdn.uat.ketchjs.com/lanyard/v2/lanyard.js”,
//       “scriptHost”:“https://cdn.uat.ketchjs.com”,
//       “shoreline”:“https://dev.ketchcdn.com/web/v3”,
//       “telemetry”:“https://dev.ketchcdn.com/web/v2/log”
//    },
//    “options”:{
//       “appDivs”:“hubspot-messages-iframe-container”,
//       “beaconPercentage”:“1"
//    },
//    “property”:{
//       “code”:“mobile”,
//       “name”:“mobile”,
//       “platform”:“IOS”
//    },
//    “jurisdiction”:{
//       “code”:“default”,
//       “defaultScopeCode”:“default”,
//       “defaultJurisdictionCode”:“default”
//    },
//    “canonicalPurposes”:{
//       “analytics”:{
//          “code”:“analytics”,
//          “name”:“Analytics”,
//          “purposeCodes”:[
//             “analytics”
//          ]
//       },
//       “behavioral_advertising”:{
//          “code”:“behavioral_advertising”,
//          “name”:“Behavioral Advertising”,
//          “purposeCodes”:[
//             “behavioral_advertising”
//          ]
//       },
//       “essential_services”:{
//          “code”:“essential_services”,
//          “name”:“Essential Services”,
//          “purposeCodes”:[
//             “essential_services”
//          ]
//       }
//    },
//    “dataSubjectTypes”:[
//       {
//          “code”:“customer”,
//          “name”:“Customer”
//       }
//    ],
//    “plugins”:{
//       “lanyard”:{
//       },
//       “tcf”:{
//          “jurisdictions”:[
//             “gdpr”,
//             “colopa”
//          ],
//          “purposeMappings”:[
//             {
//                “pluginPurposeID”:“purpose_1",
//                “purposes”:[
//                   “analytics”
//                ]
//             }
//          ]
//       }
//    }


