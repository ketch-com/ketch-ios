//
//  SetConsentStatusRequest.swift
//  Ketch
//
//  Created by Aleksey Bodnya on 3/27/20.
//  Copyright © 2020 Switchbit. All rights reserved.
//

import UIKit

class SetConsentStatusRequest: BaseRequest {

    init(session: URLSession, wheelhouseHost: URL, organizationCode: String, applicationCode: String, environmentCode: String, policyScopeCode: String, identities: [String: String], consents: [String: ConsentStatus], migrationOption: MigrationOption) {
        self.wheelhouseHost = wheelhouseHost
        self.organizationCode = organizationCode
        self.applicationCode = applicationCode
        self.environmentCode = environmentCode
        self.policyScopeCode = policyScopeCode
        self.identities = identities
        self.consents = consents
        self.migrationOption = migrationOption
        super.init(session: session)
    }

    let wheelhouseHost: URL
    let organizationCode: String
    let applicationCode: String
    let environmentCode: String
    let policyScopeCode: String
    let identities: [String: String]
    let consents: [String: ConsentStatus]
    let migrationOption: MigrationOption

    override func createRequest() -> URLRequest {
        var url = wheelhouseHost
        url.appendPathComponent("consent")
        url.appendPathComponent(organizationCode.urlEncoded)
        url.appendPathComponent("update")

        let body: [String: Any] = [
            "applicationCode": applicationCode,
            "applicationEnvironmentCode": environmentCode,
            "identities": identities.map { (identitySpaceCode, identityValue) -> String in
                return "srn:::::\(organizationCode):id/\(identitySpaceCode)/\(identityValue)"
            },
            "policyScopeCode": policyScopeCode,

            "purposes": consents.mapValues { (consent) -> [String: String] in
                return [
                    "legalBasisCode": consent.legalBasisCode ?? "",
                    "allowed": (consent.allowed ?? false) ? "true" : "false"
                ]
            },
            "migrationOption": migrationOption.rawValue
        ]
        return request(url, method: .post, body: body)
    }
}
