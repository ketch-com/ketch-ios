//
//  Consent.swift
//  KetchSDK
//
//  Created by Anton Lyfar on 11.10.2022.
//

import Foundation

extension KetchSDK {
    public struct ConsentUpdate: Codable {
        public let organizationCode: String
        public let controllerCode: String?
        public let propertyCode: String
        public let environmentCode: String
        public let identities: [String: String]
        public let collectedAt: Int?
        public let jurisdictionCode: String
        public let migrationOption: MigrationOption
        public let purposes: [String: PurposeAllowedLegalBasis]
        public let vendors: [String]?

        public init(
            organizationCode: String,
            controllerCode: String?,
            propertyCode: String,
            environmentCode: String,
            identities: [String: String],
            collectedAt: Int?,
            jurisdictionCode: String,
            migrationOption: MigrationOption,
            purposes: [String: PurposeAllowedLegalBasis],
            vendors: [String]?
        ) {
            self.organizationCode = organizationCode
            self.controllerCode = controllerCode
            self.propertyCode = propertyCode
            self.environmentCode = environmentCode
            self.identities = identities
            self.collectedAt = collectedAt
            self.jurisdictionCode = jurisdictionCode
            self.migrationOption = migrationOption
            self.purposes = purposes
            self.vendors = vendors
        }
    }
}

extension KetchSDK.ConsentUpdate {
    public enum MigrationOption: String, Codable {
        case migrateDefault = "MIGRATE_DEFAULT"
        case migrateNever = "MIGRATE_NEVER"
        case migrateFromAllow = "MIGRATE_FROM_ALLOW"
        case migrateFromDeny = "MIGRATE_FROM_DENY"
        case migrateAlways = "MIGRATE_ALWAYS"
    }

    public struct PurposeAllowedLegalBasis: Codable {
        public let allowed: Bool
        public let legalBasisCode: String

        public init(
            allowed: Bool,
            legalBasisCode: String
        ) {
            self.allowed = allowed
            self.legalBasisCode = legalBasisCode
        }

        public func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(allowed.description, forKey: .allowed)
            try container.encode(legalBasisCode, forKey: .legalBasisCode)
        }
    }
}

extension KetchSDK {
    public struct ConsentConfig: Codable {
        public let organizationCode: String
        public let controllerCode: String?
        public let propertyCode: String
        public let environmentCode: String
        public let jurisdictionCode: String
        public let identities: [String: String]
        public let purposes: [String: PurposeLegalBasis]
    }
}

extension KetchSDK.ConsentConfig {
    public struct PurposeLegalBasis: Codable {
        public let legalBasisCode: String
    }
}

extension KetchSDK {
    public struct ConsentStatus: Codable {
        public let purposes: [String: Bool]
        public let vendors: [String]?

        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            vendors = try? container.decode([String].self, forKey: .vendors)
            let purposes = try? container.decode([String: String].self, forKey: .purposes)
            let keyValues: [(String, Bool)] = purposes?.compactMap {
                guard let value = Bool($1) else { return nil }

                return ($0, value)
            } ?? []
            self.purposes = [String: Bool](uniqueKeysWithValues: keyValues)
        }
    }
}
