//
//  BaseMockRequest.swift
//  KetchTests
//
//  Created by Aleksey Bodnya on 3/26/20.
//  Copyright © 2020 Switchbit. All rights reserved.
//

import UIKit

@testable import Ketch

class BaseMockRequest: NetworkRequest {

    var json: String {
        return ""
    }

    override func send() {
        onSuccess?(json.data(using: .utf8)!)
    }
}
