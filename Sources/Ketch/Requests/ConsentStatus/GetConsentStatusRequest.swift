//
//  GetConsentStatusRequest.swift
//  Ketch
//
//  Created by Aleksey Bodnya on 3/27/20.
//  Copyright © 2020 Switchbit. All rights reserved.
//

import UIKit

class GetConsentStatusRequest: BaseRequest {

    init(session: URLSession, wheelhouseHost: URL, organizationCode: String, applicationCode: String, environmentCode: String, identities: [String: String], purposes: [String: String]) {
        self.wheelhouseHost = wheelhouseHost
        self.organizationCode = organizationCode
        self.applicationCode = applicationCode
        self.environmentCode = environmentCode
        self.identities = identities
        self.purposes = purposes
        super.init(session: session)
    }

    let wheelhouseHost: URL
    let organizationCode: String
    let applicationCode: String
    let environmentCode: String
    let identities: [String: String]
    let purposes: [String: String]

    override func createRequest() -> URLRequest {
        var url = wheelhouseHost
        url.appendPathComponent("consent")
        url.appendPathComponent(organizationCode.urlEncoded)
        url.appendPathComponent("get")

        let body: [String: Any] = [
            "applicationCode": applicationCode,
            "applicationEnvironmentCode": environmentCode,
            "identities": identities.map { (identitySpaceCode, identityValue) -> String in
                return "srn:::::\(organizationCode):id/\(identitySpaceCode)/\(identityValue)"
            },
            "purposes": purposes.mapValues { (legalBasisCode) -> [String: String] in
                return ["legalBasisCode": legalBasisCode]
            }
        ]
        return request(url, method: .post, body: body)
    }
}
