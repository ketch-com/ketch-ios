//
//  PolicyProtocol.swift
//  KetchSDK
//

import Foundation

public protocol PolicyProtocol {
    var protocolID: String { get }
    var isApplied: Bool { get }

    func configLoaded(_ configuration: KetchSDK.Configuration)
    func consentChanged(_ consentStatus: KetchSDK.ConsentStatus)
    func willShowExperience()
    func experienceHidden(reason: ExperienceHiddenReason)
    func rightInvoked(
        controller: String?,
        property: String,
        environment: String,
        invokedAt: Int?,
        identities: [String: String],
        right: String?,
        user: KetchSDK.InvokeRightConfig.User
    )
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
    public var protocolID: String {
        fatalError("protocolID is not implemented")
    }

    public var isApplied: Bool {
        fatalError("isApplied is not implemented")
    }

    var configuration: KetchSDK.Configuration?

    let userDefaults: UserDefaults

    public init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }

    func save(_ value: Any?, forKey key: String) {
        userDefaults.set(value, forKey: key)
    }

    func getValue(withKey key: String) -> Any? {
        userDefaults.value(forKey: key)
    }

    // MARK: - PolicyProtocol
    public func configLoaded(_ configuration: KetchSDK.Configuration) {
        self.configuration = configuration
    }

    public func consentChanged(_ consentStatus: KetchSDK.ConsentStatus) { }

    public func willShowExperience() { }

    public func experienceHidden(reason: ExperienceHiddenReason) { }

    public func rightInvoked(
        controller: String?,
        property: String,
        environment: String,
        invokedAt: Int?,
        identities: [String: String],
        right: String?,
        user: KetchSDK.InvokeRightConfig.User
    ) { }
}

extension PolicyPlugin: Hashable {
    public static func == (lhs: PolicyPlugin, rhs: PolicyPlugin) -> Bool {
        lhs.hashValue == rhs.hashValue
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(protocolID)
    }
}
