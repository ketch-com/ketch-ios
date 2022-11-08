//
//  TCStringEncoderV2.swift
//  KetchSDK
//
//  Created by Anton Lyfar on 03.11.2022.
//

import Foundation

struct TCStringEncoderV2 {
    let coreSegmentEncoder: CoreSegmentEncoder
    let disclosedVendorsSegmentEncoder: VendorSegmentEncoder
    let allowedVendorsSegmentEncoder: VendorSegmentEncoder
    let publisherSegmentEncoder: PublisherSegmentEncoder

    init(
        version: Int = Default.version,
        created: Date = Date(),
        updated: Date = Date(),
        cmpId: Int = Default.cmpId,
        cmpVersion: Int = Default.cmpVersion,
        consentScreen: Int = Default.consentScreen,
        consentLanguage: String? = Default.consentLanguage,
        vendorListVersion: Int = Default.vendorListVersion,
        purposesConsent: Set<Int16> = [],
        vendorsConsent: Set<Int16> = [],
        tcfPolicyVersion: Int = Default.tcfPolicyVersion,
        isServiceSpecific: Bool = Default.isServiceSpecific,
        useNonStandardStacks: Bool = Default.useNonStandardStacks,
        specialFeatureOptIns: Set<Int16> = [],
        purposesLITransparency: Set<Int16> = [],
        purposeOneTreatment: Bool = Default.purposeOneTreatment,
        publisherCC: String = Default.publisherCC,
        vendorLegitimateInterest: Set<Int16> = [],
        disclosedVendors: Set<Int16> = [],
        allowedVendors: Set<Int16> = [],
        pubPurposesConsent: Set<Int16> = [],
        numberOfCustomPurposes: Int16 = 0,
        customPurposesConsent: Set<Int16> = [],
        customPurposesLITransparency: Set<Int16> = [],
        pubPurposesLITransparency: Set<Int16> = [],
        publisherRestrictions: [PublisherRestrictionEntry] = [],
        vendors: Set<Int16>,
        maxVendorId: Int16 = 0,
        defaultConsent: Bool = false,
        emitRangeEncoding: Bool = false,
        emitMaxVendorId: Bool = true,
        emitIsRangeEncoding: Bool = true
    ) {
        coreSegmentEncoder = CoreSegmentEncoder(
            version: version,
            created: created,
            updated: updated,
            cmpId: cmpId,
            cmpVersion: cmpVersion,
            consentScreen: consentScreen,
            consentLanguage: consentLanguage ?? Default.consentLanguage,
            vendorListVersion: vendorListVersion,
            purposesConsent: purposesConsent,
            vendorsConsent: vendorsConsent,
            tcfPolicyVersion: tcfPolicyVersion,
            isServiceSpecific: isServiceSpecific,
            useNonStandardStacks: useNonStandardStacks,
            specialFeatureOptIns: specialFeatureOptIns,
            purposesLITransparency: purposesLITransparency,
            purposeOneTreatment: purposeOneTreatment,
            publisherCC: publisherCC,
            vendorLegitimateInterest: vendorLegitimateInterest,
            disclosedVendors: disclosedVendors,
            allowedVendors: allowedVendors,
            pubPurposesConsent: pubPurposesConsent,
            numberOfCustomPurposes: numberOfCustomPurposes,
            customPurposesConsent: customPurposesConsent,
            customPurposesLITransparency: customPurposesLITransparency,
            pubPurposesLITransparency: pubPurposesLITransparency,
            publisherRestrictions: publisherRestrictions
        )

        disclosedVendorsSegmentEncoder = VendorSegmentEncoder(
            vendors: disclosedVendors,
            segmentType: .disclosedVendor,
            defaultConsent: defaultConsent,
            emitRangeEncoding: emitRangeEncoding,
            emitMaxVendorId: emitMaxVendorId,
            emitIsRangeEncoding: emitIsRangeEncoding
        )

        allowedVendorsSegmentEncoder = VendorSegmentEncoder(
            vendors: allowedVendors,
            segmentType: .allowedVendor,
            defaultConsent: defaultConsent,
            emitRangeEncoding: emitRangeEncoding,
            emitMaxVendorId: emitMaxVendorId,
            emitIsRangeEncoding: emitIsRangeEncoding
        )

        publisherSegmentEncoder = PublisherSegmentEncoder(
            pubPurposesConsent: purposesConsent,
            pubPurposesLITransparency: purposesLITransparency,
            numberOfCustomPurposes: numberOfCustomPurposes,
            customPurposesConsent: customPurposesConsent,
            customPurposesLITransparency: customPurposesLITransparency
        )
    }
}


extension TCStringEncoderV2: TCFStringSegmentEncoder {
    func encode() throws -> String {
        let requiredSegment = try coreSegmentEncoder.encode()

        let optionalSegmentsEncoders: [TCFStringSegmentEncoder] = [
            disclosedVendorsSegmentEncoder,
            allowedVendorsSegmentEncoder,
            publisherSegmentEncoder
        ]

        let optionalSegments = optionalSegmentsEncoders.map { try? $0.encode() }

        return ([requiredSegment] + optionalSegments)
            .compactMap { $0 }
            .joined(separator: ".")
    }
}



extension TCStringEncoderV2 {
    enum SegmentType: Int {
        case core
        case disclosedVendor
        case allowedVendor
        case publisherTC
        case invalid = -1

        init?(rawValue: Int) {
            switch rawValue {
            case 0: self = .core
            case 1: self = .disclosedVendor
            case 2: self = .allowedVendor
            case 3: self = .publisherTC
            default: self = .invalid
            }
        }
    }

    struct PublisherRestrictionEntry {
        let purposeId: Int
        let restrictionType: RestrictionType
        let vendors: Set<Int16>
    }

    enum RestrictionType: Int {
        case notAllowed = 0
        case requireConsent = 1
        case requireLegitimateInterest = 2
        case undefined = 3

        init(rawValue: Int) {
            switch rawValue {
            case 1: self = .requireConsent
            case 2: self = .requireLegitimateInterest
            case 3: self = .undefined
            default: self = .notAllowed
            }
        }
    }

    enum Default {
        static let version = 0
        static let cmpId = 0
        static let cmpVersion = 0
        static let consentScreen = 0
        static let consentLanguage = "EN"
        static let vendorListVersion = 0
        static let tcfPolicyVersion = 0
        static let isServiceSpecific = false
        static let useNonStandardStacks = false
        static let purposeOneTreatment = false
        static let publisherCC = "US"
    }
}
