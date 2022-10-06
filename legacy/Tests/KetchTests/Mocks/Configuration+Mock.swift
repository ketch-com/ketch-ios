//
//  Configuration+Mock.swift
//  KetchTests
//
//  Created by Aleksey Bodnya on 4/3/20.
//  Copyright © 2020 Switchbit. All rights reserved.
//

import Foundation

@testable import Ketch

extension Configuration {

    static func mock() -> Configuration {
        let jsonString = #"""
        {
          "language": "en-US",
          "organization": {
            "code": "habu"
          },
          "app": {
            "code": "sublimedaily",
            "name": "Sublime Daily",
            "platform": "WEB"
          },
          "environments": [
            {
              "code": "production",
              "hash": "4290636013626569096"
            },
            {
              "code": "staging"
            }
          ],
          "policyScope": {
            "code": "ccpa",
            "defaultScopeCode": "gdpr"
          },
          "identities": {
            "habu_cookie": {
              "type": "window",
              "variable": "window.__Habu.huid"
            }
          },
          "environment": {
            "code": "production",
            "hash": "4290636013626569096"
          },
          "deployment": {
            "code": "habu_dep",
            "version": 1
          },
          "privacyPolicy": {
            "code": "habupp",
            "version": 1,
            "url": "https://habu.com/privacypolicy"
          },
          "termsOfService": {
            "code": "habutou",
            "version": 1,
            "url": "https://habu.com/tou"
          },
          "rights": [
            {
              "code": "portability",
              "name": "Portability",
              "description": "Right to have all data provided to you."
            },
            {
              "code": "rtbf",
              "name": "Data Deletion",
              "description": "Right to be forgotten."
            },
            {
              "code": "access",
              "name": "Access",
              "description": "Right to access data."
            }
          ],
          "regulations": [
            "ccpa"
          ],
          "purposes": [
            {
              "code": "identity_management",
              "name": "User ID Linking",
              "description": "Data can be used to bridge commonality of audience traits at a granular level.",
              "legalBasisCode": "disclosure",
              "requiresPrivacyPolicy": true
            },
            {
              "code": "targeted_advertising",
              "name": "Targeted Advertising",
              "description": "Data can be used to assist in the process of providing more contextually relevant advertising experiences across advertising modalities.",
              "legalBasisCode": "disclosure",
              "requiresPrivacyPolicy": true
            },
            {
              "code": "personalization_optimization",
              "name": "Site Personalization and User Experience Optimization",
              "description": "Data may be used to optimize the front-end user experience through the application of algorithms and models that can provide more relevant contextual elements to the end user.",
              "legalBasisCode": "disclosure",
              "requiresPrivacyPolicy": true
            },
            {
              "code": "segmentation",
              "name": "Segmentation and Cohort Analysis",
              "description": "At times, data may be grouped by common traits (inferred, observed, declared, etc.) into segment or cohort groupings. These groupings are designed to aggregate larger, disparate attributes into more relevant smaller collections.",
              "legalBasisCode": "disclosure",
              "requiresPrivacyPolicy": true
            },
            {
              "code": "modeling",
              "name": "Lookalike Modeling",
              "description": "Data may be used to derive expanding meaning and audience definition through the use of models that focus on finding additional context into typically variant audience groupings.",
              "legalBasisCode": "disclosure",
              "requiresPrivacyPolicy": true
            },
            {
              "code": "activation",
              "name": "Data Activation",
              "description": "In some instances, data may be used in additional systems that can extend the efficacy and usefulness of the data asset.",
              "legalBasisCode": "disclosure",
              "requiresPrivacyPolicy": true
            },
            {
              "code": "analytics_insights",
              "name": "Analytics & Insights",
              "description": "Data may be utilized in various ways to derive additional meaning and purpose. This can include the use of data in aggregate views or tactical detailed analysis, the use of data in algorithms and models, and the use of data for reporting and dashboards. ",
              "legalBasisCode": "disclosure",
              "requiresPrivacyPolicy": true
            },
            {
              "code": "data_sales",
              "name": "Data Sales",
              "description": "Data may be used for activities such as behavioral targeting.",
              "legalBasisCode": "consent_optout",
              "allowsOptOut": true,
              "requiresPrivacyPolicy": true
            }
          ],
          "services": {
            "astrolabe": "https://cdn.b10s.io/astrolabe/",
            "gangplank": "https://cdn.b10s.io/gangplank/",
            "halyard": "https://cdn.b10s.io/transom/route/switchbit/halyard/habu/bundle.min.js",
            "supercargo": "https://cdn.b10s.io/supercargo/config/1/",
            "wheelhouse": "https://cdn.b10s.io/wheelhouse/"
          },
          "options": {
            "localStorage": 1,
            "migration": 1
          }
        }
        """#

        let data = jsonString.data(using: .utf8)!
        let object = try! JSONDecoder().decode(Configuration.self, from: data)
        return object
    }
}

extension Configuration {

    var rawResponse: Mobile_GetConfigurationResponse {
        return .with {
            $0.language = language ?? ""
            $0.organization = .with {
                $0.code = organization?.code ?? ""
                $0.name = organization?.name ?? ""
            }
            $0.app = .with {
                $0.code = application?.code ?? ""
                $0.name = application?.name ?? ""
                $0.platform = application?.platform ?? ""
            }
            $0.policyScope = .with {
                $0.defaultScopeCode = policyScope?.defaultScopeCode ?? ""
                $0.code = policyScope?.code ?? ""
            }
            $0.identities = identities?.reduce(into: [String: Mobile_ConfigurationIdentity](), { (result, identity) in
                result[identity.key] = .with {
                    $0.type = identity.value.type ?? ""
                    $0.variable = identity.value.variable ?? ""
                }
            }) ?? [:]
            $0.environments = environments?.map({ environment in
                return .with {
                    $0.code = environment.code ?? ""
                    $0.pattern = environment.pattern ?? ""
                    $0.hash = environment.hash ?? ""
                }
            }) ?? []
            $0.environment = .with {
                $0.code = environment?.code ?? ""
                $0.pattern = environment?.pattern ?? ""
                $0.hash = environment?.hash ?? ""
            }
            $0.deployment = .with {
                $0.code = deployment?.code ?? ""
                $0.version = Int64(deployment?.version ?? 0)
            }
            $0.privacyPolicy = .with {
                $0.code = privacyPolicy?.code ?? ""
                $0.version = Int64(privacyPolicy?.version ?? 0)
                $0.url = privacyPolicy?.url ?? ""
            }
            $0.termsOfService = .with {
                $0.code = termsOfService?.code ?? ""
                $0.version = Int64(termsOfService?.version ?? 0)
                $0.url = termsOfService?.url ?? ""
            }
            $0.rights = rights?.map({ right in
                return .with {
                    $0.code = right.code ?? ""
                    $0.name = right.name ?? ""
                    $0.description_p = right.description ?? ""
                }
            }) ?? []
            $0.regulations = regulations ?? []
            $0.purposes = purposes?.map({ purpose in
                return .with {
                    $0.code = purpose.code ?? ""
                    $0.name = purpose.name ?? ""
                    $0.description_p = purpose.description ?? ""
                    $0.legalBasisCode = purpose.legalBasisCode ?? ""
                    $0.requiresPrivacyPolicy = purpose.requiresPrivacyPolicy ?? false
                    $0.requiresOptIn = purpose.requiresOptIn ?? false
                    $0.allowsOptOut = purpose.allowsOptOut ?? false
                }
            }) ?? []
            $0.services = {
                var servicesDict: [String: String] = [:]
                servicesDict[ServicesKeys.astrolabe.rawValue] = services?.astrolabe
                servicesDict[ServicesKeys.gangplank.rawValue] = services?.gangplank
                servicesDict[ServicesKeys.halyard.rawValue] = services?.halyard
                servicesDict[ServicesKeys.supercargo.rawValue] = services?.supercargo
                servicesDict[ServicesKeys.wheelhouse.rawValue] = services?.wheelhouse
                return servicesDict
            }()
            $0.options = {
                var optionsDict: [String: Int32] = [:]
                if let localStorage = options?.localStorage, localStorage != -1 {
                    optionsDict[OptionsKeys.localStorage.rawValue] = Int32(localStorage)
                }
                if let migration = options?.migration, migration != -1 {
                    optionsDict[OptionsKeys.migration.rawValue] = Int32(migration)
                }
                return optionsDict
            }()
        }
    }
}
