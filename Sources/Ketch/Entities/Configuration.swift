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

    public var version: Int?                    // TODO: Remove
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

extension Configuration {
    var raw: Mobile_GetConfigurationResponse {
        return .with {
            $0.language = language ?? ""
            $0.organization = .with {
                $0.code = organization?.code ?? ""
                $0.name = organization?.name ?? ""
            }
            $0.app = .with {
                $0.code = application?.code ?? ""
                $0.name = application?.name ?? ""
                $0.platform = application?.platform ?? ""
            }
            $0.policyScope = .with {
                $0.defaultScopeCode = policyScope?.defaultScopeCode ?? ""
                $0.code = policyScope?.code ?? ""
            }
            $0.identities = identities?.reduce(into: [String: Mobile_ConfigurationIdentity](), { (result, identity) in
                result[identity.key] = .with {
                    $0.type = identity.value.type ?? ""
                    $0.variable = identity.value.variable ?? ""
                }
            }) ?? [:]
            $0.environments = environments?.map({ environment in
                return .with {
                    $0.code = environment.code ?? ""
                    $0.pattern = environment.pattern ?? ""
                    $0.hash = environment.hash ?? ""
                }
            }) ?? []
            $0.environment = .with {
                $0.code = environment?.code ?? ""
                $0.pattern = environment?.pattern ?? ""
                $0.hash = environment?.hash ?? ""
            }
            $0.deployment = .with {
                $0.code = deployment?.code ?? ""
                $0.version = Int64(deployment?.version ?? 0)
            }
            $0.privacyPolicy = .with {
                $0.code = privacyPolicy?.code ?? ""
                $0.version = Int64(privacyPolicy?.version ?? 0)
                $0.url = privacyPolicy?.url ?? ""
            }
            $0.termsOfService = .with {
                $0.code = termsOfService?.code ?? ""
                $0.version = Int64(termsOfService?.version ?? 0)
                $0.url = termsOfService?.url ?? ""
            }
            $0.rights = rights?.map({ right in
                return .with {
                    $0.code = right.code ?? ""
                    $0.name = right.name ?? ""
                    $0.description_p = right.description ?? ""
                }
            }) ?? []
            $0.regulations = regulations ?? []
            $0.purposes = purposes?.map({ purpose in
                return .with {
                    $0.code = purpose.code ?? ""
                    $0.name = purpose.name ?? ""
                    $0.description_p = purpose.description ?? ""
                    $0.legalBasisCode = purpose.legalBasisCode ?? ""
                    $0.requiresPrivacyPolicy = purpose.requiresPrivacyPolicy ?? false
                    $0.requiresOptIn = purpose.requiresOptIn ?? false
                    $0.allowsOptOut = purpose.allowsOptOut ?? false
                }
            }) ?? []
            $0.services = {
                var servicesDict: [String: String] = [:]
                servicesDict[ServicesKeys.astrolabe.rawValue] = services?.astrolabe
                servicesDict[ServicesKeys.gangplank.rawValue] = services?.gangplank
                servicesDict[ServicesKeys.halyard.rawValue] = services?.halyard
                servicesDict[ServicesKeys.supercargo.rawValue] = services?.supercargo
                servicesDict[ServicesKeys.wheelhouse.rawValue] = services?.wheelhouse
                return servicesDict
            }()
            $0.options = {
                var optionsDict: [String: Int32] = [:]
                if let localStorage = options?.localStorage, localStorage != -1 {
                    optionsDict[OptionsKeys.localStorage.rawValue] = Int32(localStorage)
                }
                if let migration = options?.migration, migration != -1 {
                    optionsDict[OptionsKeys.migration.rawValue] = Int32(migration)
                }
                return optionsDict
            }()
        }
    }
}
