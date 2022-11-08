//
//  TCF.swift
//  KetchSDK
//
//  Created by Anton Lyfar on 25.10.2022.
//

import Foundation

private let TCF_TCString_Key = "IABTCF_TCString"
private let TCF_gdprApplies_Key = "IABTCF_gdprApplies"

public class TCF: PolicyPlugin {
    public typealias TCF_String = String

    public override var protocolID: String { "TCF" }

    public override var isApplied: Bool {
        configuration?.regulations?.contains(Constants.GDPREU) == true
    }

    public override func consentChanged(_ consentStatus: KetchSDK.ConsentStatus) {
        let encodedString = encode(with: consentStatus)

        save(encodedString, forKey: TCF_TCString_Key)
        save(true , forKey: TCF_gdprApplies_Key)
    }

    public func encode(
        with consent: KetchSDK.ConsentStatus
    ) -> TCF_String {
        let consentPurposes = consent.purposes.filter(\.value).map(\.key)

        let purposes = configuration?.purposes?.filter { purpose in
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

        let vendors = configuration?.vendors?.filter { vendor in
            consent.vendors?.contains(vendor.id) ?? false
        } ?? []

        let vendorsConsent = vendors.compactMap { vendor in Int16(vendor.id) }
        let vendorLegitimateInterest = vendorsConsent

        let encoder = TCStringEncoderV2(
            version: Constants.VERSION,
            cmpId: Constants.CMP_ID,
            cmpVersion: Constants.CMP_VERSION,
            consentLanguage: configuration?.language,
            vendorListVersion: 128,
            purposesConsent: Set(purposesConsent),
            vendorsConsent: Set(vendorsConsent),
            isServiceSpecific: Constants.IS_SERVICE_SPECIFIC,
            useNonStandardStacks: Constants.USE_NON_STANDART_STACKS,
            specialFeatureOptIns: Set(specialFeatureOptIns),
            purposesLITransparency: Set(purposesLITransparency),
            vendorLegitimateInterest: Set(vendorLegitimateInterest),
            vendors: []
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
