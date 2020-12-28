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
        language = response.language
        organization = Organization(code: response.organization.code, name: response.organization.name)
        application = Application(code: response.app.code, name: response.app.name, platform: response.app.platform)
        policyScope = PolicyScope(defaultScopeCode: response.policyScope.defaultScopeCode, code: response.policyScope.code)
        identities = response.identities.mapValues { value in
            return Identity(type: value.type, variable: value.variable)
        }
        environments = response.environments.map { environment in Environment(code: environment.code, pattern: environment.pattern, hash: environment.hash) }
        environment = Environment(code: response.environment.code, pattern: response.environment.pattern, hash: response.environment.hash)
        deployment = Deployment(code: response.deployment.code, version: Int(response.deployment.version))
        privacyPolicy = Policy(code: response.privacyPolicy.code, version: Int(response.privacyPolicy.version), url: response.privacyPolicy.url)
        termsOfService = Policy(code: response.termsOfService.code, version: Int(response.termsOfService.version), url: response.termsOfService.url)
        rights = response.rights.map { right in Right(code: right.code, name: right.name, description: right.description_p)}
        regulations = response.regulations
        purposes = response.purposes.map { purpose in Purpose(code: purpose.code, name: purpose.name, description: purpose.description_p, legalBasisCode: purpose.legalBasisCode, requiresPrivacyPolicy: purpose.requiresPrivacyPolicy, requiresOptIn: purpose.requiresOptIn, allowsOptOut: purpose.allowsOptOut)}
        services = Services(astrolabe: response.services[ServicesKeys.astrolabe.rawValue],
                            gangplank: response.services[ServicesKeys.gangplank.rawValue],
                            halyard: response.services[ServicesKeys.halyard.rawValue],
                            supercargo: response.services[ServicesKeys.supercargo.rawValue],
                            wheelhouse: response.services[ServicesKeys.wheelhouse.rawValue])
        options = Options(localStorage: Int(response.options[OptionsKeys.localStorage.rawValue] ?? -1),
                          migration: Int(response.options[OptionsKeys.migration.rawValue] ?? -1))
    }
    
}
