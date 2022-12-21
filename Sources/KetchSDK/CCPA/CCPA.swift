//
//  CCPA.swift
//  KetchSDK
//

import Foundation

private let USPrivacy_String_Key = "IABUSPrivacy_String"
private let USPrivacy_Applied_Key = "IABUSPrivacy_Applied"

private let TCF_TCString_Key = "IABTCF_TCString"
private let TCF_gdprApplies_Key = "IABTCF_gdprApplies"

/// Implementation CCPA protocol handling as PolicyPlugin
public class CCPA: PolicyPlugin {
    public typealias CCPA_String = String

    let notice = false
    let lspa = false

    public override var protocolID: String { "CCPA" }

    public override var isApplied: Bool {
        configuration?.regulations?.contains(Constants.CCPACA) == true
    }

    public override func consentChanged(_ consentStatus: KetchSDK.ConsentStatus) {
        let encodedString = encode(with: consentStatus, notice: notice, lspa: lspa)

        save(encodedString, forKey: USPrivacy_String_Key)
        save(true , forKey: USPrivacy_Applied_Key)
    }

    public func encode(
        with consent: KetchSDK.ConsentStatus,
        notice: Bool,
        lspa: Bool
    ) -> CCPA_String {
        let defaultResult = "\(Constants.API_VERSION)---"

        guard
            let canonicalPurposes = configuration?.canonicalPurposes,
            canonicalPurposes.isEmpty == false
        else {
            print("Configuration.canonicalPurposes is nil or empty")
            return defaultResult
        }

        let noticeYesNo = notice ? "Y" : "N"

        let analyticsPurposeCodes = canonicalPurposes[Constants.ANALYTICS]?.purposeCodes
        let behavioralAdvertisingPurposeCodes = canonicalPurposes[Constants.BEHAVIORAL_ADVERTISING]?.purposeCodes
        let dataBrokingPurposeCodes = canonicalPurposes[Constants.DATA_BROKING]?.purposeCodes

        let analyticsOptOut = analyticsPurposeCodes?.compactMap { consent.purposes[$0] } ?? []
        let behavioralAdvertisingOptOut = behavioralAdvertisingPurposeCodes?.compactMap { consent.purposes[$0] } ?? []
        let dataBrokingOptOut = dataBrokingPurposeCodes?.compactMap { consent.purposes[$0] } ?? []

        let analyticsEnabled = analyticsPurposeCodes?.count == analyticsOptOut.count
        let behavioralAdvertisingEnabled = behavioralAdvertisingPurposeCodes?.count == behavioralAdvertisingOptOut.count
        let dataBrokingEnabled = dataBrokingPurposeCodes?.count == dataBrokingOptOut.count

        let optedOut = analyticsEnabled && behavioralAdvertisingEnabled && dataBrokingEnabled ? "Y" : "N"

        // we expect the user to set the LSPA variable on their page if they are using that framework for CCPA compliance
        let lspaYesNo = lspa ? "Y" : "N"

        // return uspString
        // v = version (int)
        // n = Notice Given (char)
        // o = OptedOut (char)
        // l = Lspact (char)
        return "\(Constants.API_VERSION)\(noticeYesNo)\(optedOut)\(lspaYesNo)"
    }
}

extension CCPA {
    private enum Constants {
        static let CCPACA = "ccpaca"
        static let API_VERSION = "1"
        static let ANALYTICS = "analytics"
        static let BEHAVIORAL_ADVERTISING = "behavioral_advertising"
        static let DATA_BROKING = "data_broking"
    }
}
