//
//  GetFullConfigurationRequest.swift
//  Ketch
//
//  Created by Aleksey Bodnya on 3/25/20.
//  Copyright © 2020 Switchbit. All rights reserved.
//

import UIKit

class GetFullConfigurationRequest: BaseRequest {

    init(session: URLSession, supercargoHost: URL, organizationCode: String, applicationCode: String, environmentCode: String, environmentHash: String, policyScopeCode: String, languageCode: String) {
        self.supercargoHost = supercargoHost
        self.organizationCode = organizationCode
        self.applicationCode = applicationCode
        self.environmentCode = environmentCode
        self.environmentHash = environmentHash
        self.policyScopeCode = policyScopeCode
        self.languageCode = languageCode
        super.init(session: session)
    }

    let supercargoHost: URL
    let organizationCode: String
    let applicationCode: String
    let environmentCode: String
    let environmentHash: String
    let policyScopeCode: String
    let languageCode: String

    override func createRequest() -> URLRequest {
        var url = supercargoHost
        url.appendPathComponent(organizationCode.urlEncoded)
        url.appendPathComponent(applicationCode.urlEncoded)
        url.appendPathComponent(environmentCode.urlEncoded)
        url.appendPathComponent(environmentHash.urlEncoded)
        url.appendPathComponent(policyScopeCode.urlEncoded)
        url.appendPathComponent(languageCode.urlEncoded)
        url.appendPathComponent("config.json")
        return request(url, method: .get)
    }
}
