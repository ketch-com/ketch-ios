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

    override init(
        with configuration: KetchSDK.Configuration,
        userDefaults: UserDefaults = .standard
    ) throws {
        guard configuration.regulations?.contains(Constants.GDPREU) == true else {
            throw PolicyPluginError.notApplicableToConfig
        }

        try super.init(with: configuration, userDefaults: userDefaults)
    }

    public override func consentChanged(consent: KetchSDK.ConsentStatus) {
        let encodedString = ""

        save(encodedString, forKey: TCF_TCString_Key)
        save(true , forKey: TCF_gdprApplies_Key)
    }

    public func encode(
        with consent: KetchSDK.ConsentStatus,
        notice: Bool,
        lspa: Bool
    ) -> TCF_String {
        String()
    }
}

extension TCF {
    private enum Constants {
        static let GDPREU = "gdpreu"
    }
}
