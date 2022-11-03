//
//  TCF.swift
//  KetchSDK
//
//  Created by Anton Lyfar on 25.10.2022.
//

import Foundation
import UIKit

private let TCF_TCString_Key = "IABTCF_TCString"
private let TCF_gdprApplies_Key = "IABTCF_gdprApplies"

public class TCF: PolicyPlugin {
    public typealias TCF_String = String

    private let vendorListVersion: Int

    init(
        with configuration: KetchSDK.Configuration,
        vendorListVersion: Int,
        userDefaults: UserDefaults = .standard
    ) throws {
        guard configuration.regulations?.contains(Constants.GDPREU) == true else {
            throw PolicyPluginError.notApplicableToConfig
        }

        self.vendorListVersion = vendorListVersion
        try super.init(with: configuration, userDefaults: userDefaults)
    }

    public override func consentChanged(consent: KetchSDK.ConsentStatus) {
        let encodedString = encode(with: consent)

        save(encodedString, forKey: TCF_TCString_Key)
        save(true , forKey: TCF_gdprApplies_Key)
    }

    public func encode(
        with consent: KetchSDK.ConsentStatus
    ) -> TCF_String {
        let consentPurposes = consent.purposes.filter(\.value).map(\.key)

        let purposes = configuration.purposes?.filter { purpose in
            purpose.tcfID?.isEmpty == false
            && consentPurposes.contains(purpose.code)
        } ?? []

        let purposesConsent = purposes
            .filter { $0.tcfType == Constants.TCF_PURPOSE_TYPE }
            .filter { $0.legalBasisCode == Constants.CONSENT_OPTIN }
            .compactMap(\.tcfID)
            .compactMap(Int16.init)

        let purposesLITransparency = purposes
            .filter { $0.tcfType == Constants.TCF_PURPOSE_TYPE }
            .filter { $0.legalBasisCode == Constants.CONSENT_OPTIN || $0.legalBasisCode == Constants.LEGITIMATEINTEREST_OBJECTABLE }
            .compactMap(\.tcfID)
            .compactMap(Int16.init)

        let specialFeatureOptIns = purposes
            .filter { $0.tcfType == Constants.TCF_SPECIAL_FEATURE_TYPE }
            .compactMap(\.tcfID)
            .compactMap(Int16.init)

        let vendors = configuration.vendors?.filter { vendor in
            consent.vendors?.contains(vendor.id) ?? false
        } ?? []

        let vendorsConsent = vendors.compactMap { vendor in Int16(vendor.id) }
        let vendorLegitimateInterest = vendorsConsent

        let encoder = TCStringEncoderV2(
            version: Constants.VERSION,
            cmpId: Constants.CMP_ID,
            cmpVersion: Constants.CMP_VERSION,
            consentLanguage: configuration.language,
            vendorListVersion: vendorListVersion,
            purposesConsent: Set(purposesConsent),
            vendorsConsent: Set(vendorsConsent),
            isServiceSpecific: Constants.IS_SERVICE_SPECIFIC,
            useNonStandardStacks: Constants.USE_NON_STANDART_STACKS,
            specialFeatureOptIns: Set(specialFeatureOptIns),
            purposesLITransparency: Set(purposesLITransparency),
            vendorLegitimateInterest: Set(vendorLegitimateInterest)
        )

        return try! encoder.encode()
    }
}

extension TCF {
    private enum Constants {
        static let GDPREU = "gdpreu"

        static let VERSION = 2
        static let CMP_ID = 2
        static let CMP_VERSION = 1
        static let USE_NON_STANDART_STACKS = false
        static let IS_SERVICE_SPECIFIC = true

        static let TCF_PURPOSE_TYPE = "purpose"
        static let TCF_SPECIAL_FEATURE_TYPE = "specialFeature"

        static let CONSENT_OPTIN = "consent_optin"
        static let LEGITIMATEINTEREST_OBJECTABLE = "legitimateinterest_objectable"
    }
}

struct TCStringEncoderV2 {
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
    let pubPurposesConsent: Set<Int16>
    let numberOfCustomPurposes: Int16
    let customPurposesConsent: Set<Int16>
    let customPurposesLITransparency: Set<Int16>
    let pubPurposesLITransparency: Set<Int16>
    let publisherRestrictions: [PublisherRestrictionEntry]

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
        publisherRestrictions: [PublisherRestrictionEntry] = []
    ) {
        self.version = version
        self.created = created
        self.updated = updated
        self.cmpId = cmpId
        self.cmpVersion = cmpVersion
        self.consentScreen = consentScreen
        self.consentLanguage = consentLanguage ?? Default.consentLanguage
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
        self.pubPurposesConsent = pubPurposesConsent
        self.numberOfCustomPurposes = numberOfCustomPurposes
        self.customPurposesConsent = customPurposesConsent
        self.customPurposesLITransparency = customPurposesLITransparency
        self.pubPurposesLITransparency = pubPurposesLITransparency
        self.publisherRestrictions = publisherRestrictions
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

protocol TCFEncoder {
    func encode() throws -> String
}

extension TCStringEncoderV2: TCFEncoder {
    enum EncoderError: Error {
        case incompatibleVersion(Int)
        case invalidLanguageCode(String)
        case emptyValue(named: String)
    }

    func encode() throws -> String {
        let core = try encodeCore()

        let vendorsEncoder = VendorEncoder(
            vendors: [],
            disclosedVendors: [],
            allowedVendors: []
        )

        let disclosedVendorsSegment = vendorsEncoder.encodeDisclosedVendors()
        let allowedVendorsSegment = vendorsEncoder.encodeAllowedVendors()

        let publisherEncoder = PublisherEncoder(
            pubPurposesConsent: purposesConsent,
            pubPurposesLITransparency: purposesLITransparency,
            numberOfCustomPurposes: numberOfCustomPurposes,
            customPurposesConsent: customPurposesConsent,
            customPurposesLITransparency: customPurposesLITransparency
        )
        let publisherSegment = try? publisherEncoder.encode()

        return [core, disclosedVendorsSegment, allowedVendorsSegment, publisherSegment]
            .compactMap { $0 }
            .joined(separator: ".")
    }

    func encodeCore() throws -> String {
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

        let vendorsConsent = (try? VendorEncoder(vendors: vendorsConsent).encode()) ?? String()
        let vendorInterest = (try? VendorEncoder(vendors: vendorLegitimateInterest).encode()) ?? String()

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

            let encodedVendors = try! VendorEncoder(
                vendors: Set(publisherRestriction.vendors),
                emitRangeEncoding: true,
                emitMaxVendorId: false,
                emitIsRangeEncoding: false,
                disclosedVendors: disclosedVendors,
                allowedVendors: allowedVendors
            ).encode()

            consentString.append(encodedVendors)
        }

        return consentString.trimmedWebSafeBase64EncodedString()
    }
}

extension TCFEncoder {
    func encode(_ bool: Bool, to length: Int) -> String {
        encode(bool ? 1 : 0, to: length)
    }

    func encode(_ integer: UInt8, to length: Int) -> String {
        String(integer, radix: 2).padLeft(to: length)
    }

    func encode(_ integer: Int16, to length: Int) -> String {
        String(integer, radix: 2).padLeft(to: length)
    }

    func encode(_ integer: Int, to length: Int) -> String {
        String(integer, radix: 2)
            .padLeft(to: length)
    }

    func encode(_ date: Date, to length: Int) -> String {
        encode(Int(date.timeIntervalSince1970 * 10), to: length)
    }

    func encode(_ indices: Set<Int16>, to length: Int) -> String {
        let minIndex: Int16 = 1
        let maxIndex = minIndex + Int16(length) - 1

        var bitString = [Character](repeating: "0", count: length)

        indices
            .forEach { index in
                guard (minIndex...maxIndex).contains(index) else { return }

                bitString[Int(index - minIndex)] = "1"
            }

        return String(bitString)
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

//         OOB_SEGMENT_TYPE(3, 0),
//
//         // disallowed vendor fields
//         DV_MAX_VENDOR_ID(16, OOB_SEGMENT_TYPE),
//         DV_IS_RANGE_ENCODING(1),
//         DV_VENDOR_BITRANGE_FIELD(
//                 BitRangeFieldUtils.lengthSupplier(DV_IS_RANGE_ENCODING, DV_MAX_VENDOR_ID)),
//
//         // allowed vendor fields
//         AV_MAX_VENDOR_ID(16, OOB_SEGMENT_TYPE),
//         AV_IS_RANGE_ENCODING(1),
//         AV_VENDOR_BITRANGE_FIELD(
//                 BitRangeFieldUtils.lengthSupplier(AV_IS_RANGE_ENCODING, AV_MAX_VENDOR_ID)),
//
//         // publisher purposes transparency and consent
//         PPTC_SEGMENT_TYPE(3, 0),
//         PPTC_PUB_PURPOSES_CONSENT(24),
//         PPTC_PUB_PURPOSES_LI_TRANSPARENCY(24),
//         PPTC_NUM_CUSTOM_PURPOSES(6),
//
//
//         // range entry, only field lengths are supported
//         NUM_ENTRIES(12, OffsetSupplier.NOT_SUPPORTED),
//         IS_A_RANGE(1, OffsetSupplier.NOT_SUPPORTED),
//         START_OR_ONLY_VENDOR_ID(16, OffsetSupplier.NOT_SUPPORTED),
//         END_VENDOR_ID(16, OffsetSupplier.NOT_SUPPORTED),
//         TIMESTAMP(36, OffsetSupplier.NOT_SUPPORTED),
//
//         // publish restriction fields, only field lengths are supported
//         PURPOSE_ID(6, OffsetSupplier.NOT_SUPPORTED),
//         RESTRICTION_TYPE(2, OffsetSupplier.NOT_SUPPORTED),
//
//         CHAR(6, OffsetSupplier.NOT_SUPPORTED)
    }
}

private extension String {
    func padLeft(withCharacter character: String = "0", to length: Int) -> String {
        let padCount = length - count
        guard padCount > 0 else { return self }
        return String(repeating: character, count: padCount) + self
    }

    func padRight(withCharacter character: String = "0", toLength length: Int) -> String {
        let padCount = length - count
        guard padCount > 0 else { return self }
        return self + String(repeating: character, count: padCount)
    }

    func padRight(withCharacter character: String = "0", toNearestMultipleOf multiple: Int) -> String {
        let (byteCount, bitRemainder) = count.quotientAndRemainder(dividingBy: multiple)
        let totalBytes = byteCount + (bitRemainder > 0 ? 1 : 0)
        return padRight(toLength: totalBytes * multiple)
    }

    func split(by length: Int) -> [String] {
        var startIndex = self.startIndex
        var results = [Substring]()

        while startIndex < self.endIndex {
            let endIndex = self.index(startIndex, offsetBy: length, limitedBy: self.endIndex) ?? self.endIndex
            results.append(self[startIndex..<endIndex])
            startIndex = endIndex
        }

        return results.map { String($0) }
    }

    func trimmedWebSafeBase64EncodedString() -> String {
        let data = Data(split(by: 8).compactMap { UInt8($0, radix: 2) })

        return data.base64EncodedString()
            .trimmingCharacters(in: ["="])
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
    }
}

struct VendorEncoder: TCFEncoder {
    enum VendorEncodingType: Int {
        case bitField = 0
        case range = 1
    }

    let vendors: Set<Int16>
    let maxVendorId: Int16
    let defaultConsent: Bool
    let emitRangeEncoding: Bool
    let emitMaxVendorId: Bool
    let emitIsRangeEncoding: Bool
    let disclosedVendors: Set<Int16>
    let allowedVendors: Set<Int16>

    init(
        vendors: Set<Int16>,
        maxVendorId: Int16 = 0,
        defaultConsent: Bool = false,
        emitRangeEncoding: Bool = false,
        emitMaxVendorId: Bool = true,
        emitIsRangeEncoding: Bool = true,
        disclosedVendors: Set<Int16> = [],
        allowedVendors: Set<Int16> = []
    ) {
        self.vendors = vendors
        self.maxVendorId = maxVendorId
        self.defaultConsent = defaultConsent
        self.emitRangeEncoding = emitRangeEncoding
        self.emitMaxVendorId = emitMaxVendorId
        self.emitIsRangeEncoding = emitIsRangeEncoding
        self.disclosedVendors = disclosedVendors
        self.allowedVendors = allowedVendors
    }

    func encode() throws -> String {
        if vendors.isEmpty {
            return encode(0, to: FieldIndices.CORE_VENDOR_MAX_VENDOR_ID)
            + encode(false, to: FieldIndices.CORE_VENDOR_IS_RANGE_ENCODING)
        }

        let maxVendorId = vendors.max() ?? 0
        var vendorsEncoded = String()

        if emitMaxVendorId {
            vendorsEncoded.append(encode(maxVendorId, to: FieldIndices.CORE_VENDOR_MAX_VENDOR_ID))
        }

        // we encode by both methods (bit field and ranges) and use whichever is smallest
        let encodingUsingBitField = vendorsEncoded
            .appending(bitFieldBinaryString(allowedVendorIds: vendors, maxVendorId: maxVendorId))

        let encodingUsingRanges = vendorsEncoded
            .appending(rangesBinaryString(allowedVendorIds: vendors, maxVendorId: maxVendorId))

        if encodingUsingRanges.count < encodingUsingBitField.count || emitRangeEncoding {
            return encodingUsingRanges
        } else {
            return encodingUsingBitField
        }
    }

    func bitFieldBinaryString(allowedVendorIds: Set<Int16>, maxVendorId: Int16) -> String {
        var consentString = ""
        consentString.append(encode(VendorEncodingType.bitField.rawValue, to: FieldIndices.CORE_VENDOR_IS_RANGE_ENCODING))
        consentString.append(encode(vendorBitFieldForVendors: allowedVendorIds, maxVendorId: maxVendorId))
        return consentString
    }

    func rangesBinaryString(allowedVendorIds: Set<Int16>, maxVendorId: Int16) -> String {
        var consentString = ""
        if emitIsRangeEncoding {
            consentString.append(encode(VendorEncodingType.range.rawValue, to: FieldIndices.CORE_VENDOR_IS_RANGE_ENCODING))
        }

        consentString.append(encode(vendorRanges: ranges(for: allowedVendorIds, in: Set(1...maxVendorId), defaultConsent: defaultConsent)))
        return consentString
    }

    func encode(vendorBitFieldForVendors vendors: Set<Int16>, maxVendorId: Int16) -> String {
        guard maxVendorId >= 1 else { return "" }

        return (1...maxVendorId).reduce("") { $0 + (vendors.contains($1) ? "1" : "0") }
    }

    func encode(vendorRanges ranges: [ClosedRange<Int16>]) -> String {
        var string = ""

        string.append(encode(ranges.count, to: FieldIndices.NUM_ENTRIES))

        for range in ranges {
            if range.count == 1 {
                // single entry
                string.append(encode(0, to: 1))
                string.append(encode(range.lowerBound, to: FieldIndices.CORE_VENDOR_VENDOR_ID))
            } else {
                // range entry
                string.append(encode(1, to: 1))
                string.append(encode(range.lowerBound, to: FieldIndices.CORE_VENDOR_VENDOR_ID))
                string.append(encode(range.upperBound, to: FieldIndices.CORE_VENDOR_VENDOR_ID))
            }
        }

        return string
    }

    func ranges(for allowedVendorIds: Set<Int16>, in allVendorIds: Set<Int16>, defaultConsent: Bool) -> [ClosedRange<Int16>] {
        let vendorsToEncode = defaultConsent ? allVendorIds.subtracting(allowedVendorIds).sorted() : allowedVendorIds.sorted()

        var ranges = [ClosedRange<Int16>]()
        var currentRangeStart: Int16?
        for vendorId in allVendorIds.sorted() {
            if vendorsToEncode.contains(vendorId) {
                if currentRangeStart == nil {
                    // start a new range
                    currentRangeStart = vendorId
                }
            } else if let rangeStart = currentRangeStart {
                // close the range
                ranges.append(rangeStart...vendorId-1)
                currentRangeStart = nil
            }
        }

        // close any range open at the end
        if let rangeStart = currentRangeStart, let last = vendorsToEncode.last {
            ranges.append(rangeStart...last)
            currentRangeStart = nil
        }

        return ranges
    }
}

extension VendorEncoder {
    enum FieldIndices {
        static let CORE_VENDOR_VENDOR_ID = 16
        static let NUM_ENTRIES = 12
        static let CORE_VENDOR_MAX_VENDOR_ID = 16
        static let CORE_VENDOR_IS_RANGE_ENCODING = 1

        static let CORE_VENDOR_LI_MAX_VENDOR_ID = 16
        static let CORE_VENDOR_LI_IS_RANGE_ENCODING = 1
        static let CORE_NUM_PUB_RESTRICTION = 12

        static let OOB_SEGMENT_TYPE = 3
    }
}

extension VendorEncoder {
    func encodeDisclosedVendors() -> String? {
        if disclosedVendors.isEmpty { return nil }

        var consentString = ""
        consentString.append(encode(TCStringEncoderV2.SegmentType.disclosedVendor.rawValue, to: FieldIndices.OOB_SEGMENT_TYPE))
        consentString.append(encode(vendorBitFieldForVendors: disclosedVendors, maxVendorId: maxVendorId))

        return consentString.trimmedWebSafeBase64EncodedString()
    }

    func encodeAllowedVendors() -> String? {
        if allowedVendors.isEmpty { return nil }

        var consentString = ""
        consentString.append(encode(TCStringEncoderV2.SegmentType.allowedVendor.rawValue, to: FieldIndices.OOB_SEGMENT_TYPE))
        consentString.append(encode(vendorBitFieldForVendors: allowedVendors, maxVendorId: maxVendorId))

        return consentString.trimmedWebSafeBase64EncodedString()
    }
}

struct PublisherEncoder: TCFEncoder {
    enum FieldIndices {
        static let CORE_VENDOR_VENDOR_ID = 16
        static let NUM_ENTRIES = 12
        static let CORE_VENDOR_MAX_VENDOR_ID = 16
        static let CORE_VENDOR_IS_RANGE_ENCODING = 1

        static let CORE_VENDOR_LI_MAX_VENDOR_ID = 16
        static let CORE_VENDOR_LI_IS_RANGE_ENCODING = 1
        static let CORE_NUM_PUB_RESTRICTION = 12

        static let PPTC_PUB_PURPOSES_CONSENT: Int16 = 24
        static let PPTC_PUB_PURPOSES_LI_TRANSPARENCY: Int16 = 24
        static let PPTC_NUM_CUSTOM_PURPOSES = 6

        static let PPTC_SEGMENT_TYPE = 3
    }

    let pubPurposesConsent: Set<Int16>
    let pubPurposesLITransparency: Set<Int16>
    let numberOfCustomPurposes: Int16
    let customPurposesConsent: Set<Int16>
    let customPurposesLITransparency: Set<Int16>

    init(
        pubPurposesConsent: Set<Int16>,
        pubPurposesLITransparency: Set<Int16>,
        numberOfCustomPurposes: Int16,
        customPurposesConsent: Set<Int16>,
        customPurposesLITransparency: Set<Int16>
    ) {
        self.pubPurposesConsent = pubPurposesConsent
        self.pubPurposesLITransparency = pubPurposesLITransparency
        self.numberOfCustomPurposes = numberOfCustomPurposes
        self.customPurposesConsent = customPurposesConsent
        self.customPurposesLITransparency = customPurposesLITransparency
    }

    /// Publisher Purposes Transparency and Consent segment
    /// - Returns: Encoded string
    func encode() throws -> String {
        guard pubPurposesConsent.isEmpty == false
        else { throw TCStringEncoderV2.EncoderError.emptyValue(named: "pubPurposesConsent") }

        guard pubPurposesLITransparency.isEmpty == false
        else { throw TCStringEncoderV2.EncoderError.emptyValue(named: "pubPurposesLITransparency") }

        guard numberOfCustomPurposes > 0
        else { throw TCStringEncoderV2.EncoderError.emptyValue(named: "numberOfCustomPurposes") }

        var consentString = ""
        consentString.append(encode(TCStringEncoderV2.SegmentType.publisherTC.rawValue, to: FieldIndices.PPTC_SEGMENT_TYPE))
        consentString.append(encode(pubPurposesConsent, count: FieldIndices.PPTC_PUB_PURPOSES_CONSENT))
        consentString.append(encode(pubPurposesLITransparency, count: FieldIndices.PPTC_PUB_PURPOSES_LI_TRANSPARENCY))
        consentString.append(encode(numberOfCustomPurposes, to: FieldIndices.PPTC_NUM_CUSTOM_PURPOSES))
        consentString.append(encode(customPurposesConsent, count: numberOfCustomPurposes))
        consentString.append(encode(customPurposesLITransparency, count: numberOfCustomPurposes))

        return consentString.trimmedWebSafeBase64EncodedString()
    }

    func encode(_ values: Set<Int16>, count: Int16) -> String {
        guard count >= 1 else { return "" }

        return (1...count).reduce("") { $0 + (values.contains($1) ? "1" : "0") }
    }
}
