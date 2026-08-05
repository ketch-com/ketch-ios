import XCTest
@testable import KetchSDK

final class PolicyPluginDispatchTests: XCTestCase {

    func testWillShowExperienceReachesRegisteredPlugin() {
        let ketch = Ketch(organizationCode: "acme", propertyCode: "prop", environmentCode: "production", identities: [])
        let plugin = SpyPolicyPlugin()
        ketch.add(plugin: plugin)

        ketch.notifyWillShowExperience()

        XCTAssertEqual(plugin.willShowExperienceCount, 1)
    }

    func testExperienceHiddenReachesRegisteredPluginWithMappedReason() {
        let ketch = Ketch(organizationCode: "acme", propertyCode: "prop", environmentCode: "production", identities: [])
        let plugin = SpyPolicyPlugin()
        ketch.add(plugin: plugin)

        ketch.notifyExperienceHidden(status: .Close)

        XCTAssertEqual(plugin.hiddenReasons, [.close])
    }

    func testExperienceHiddenReasonMapsEveryHideExperienceStatus() {
        let ketch = Ketch(organizationCode: "acme", propertyCode: "prop", environmentCode: "production", identities: [])
        let plugin = SpyPolicyPlugin()
        ketch.add(plugin: plugin)

        let statuses: [KetchSDK.HideExperienceStatus] = [
            .SetConsent, .InvokeRight, .Close, .WillNotShow,
            .CloseWithoutSettingConsent, .SetSubscriptions, .None
        ]
        statuses.forEach { ketch.notifyExperienceHidden(status: $0) }

        XCTAssertEqual(plugin.hiddenReasons, [
            .setConsent, .invokeRight, .close, .willNotShow,
            .closeWithoutSettingConsent, .setSubscriptions, .none
        ])
    }
}

// MARK: - Test doubles

private final class SpyPolicyPlugin: PolicyPlugin {
    override var protocolID: String { "spy-policy-plugin" }
    override var isApplied: Bool { true }

    private(set) var willShowExperienceCount = 0
    private(set) var hiddenReasons: [ExperienceHiddenReason] = []

    override func willShowExperience() {
        willShowExperienceCount += 1
    }

    override func experienceHidden(reason: ExperienceHiddenReason) {
        hiddenReasons.append(reason)
    }
}
