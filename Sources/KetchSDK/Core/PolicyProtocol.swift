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
  case closeWithoutSettingConsent
  case setSubscriptions
  case none

  init(status: KetchSDK.HideExperienceStatus) {
    switch status {
    case .SetConsent: self = .setConsent
    case .InvokeRight: self = .invokeRight
    case .Close: self = .close
    case .WillNotShow: self = .willNotShow
    case .CloseWithoutSettingConsent: self = .closeWithoutSettingConsent
    case .SetSubscriptions: self = .setSubscriptions
    case .None: self = .none
    }
  }
}

public enum PolicyPluginError: Error {
    case notApplicableToConfig
}

/// PolicyPlugin base class
open class PolicyPlugin: PolicyProtocol {
    open var protocolID: String {
        fatalError("protocolID is not implemented")
    }

    open var isApplied: Bool {
        fatalError("isApplied is not implemented")
    }

    var configuration: KetchSDK.Configuration?

    let userDefaults: UserDefaults
    private let nativeStorage: NativeStorage

    public init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
        self.nativeStorage = NativeStorage(userDefaults: userDefaults)
    }

    func save(_ value: Any?, forKey key: String) {
        nativeStorage.set(value, forKey: key)
    }

    func getValue(withKey key: String) -> Any? {
        nativeStorage.value(forKey: key)
    }

    // MARK: - PolicyProtocol
    open func configLoaded(_ configuration: KetchSDK.Configuration) {
        self.configuration = configuration
    }

    open func consentChanged(_ consentStatus: KetchSDK.ConsentStatus) { }

    open func willShowExperience() { }

    open func experienceHidden(reason: ExperienceHiddenReason) { }

    open func rightInvoked(
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
