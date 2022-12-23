//
//  PolicyProtocol.swift
//  KetchSDK
//

import Foundation

/// Protocol of PolicyPlugin. Can be consumed and run by Ketch instance.
public protocol PolicyProtocol {
    /// Any unique protocol Id in consumed list.
    var protocolID: String { get }

    /// Indicates in this protocol applies with current config.
    var isApplied: Bool { get }

    // MARK: - Protocol lifecycle events
    /// Triggers on any config change
    func configLoaded(_ configuration: KetchSDK.Configuration)

    /// Triggers on any consent change
    func consentChanged(_ consentStatus: KetchSDK.ConsentStatus)

    /// Indicates event when initiated experience presentation defined in config
    func willShowExperience()

    /// Indicates event when stopped experience presentation defined in config
    func experienceHidden(reason: ExperienceHiddenReason)

    /// Indicates event user initiated rights invocation
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

/// PolicyPlugin base class
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
