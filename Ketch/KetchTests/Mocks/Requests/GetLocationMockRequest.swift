//
//  GetLocationMockRequest.swift
//  KetchTests
//
//  Created by Aleksey Bodnya on 3/27/20.
//  Copyright © 2020 Switchbit. All rights reserved.
//

import UIKit

class GetLocationMockRequest: BaseMockRequest {

    override var json: String {
        return #"""
        {
          "location" : {
            "zip" : "02987",
            "countryName" : "Ukraine",
            "regionCode" : "30",
            "longitude" : 26.296680000000001,
            "hostname" : "112.186.131.8",
            "countryCode" : "UA",
            "latitude" : 62.571329999999998,
            "location" : {
              "countryFlagEmojiUnicode" : "U+1F1FA U+1F1E6",
              "callingCode" : "380",
              "capital" : "Kyiv",
              "countryFlagEmoji" : "🇺🇦",
              "geonameId" : 810236,
              "countryFlag" : "http:\/\/assets.ipapi.com\/flags\/ua.svg",
              "languages" : [
                {
                  "name" : "Ukrainian",
                  "native" : "Українська",
                  "code" : "uk"
                }
              ]
            },
            "ip" : "112.186.131.8",
            "continentCode" : "EU",
            "city" : "Kyiv",
            "continentName" : "Europe",
            "regionName" : "Kyiv City"
          }
        }
        """#
    }
}
