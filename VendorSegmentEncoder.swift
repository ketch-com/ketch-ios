//
//  VendorSegmentEncoder.swift
//  KetchSDK
//
//  Created by Anton Lyfar on 03.11.2022.
//

import Foundation

struct VendorSegmentEncoder: TCFStringSegmentEncoder {
    let vendors: Set<Int16>
    let segmentType: TCStringEncoderV2.SegmentType
    let maxVendorId: Int16
    let defaultConsent: Bool
    let emitRangeEncoding: Bool
    let emitMaxVendorId: Bool
    let emitIsRangeEncoding: Bool

    init(
        vendors: Set<Int16>,
        segmentType: TCStringEncoderV2.SegmentType,
        defaultConsent: Bool = false,
        emitRangeEncoding: Bool = false,
        emitMaxVendorId: Bool = true,
        emitIsRangeEncoding: Bool = true
    ) {
        self.vendors = vendors
        self.segmentType = segmentType
        self.defaultConsent = defaultConsent
        self.emitRangeEncoding = emitRangeEncoding
        self.emitMaxVendorId = emitMaxVendorId
        self.emitIsRangeEncoding = emitIsRangeEncoding

        maxVendorId = vendors.max() ?? 0
    }

    func encode() throws -> String {
        try encode(segment: segmentType)
    }

    func coreEncoding() throws -> String {
        if vendors.isEmpty {
            return encode(0, to: FieldIndices.CORE_VENDOR_MAX_VENDOR_ID)
            + encode(false, to: FieldIndices.CORE_VENDOR_IS_RANGE_ENCODING)
        }

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
            vendorsEncoded = encodingUsingRanges
        } else {
            vendorsEncoded = encodingUsingBitField
        }

        return vendorsEncoded
    }

    func encode(segment: TCStringEncoderV2.SegmentType) throws -> String {
        switch segment {
        case .core: return try coreEncoding()
        case .disclosedVendor, .allowedVendor: return try segmentEncoding()
        default: throw TCStringEncoderV2.EncoderError.unsupportedSegment
        }
    }

    func segmentEncoding() throws -> String {
        if vendors.isEmpty { throw EncoderError.noVendorsSelected }

        var consentString = ""
        consentString.append(encode(segmentType.rawValue, to: FieldIndices.OOB_SEGMENT_TYPE))
        consentString.append(encode(vendorBitFieldForVendors: vendors, maxVendorId: maxVendorId))

        return trimWebSafeBase64EncodedString(consentString)
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

extension VendorSegmentEncoder {
    typealias EncoderError = TCStringEncoderV2.EncoderError

    enum VendorEncodingType: Int {
        case bitField = 0
        case range = 1
    }

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
