//
//  Configuration.swift
//  Ketch
//
//  Created by Aleksey Bodnya on 3/25/20.
//  Copyright © 2020 Switchbit. All rights reserved.
//

import UIKit

public struct Configuration: Codable {

    public struct PolicyScope: Codable {

        public var defaultScopeCode: String?
        public var code: String?
    }

    public var version: Int?
    public var language: String?
    public var organization: Organization?
    public var application: Application?
    public var environments: [Environment]?
    public var policyScope: PolicyScope?
    public var identities: [String: Identity]?
    public var environment: Environment?
    public var deployment: Deployment?
    public var privacyPolicy: Policy?
    public var termsOfService: Policy?
    public var rights: [Right]?
    public var regulations: [String]?
    public var purposes: [Purpose]?
    public var services: Services?
    public var options: Options?

    enum CodingKeys: String, CodingKey {
        case version = "v"
        case language
        case organization
        case application = "app"
        case environments
        case policyScope
        case identities
        case environment
        case deployment
        case privacyPolicy
        case termsOfService
        case rights
        case regulations
        case purposes
        case services
        case options
    }
}
