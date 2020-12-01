//
//  GetLocationRequest.swift
//  Ketch
//
//  Created by Aleksey Bodnya on 3/27/20.
//  Copyright © 2020 Switchbit. All rights reserved.
//

import UIKit

class GetLocationRequest: BaseRequest {

    init(session: URLSession, astrolabeHost: URL) {
        self.astrolabeHost = astrolabeHost
        super.init(session: session)
    }

    let astrolabeHost: URL

    override func createRequest() -> URLRequest {
        return request(astrolabeHost, method: .get)
    }
}
