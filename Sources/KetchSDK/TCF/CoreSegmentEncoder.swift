//
//  CoreSegmentEncoder.swift
//  KetchSDK
//

import Foundation

struct CoreSegmentEncoder: TCFStringSegmentEncoder {
    typealias EncoderError = TCStringEncoderV2.EncoderError
    typealias PublisherRestrictionEntry = TCStringEncoderV2.PublisherRestrictionEntry

    let version: Int
    let created: Date
    let updated: Date
    let cmpId: Int
    let cmpVersion: Int
    let consentScreen: Int
    let consentLanguage: String
    let vendorListVersion: Int
    let purposesConsent: Set<Int16>
    let vendorsConsent: Set<Int16>
    let tcfPolicyVersion: Int
    let isServiceSpecific: Bool
    let useNonStandardStacks: Bool
    let specialFeatureOptIns: Set<Int16>
    let purposesLITransparency: Set<Int16>
    let purposeOneTreatment: Bool
    let publisherCC: String
    let vendorLegitimateInterest: Set<Int16>
    let disclosedVendors: Set<Int16>
    let allowedVendors: Set<Int16>

    let publisherRestrictions: [PublisherRestrictionEntry]

    init(
        version: Int,
        created: Date,
        updated: Date,
        cmpId: Int,
        cmpVersion: Int,
        consentScreen: Int,
        consentLanguage: String,
        vendorListVersion: Int,
        purposesConsent: Set<Int16> = [],
        vendorsConsent: Set<Int16> = [],
        tcfPolicyVersion: Int,
        isServiceSpecific: Bool,
        useNonStandardStacks: Bool,
        specialFeatureOptIns: Set<Int16> = [],
        purposesLITransparency: Set<Int16> = [],
        purposeOneTreatment: Bool,
        publisherCC: String,
        vendorLegitimateInterest: Set<Int16> = [],
        disclosedVendors: Set<Int16> = [],
        allowedVendors: Set<Int16> = [],
        pubPurposesConsent: Set<Int16> = [],
        numberOfCustomPurposes: Int16 = 0,
        customPurposesConsent: Set<Int16> = [],
        customPurposesLITransparency: Set<Int16> = [],
        pubPurposesLITransparency: Set<Int16> = [],
        publisherRestrictions: [TCStringEncoderV2.PublisherRestrictionEntry]
    ) {
        self.version = version
        self.created = created
        self.updated = updated
        self.cmpId = cmpId
        self.cmpVersion = cmpVersion
        self.consentScreen = consentScreen
        self.consentLanguage = consentLanguage
        self.vendorListVersion = vendorListVersion
        self.purposesConsent = purposesConsent
        self.vendorsConsent = vendorsConsent
        self.tcfPolicyVersion = tcfPolicyVersion
        self.isServiceSpecific = isServiceSpecific
        self.useNonStandardStacks = useNonStandardStacks
        self.specialFeatureOptIns = specialFeatureOptIns
        self.purposesLITransparency = purposesLITransparency
        self.purposeOneTreatment = purposeOneTreatment
        self.publisherCC = publisherCC
        self.vendorLegitimateInterest = vendorLegitimateInterest
        self.disclosedVendors = disclosedVendors
        self.allowedVendors = allowedVendors
        self.publisherRestrictions = publisherRestrictions
    }

    func encode() throws -> String {
        guard version == 2 else { throw EncoderError.incompatibleVersion(version) }

        guard
            consentLanguage.count == 2,
            let firstLanguageCharacter = consentLanguage
                .uppercased()[consentLanguage.index(consentLanguage.startIndex, offsetBy: 0)]
                .asciiValue,
            firstLanguageCharacter >= Constants.asciiOffset,
            let secondLanguageCharacter = consentLanguage
                .uppercased()[consentLanguage.index(consentLanguage.startIndex, offsetBy: 1)]
                .asciiValue,
            secondLanguageCharacter >= Constants.asciiOffset
        else {
            throw EncoderError.invalidLanguageCode(consentLanguage)
        }

        guard
            publisherCC.count == 2,
            let firstPublisherCCCharacter = publisherCC
                .uppercased()[publisherCC.index(publisherCC.startIndex, offsetBy: 0)]
                .asciiValue,
            firstPublisherCCCharacter >= Constants.asciiOffset,
            let secondPublisherCCCharacter = publisherCC
                .uppercased()[publisherCC.index(publisherCC.startIndex, offsetBy: 1)]
                .asciiValue,
            secondPublisherCCCharacter >= Constants.asciiOffset
        else {
            throw EncoderError.invalidLanguageCode(publisherCC)
        }

        let vendorsConsent = (try? VendorSegmentEncoder(vendors: vendorsConsent, segmentType: .core).encode()) ?? String()
        let vendorInterest = (try? VendorSegmentEncoder(vendors: vendorLegitimateInterest, segmentType: .core).encode()) ?? String()

        var consentString = String()

        consentString.append(encode(version, to: FieldIndices.CORE_VERSION))
        consentString.append(encode(created, to: FieldIndices.CORE_CREATED))
        consentString.append(encode(updated, to: FieldIndices.CORE_LAST_UPDATED))
        consentString.append(encode(cmpId, to: FieldIndices.CORE_CMP_ID))
        consentString.append(encode(cmpVersion, to: FieldIndices.CORE_CMP_VERSION))
        consentString.append(encode(consentScreen, to: FieldIndices.CORE_CONSENT_SCREEN))
        consentString.append(encode(firstLanguageCharacter - Constants.asciiOffset, to: FieldIndices.CORE_CONSENT_LANGUAGE / 2))
        consentString.append(encode(secondLanguageCharacter - Constants.asciiOffset, to: FieldIndices.CORE_CONSENT_LANGUAGE / 2))
        consentString.append(encode(vendorListVersion, to: FieldIndices.CORE_VENDOR_LIST_VERSION))
        consentString.append(encode(tcfPolicyVersion, to: FieldIndices.CORE_TCF_POLICY_VERSION))
        consentString.append(encode(isServiceSpecific, to: FieldIndices.CORE_IS_SERVICE_SPECIFIC))
        consentString.append(encode(useNonStandardStacks, to: FieldIndices.CORE_USE_NON_STANDARD_STOCKS))
        consentString.append(encode(specialFeatureOptIns, to: FieldIndices.CORE_SPECIAL_FEATURE_OPT_INS))
        consentString.append(encode(purposesConsent, to: FieldIndices.CORE_PURPOSES_CONSENT))
        consentString.append(encode(purposesLITransparency, to: FieldIndices.CORE_PURPOSES_LI_TRANSPARENCY))
        consentString.append(encode(purposeOneTreatment, to: FieldIndices.CORE_PURPOSE_ONE_TREATMENT))
        consentString.append(encode(firstPublisherCCCharacter - Constants.asciiOffset, to: FieldIndices.CORE_PUBLISHER_CC / 2))
        consentString.append(encode(secondPublisherCCCharacter - Constants.asciiOffset, to: FieldIndices.CORE_PUBLISHER_CC / 2))
        consentString.append(vendorsConsent)
        consentString.append(vendorInterest)
        consentString.append(encode(publisherRestrictions.count, to: FieldIndices.CORE_NUM_PUB_RESTRICTION))

        publisherRestrictions.forEach { publisherRestriction in
            consentString.append(encode(publisherRestriction.purposeId, to: FieldIndices.PURPOSE_ID))
            consentString.append(encode(publisherRestriction.restrictionType.rawValue, to: FieldIndices.RESTRICTION_TYPE))

            let encodedVendors = try! VendorSegmentEncoder(
                vendors: Set(publisherRestriction.vendors),
                segmentType: .core,
                emitRangeEncoding: true,
                emitMaxVendorId: false,
                emitIsRangeEncoding: false
            ).encode()

            consentString.append(encodedVendors)
        }

        return trimWebSafeBase64EncodedString(consentString)
    }
}

extension CoreSegmentEncoder {
    private enum Constants {
        static let asciiOffset: UInt8 = 65
    }

    enum FieldIndices {
        static let CORE_VERSION = 6
        static let CORE_CREATED = 36
        static let CORE_LAST_UPDATED = 36
        static let CORE_CMP_ID = 12
        static let CORE_CMP_VERSION = 12
        static let CORE_CONSENT_SCREEN = 6
        static let CORE_CONSENT_LANGUAGE = 12
        static let CORE_VENDOR_LIST_VERSION = 12
        static let CORE_TCF_POLICY_VERSION = 6
        static let CORE_IS_SERVICE_SPECIFIC = 1
        static let CORE_USE_NON_STANDARD_STOCKS = 1
        static let CORE_SPECIAL_FEATURE_OPT_INS = 12
        static let CORE_PURPOSES_CONSENT = 24
        static let CORE_PURPOSES_LI_TRANSPARENCY = 24
        static let CORE_PURPOSE_ONE_TREATMENT = 1
        static let CORE_PUBLISHER_CC = 12
        static let CORE_NUM_PUB_RESTRICTION = 12
        static let PURPOSE_ID = 6
        static let RESTRICTION_TYPE = 2
    }
}
