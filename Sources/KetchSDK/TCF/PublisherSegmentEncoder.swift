//
//  PublisherSegmentEncoder.swift
//  KetchSDK
//

import Foundation

struct PublisherSegmentEncoder: TCFStringSegmentEncoder {
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

        return trimWebSafeBase64EncodedString(consentString)
    }

    func encode(_ values: Set<Int16>, count: Int16) -> String {
        guard count >= 1 else { return "" }

        return (1...count).reduce("") { $0 + (values.contains($1) ? "1" : "0") }
    }
}
