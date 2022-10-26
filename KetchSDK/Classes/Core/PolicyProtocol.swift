//
//  PolicyProtocol.swift
//  KetchSDK
//
//  Created by Anton Lyfar on 26.10.2022.
//

import Foundation

public protocol PolicyProtocol {
    func consentChanged(consent: KetchSDK.ConsentStatus)
    func willShowExperience()
    func experienceHidden(reason: ExperienceHiddenReason)
}

public enum ExperienceHiddenReason: String {
  case setConsent
  case invokeRight
  case close
  case willNotShow
}

public enum PolicyPluginError: Error {
    case notApplicableToConfig
}

open class PolicyPlugin: PolicyProtocol {

    let configuration: KetchSDK.Configuration

    let userDefaults: UserDefaults

    init(
        with configuration: KetchSDK.Configuration,
        userDefaults: UserDefaults = .standard
    ) throws {
        self.configuration = configuration
        self.userDefaults = userDefaults
    }

    func save(_ value: Any?, forKey key: String) {
        userDefaults.set(value, forKey: key)
    }

    func getValue(withKey key: String) -> Any? {
        userDefaults.value(forKey: key)
    }

// MARK: - PolicyProtocol
    public func consentChanged(consent: KetchSDK.ConsentStatus) { }

    public func willShowExperience() { }

    public func experienceHidden(reason: ExperienceHiddenReason) { }

}
