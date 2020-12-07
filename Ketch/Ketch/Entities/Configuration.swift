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
    
    init(response: Mobile_GetConfigurationResponse) {
        organization = Organization(code: response.organization.code)
        application = Application(code: response.app.code, name: response.app.name, platform: response.app.platform)
        environment = Environment(code: response.environment.code, pattern: response.environment.pattern, hash: response.environment.hash)
        //extend maping
    }
    
    func requestConfiguration() -> Mobile_GetConfigurationRequest {
        // remove hardCode, extend maping
        let options: Mobile_GetConfigurationRequest = .with {
            $0.organizationCode = self.organization?.code ?? ""
            $0.applicationCode = self.application?.code ?? ""
            $0.applicationEnvironmentCode = self.environment?.code ?? ""
            $0.countryCode = "US"
            $0.regionCode = "CA"
            $0.languageCode = "en"
        }
        
        return options
    }
}
