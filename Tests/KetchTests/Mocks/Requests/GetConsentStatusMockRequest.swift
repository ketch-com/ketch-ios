//
//  GetConsentStatusMockRequest.swift
//  KetchTests
//
//  Created by Aleksey Bodnya on 3/27/20.
//  Copyright © 2020 Switchbit. All rights reserved.
//

import UIKit

class GetConsentStatusMockRequest: BaseMockRequest {

    override var json: String {
        return #"""
        {
          "purposes": {
            "{purpose.1}": {
              "allowed": "true"
            },
            "{purpose.2}": {
              "allowed": "false"
            },
            "{purpose.3}": {
              "allowed": "true"
            }
          }
        }
        """#
    }
}
