//
//  GetConsentStatusResponse.swift
//  Ketch
//
//  Created by Aleksey Bodnya on 3/25/20.
//  Copyright © 2020 Switchbit. All rights reserved.
//

import UIKit

struct GetConsentStatusResponse: Codable {

    struct Purpose: Codable {
        var allowed: String
    }

    var purposes: [String: Purpose]?
}

class GetConsentStatusResponseHandler: ResponseHandler<GetConsentStatusResponse, [String: ConsentStatus]> {

    init(purposes: [String: String]) {
        self.purposes = purposes
        super.init()
    }

    let purposes: [String: String]

    override func handle(response: GetConsentStatusResponse, onSuccess: @escaping SuccessHandler, onError: @escaping ErrorHandler) {
        var result = [String: ConsentStatus]()
        for (code, responseAllowed) in (response.purposes ?? [:]) {
            guard let legalBasisCode = purposes[code] else {
                continue
            }
            let consentStatus = ConsentStatus(allowed: responseAllowed.allowed == "true", legalBasisCode: legalBasisCode)
            result[code] = consentStatus
        }
        onSuccess(result)
    }
}
