//
//  PolicyProtocol.swift
//  KetchSDK
//
//  Created by Anton Lyfar on 25.10.2022.
//

import Foundation

public protocol PolicyProtocol {
    static func isApplicable(for configuration: KetchSDK.Configuration) -> Bool
}

public typealias CCPA_String = String

public enum CCPA {
    public static func encode(
        with configuration: KetchSDK.Configuration,
        consent: KetchSDK.ConsentStatus,
        notice: Bool,
        lspa: Bool
    ) -> CCPA_String {
        let defaultResult = "\(Constants.API_VERSION)---"

        guard isApplicable(for: configuration) else {
            print("CCPA is not applied")
            return defaultResult
        }

        guard
            let canonicalPurposes = configuration.canonicalPurposes,
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

extension CCPA: PolicyProtocol {
    public static func isApplicable(for configuration: KetchSDK.Configuration) -> Bool {
        configuration.regulations?.contains(Constants.CCPACA) == true
    }
}
