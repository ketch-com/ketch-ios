//
//  GetFullConfigurationMockRequest.swift
//  KetchTests
//
//  Created by Aleksey Bodnya on 3/26/20.
//  Copyright © 2020 Switchbit. All rights reserved.
//

import UIKit

class GetFullConfigurationMockRequest: BaseMockRequest {

    override var json: String {
        return #"""
        {
          "v": 1,
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
    }
}
