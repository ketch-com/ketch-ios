//
//  InvokeRightsRequest.swift
//  Ketch
//
//  Created by Aleksey Bodnya on 3/27/20.
//  Copyright © 2020 Switchbit. All rights reserved.
//

import UIKit

class InvokeRightsRequest: BaseRequest {

    init(session: URLSession, gangplankHost: URL, organizationCode: String, applicationCode: String, environmentCode: String, policyScopeCode: String, identities: [String: String], rights: [String], userData: UserData) {
        self.gangplankHost = gangplankHost
        self.organizationCode = organizationCode
        self.applicationCode = applicationCode
        self.environmentCode = environmentCode
        self.policyScopeCode = policyScopeCode
        self.identities = identities
        self.rights = rights
        self.userData = userData
        super.init(session: session)
    }

    let gangplankHost: URL
    let organizationCode: String
    let applicationCode: String
    let environmentCode: String
    let policyScopeCode: String
    let identities: [String: String]
    let rights: [String]
    let userData: UserData

    override func createRequest() -> URLRequest {
        var url = gangplankHost
        url.appendPathComponent("rights")
        url.appendPathComponent(organizationCode.urlEncoded)
        url.appendPathComponent("invoke")

        let body: [String: Any] = [
            "applicationCode": applicationCode,
            "applicationEnvironmentCode": environmentCode,
            "identities": identities.map { (identitySpaceCode, identityValue) -> String in
                return "srn:::::\(organizationCode):id/\(identitySpaceCode)/\(identityValue)"
            },
            "policyScopeCode": policyScopeCode,
            "rightsEmail": userData.email,
            "rightCodes": rights
        ]
        return request(url, method: .post, body: body)
    }
}
