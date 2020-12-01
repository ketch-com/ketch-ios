//
//  BootstrapConfiguration.swift
//  Ketch
//
//  Created by Aleksey Bodnya on 3/25/20.
//  Copyright © 2020 Switchbit. All rights reserved.
//

import Foundation

public struct BootstrapConfiguration: Codable {

    public struct PolicyScope: Codable {

        public var defaultScopeCode: String?
        public var scopes: [String: String]?
    }

    public var version: Int?
    public var organization: Organization?
    public var application: Application?
    public var environments: [Environment]?
    public var policyScope: PolicyScope?
    public var identities: [String: Identity]?
    public var scripts: [String]?
    public var services: Services?
    public var options: Options?

    enum CodingKeys: String, CodingKey {
        case version = "v"
        case organization
        case application = "app"
        case environments
        case policyScope
        case identities
        case scripts
        case services
        case options
    }
}
