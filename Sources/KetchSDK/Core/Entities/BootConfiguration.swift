//
//  BootConfiguration.swift
//  KetchSDK
//

import Foundation

extension KetchSDK {
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
}

extension KetchSDK.BootConfiguration {
    public typealias Organization = KetchSDK.Configuration.Organization
    public typealias Property = KetchSDK.Configuration.Property
    public typealias Environment = KetchSDK.Configuration.Environment
    public typealias Identity = KetchSDK.Configuration.Identity

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
