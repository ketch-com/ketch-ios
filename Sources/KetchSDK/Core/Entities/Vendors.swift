//
//  Vendors.swift
//  KetchSDK
//

import Foundation

extension KetchSDK {
    public struct Vendors: Codable {
        public let gvlSpecificationVersion: Int
        public let vendorListVersion: Int
        public let tcfPolicyVersion: Int
        public let lastUpdated: String?
        public let purposes: [String: Purpose]?
        public let specialPurposes: [String: Purpose]?
        public let features: [String: Purpose]?
        public let specialFeatures: [String: Purpose]?
        public let stacks: [String: Stack]?
        public let vendors: [String: Vendor]?
    }
}

extension KetchSDK.Vendors {
    public struct Purpose: Codable {
        public let id: Int
        public let name: String?
        public let description: String?
        public let descriptionLegal: String?
    }

    public struct Stack: Codable {
        public let id: Int
        public let name: String?
        public let description: String?
        public let purposes: [Int]?
        public let specialPurposes: [Int]?
        public let features: [Int]?
        public let specialFeatures: [Int]?
    }

    public struct Vendor: Codable {
        public let id: Int
        public let name: String?
        public let purposes: [Int]?
        public let legIntPurposes: [Int]?
        public let flexiblePurposes: [Int]?
        public let specialPurposes: [Int]?
        public let features: [Int]?
        public let specialFeatures: [Int]?
        public let policyUrl: String?
    }
}
