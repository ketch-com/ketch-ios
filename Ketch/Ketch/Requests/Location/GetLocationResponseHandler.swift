//
//  GetLocationResponse.swift
//  Ketch
//
//  Created by Aleksey Bodnya on 3/25/20.
//  Copyright © 2020 Switchbit. All rights reserved.
//

import UIKit

struct GetLocationResponse: Codable {

    var location: Location
}

class GetLocationResponseHandler: ResponseHandler<GetLocationResponse, Location> {

    override func handle(response: GetLocationResponse, onSuccess: @escaping SuccessHandler, onError: @escaping ErrorHandler) {
        onSuccess(response.location)
    }
}

