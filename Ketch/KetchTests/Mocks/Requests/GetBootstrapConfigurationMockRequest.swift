//
//  GetBootstrapConfigurationMockRequest.swift
//  KetchTests
//
//  Created by Aleksey Bodnya on 3/26/20.
//  Copyright © 2020 Switchbit. All rights reserved.
//

import UIKit

class GetBootstrapConfigurationMockRequest: BaseMockRequest {

    override var json: String {
        return #"""
        {
          "v": 1,
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
              "pattern": "Ly9zdWJsaW1lZGFpbHkuY29t",
              "hash": "4290636013626569096"
            },
            {
              "code": "staging",
              "pattern": "Ly9zdGFnZS5zdWJsaW1lZGFpbHkuY29t",
              "hash": "5372302035981843260"
            }
          ],
          "policyScope": {
            "defaultScopeCode": "gdpr",
            "scopes": {
              "AT": "gdpr",
              "BE": "gdpr",
              "BG": "gdpr",
              "CY": "gdpr",
              "CZ": "gdpr",
              "DE": "gdpr",
              "DK": "gdpr",
              "EE": "gdpr",
              "ES": "gdpr",
              "FI": "gdpr",
              "FR": "gdpr",
              "GB": "gdpr",
              "GF": "gdpr",
              "GP": "gdpr",
              "GR": "gdpr",
              "HR": "gdpr",
              "HU": "gdpr",
              "IE": "gdpr",
              "IS": "gdpr",
              "IT": "gdpr",
              "LI": "gdpr",
              "LT": "gdpr",
              "LU": "gdpr",
              "LV": "gdpr",
              "MQ": "gdpr",
              "MT": "gdpr",
              "NL": "gdpr",
              "NO": "gdpr",
              "PL": "gdpr",
              "PT": "gdpr",
              "RE": "gdpr",
              "RO": "gdpr",
              "SE": "gdpr",
              "SI": "gdpr",
              "SK": "gdpr",
              "US-AK": "us_standard",
              "US-AL": "us_standard",
              "US-AR": "us_standard",
              "US-AZ": "us_standard",
              "US-CA": "ccpa",
              "US-CO": "us_standard",
              "US-CT": "us_standard",
              "US-DC": "us_standard",
              "US-DE": "us_standard",
              "US-FL": "us_standard",
              "US-GA": "us_standard",
              "US-HI": "us_standard",
              "US-IA": "us_standard",
              "US-ID": "us_standard",
              "US-IL": "us_standard",
              "US-IN": "us_standard",
              "US-KS": "us_standard",
              "US-KY": "us_standard",
              "US-LA": "us_standard",
              "US-MA": "us_standard",
              "US-MD": "us_standard",
              "US-ME": "us_standard",
              "US-MI": "us_standard",
              "US-MN": "us_standard",
              "US-MO": "us_standard",
              "US-MS": "us_standard",
              "US-MT": "us_standard",
              "US-NC": "us_standard",
              "US-ND": "us_standard",
              "US-NE": "us_standard",
              "US-NH": "us_standard",
              "US-NJ": "us_standard",
              "US-NM": "us_standard",
              "US-NV": "us_standard",
              "US-NY": "us_standard",
              "US-OH": "us_standard",
              "US-OK": "us_standard",
              "US-OR": "us_standard",
              "US-PA": "us_standard",
              "US-RI": "us_standard",
              "US-SC": "us_standard",
              "US-SD": "us_standard",
              "US-TN": "us_standard",
              "US-TX": "us_standard",
              "US-UT": "us_standard",
              "US-VA": "us_standard",
              "US-VT": "us_standard",
              "US-WA": "us_standard",
              "US-WI": "us_standard",
              "US-WV": "us_standard",
              "US-WY": "us_standard",
              "YT": "gdpr"
            }
          },
          "identities": {
            "habu_cookie": {
              "type": "window",
              "variable": "window.__Habu.huid"
            }
          },
          "scripts": [
            "https://cdn.b10s.io/transom/route/switchbit/semaphore/habu/semaphore.js"
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
