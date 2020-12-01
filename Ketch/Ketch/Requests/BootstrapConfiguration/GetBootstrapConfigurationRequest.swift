//
//  GetBootstrapConfigurationRequest.swift
//  Ketch
//
//  Created by Aleksey Bodnya on 3/25/20.
//  Copyright © 2020 Switchbit. All rights reserved.
//

import UIKit

/// The request for retrieveing `BootstrapConfiguration`
class GetBootstrapConfigurationRequest: BaseRequest {

    // MARK: Initializer

    /// Initializer
    /// - Parameter session: URLSession used to send network requests
    /// - Parameter organizationCode: The code of organization
    /// - Parameter applicationCode: The code of application
    init(session: URLSession, organizationCode: String, applicationCode: String) {
        self.organizationCode = organizationCode
        self.applicationCode = applicationCode
        super.init(session: session)
    }

    // MARK: Properties

    /// The code of organization
    let organizationCode: String

    /// The code of application
    let applicationCode: String

    // MARK: Creating Request

    /// Creates request
    /// - Returns: URLRequest to get `BootstrapConfiguration`
    override func createRequest() -> URLRequest {
        let url = URL(string: "https://cdn.b10s.io/supercargo/config/1/\(organizationCode)/\(applicationCode)/boot.json")!
        return request(url, method: .get)
    }
}
