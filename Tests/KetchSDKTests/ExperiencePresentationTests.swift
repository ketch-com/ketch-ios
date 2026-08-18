import XCTest
@testable import KetchSDK

/// Covers the paths that show and tear down an experience. These drive KetchUI's bridge-event
/// handler directly, since there is no seam for injecting a fake WebPresentationItem.
final class ExperiencePresentationTests: XCTestCase {

    private var ketch: Ketch!
    private var ketchUI: KetchUI!
    private var listener: SpyEventListener!

    override func setUp() {
        super.setUp()
        ketch = Ketch(organizationCode: "acme", propertyCode: "prop", environmentCode: "production", identities: [])
        ketchUI = KetchUI(ketch: ketch)
        listener = SpyEventListener()
        ketchUI.eventListener = listener
    }

    override func tearDown() {
        ketchUI = nil
        ketch = nil
        listener = nil
        super.tearDown()
    }

    private let emptyConfiguration = KetchSDK.Configuration(
        experiences: nil,
        theme: nil,
        rights: nil,
        jurisdiction: nil,
        purposes: nil
    )

    private func bootTag() {
        ketchUI.handle(webPresentationEvent: .configurationLoaded(emptyConfiguration))
    }

    // MARK: - Teardown parity

    func testCloseExperience_notifiesListenerAndPlugin() {
        let plugin = SpyHidePlugin()
        ketch.add(plugin: plugin)
        bootTag()
        ketchUI.handle(webPresentationEvent: .show(.consent))
        XCTAssertNotNil(ketchUI.webPresentationItem)

        ketchUI.closeExperience()

        XCTAssertNil(ketchUI.webPresentationItem)
        XCTAssertEqual(listener.dismissCount, 1, "programmatic close must fire the same hide lifecycle as a web-driven close")
        XCTAssertEqual(plugin.hiddenReasons, [.none])
    }

    func testCloseExperience_whenNothingShowing_isANoOp() {
        bootTag()

        ketchUI.closeExperience()

        XCTAssertEqual(listener.dismissCount, 0, "closing nothing must not fabricate a dismiss event")
    }

    func testReload_whileExperienceShowing_tearsItDownRatherThanStrandingIt() {
        bootTag()
        ketchUI.handle(webPresentationEvent: .show(.consent))
        XCTAssertNotNil(ketchUI.webPresentationItem)

        ketchUI.reload()

        XCTAssertNil(
            ketchUI.webPresentationItem,
            "reload removes the page's script handlers, so no .onClose can arrive for a stranded experience"
        )
        XCTAssertTrue(
            ketchUI.trigger(triggerName: .custom, functionName: "testFn"),
            "a stranded experience would latch the trigger guard permanently"
        )
    }
}

// MARK: - Test doubles

private final class SpyHidePlugin: PolicyPlugin {
    override var protocolID: String { "spy-hide-plugin" }
    override var isApplied: Bool { true }

    private(set) var hiddenReasons: [ExperienceHiddenReason] = []

    override func experienceHidden(reason: ExperienceHiddenReason) {
        hiddenReasons.append(reason)
    }
}

private final class SpyEventListener: KetchEventListener {
    private(set) var onShowCount = 0
    private(set) var dismissCount = 0

    func onShow() { onShowCount += 1 }
    func onDismiss(status: KetchSDK.HideExperienceStatus) { dismissCount += 1 }

    func onWillShowExperience(type: KetchSDK.WillShowExperienceType) {}
    func onHasShownExperience() {}
    func onEnvironmentUpdated(environment: String?) {}
    func onRegionInfoUpdated(regionInfo: String?) {}
    func onJurisdictionUpdated(jurisdiction: String?) {}
    func onIdentitiesUpdated(identities: String?) {}
    func onConsentUpdated(consent: KetchSDK.ConsentStatus) {}
    func onError(description: String) {}
    func onCCPAUpdated(ccpaString: String?) {}
    func onTCFUpdated(tcfString: String?) {}
    func onGPPUpdated(gppString: String?) {}
}
