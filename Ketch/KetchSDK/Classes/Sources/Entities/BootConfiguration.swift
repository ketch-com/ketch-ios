//
//  BootConfiguration.swift
//  KetchSDK
//
//  Created by Anton Lyfar on 11.10.2022.
//

import Foundation

public struct BootConfiguration: Codable {
    public let v: Int?
    public let organization: Organization?
    public let app: Property?
    public let environments: [Environment]?
    public let policyScope: PolicyScope?
    public let identities: [String: Identity]?
    public let scripts: [String]?
    public let languages: [Language]?
    public let services: [String: String]?
    public let options: [String: Int]?
    public let optionsNew: [String: String]?
    public let property: Property?
    public let jurisdiction: PolicyScope?
}

extension BootConfiguration {
    public typealias Organization = Configuration.Organization
    public typealias Property = Configuration.Property
    public typealias Environment = Configuration.Environment
    public typealias Identity = Configuration.Identity

    public struct PolicyScope: Codable {
        public let defaultScopeCode: String?
        public let scopes: [String: String]?
    }

    public struct Language: Codable {
        public let code: String?
        public let englishName: String?
        public let nativeName: String?
    }
}
