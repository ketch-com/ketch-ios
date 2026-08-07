import XCTest
@testable import KetchSDK

final class TriggerValidationTests: XCTestCase {
    func testValidFunctionName_lettersDigitsUnderscoreDotDash() {
        XCTAssertTrue(KetchUI.isValidTriggerFunctionName("myFunction_1.name-2"))
    }

    func testValidFunctionName_singleCharacter() {
        XCTAssertTrue(KetchUI.isValidTriggerFunctionName("a"))
    }

    func testInvalidFunctionName_empty() {
        XCTAssertFalse(KetchUI.isValidTriggerFunctionName(""))
    }

    func testInvalidFunctionName_blankWhitespace() {
        XCTAssertFalse(KetchUI.isValidTriggerFunctionName(" "))
    }

    func testInvalidFunctionName_containsSpace() {
        XCTAssertFalse(KetchUI.isValidTriggerFunctionName("my function"))
    }

    func testInvalidFunctionName_containsSpecialCharacter() {
        XCTAssertFalse(KetchUI.isValidTriggerFunctionName("my/function"))
        XCTAssertFalse(KetchUI.isValidTriggerFunctionName("my'function"))
        XCTAssertFalse(KetchUI.isValidTriggerFunctionName("<script>"))
    }

    func testTriggerNameRawValue_customMatchesJSShape() {
        XCTAssertEqual(TriggerName.custom.rawValue, "custom")
    }

    // MARK: - Trigger state machine
    //
    // These drive KetchUI's private bridge-event handler directly, since there is no seam for
    // injecting a fake WebPresentationItem to exercise the real .configurationLoaded flow.

    private func makeKetchUI() -> KetchUI {
        let ketch = Ketch(organizationCode: "acme", propertyCode: "prop", environmentCode: "production", identities: [])
        return KetchUI(ketch: ketch)
    }

    private let emptyConfiguration = KetchSDK.Configuration(
        experiences: nil,
        theme: nil,
        rights: nil,
        jurisdiction: nil,
        purposes: nil
    )

    func testTrigger_beforeTagBoots_queuesRatherThanFiring() {
        let ketchUI = makeKetchUI()
        XCTAssertFalse(ketchUI.isTagBooted)

        let accepted = ketchUI.trigger(triggerName: .custom, functionName: "testFn")

        XCTAssertTrue(accepted)
        XCTAssertNotNil(ketchUI.pendingTrigger)
    }

    func testTrigger_afterTagBoots_firesImmediatelyWithoutQueueing() {
        let ketchUI = makeKetchUI()
        ketchUI.handle(webPresentationEvent: .configurationLoaded(emptyConfiguration))
        XCTAssertTrue(ketchUI.isTagBooted)

        let accepted = ketchUI.trigger(triggerName: .custom, functionName: "testFn")

        XCTAssertTrue(accepted)
        XCTAssertNil(ketchUI.pendingTrigger)
    }

    func testConfigurationLoaded_drainsAPreviouslyQueuedTrigger() {
        let ketchUI = makeKetchUI()
        _ = ketchUI.trigger(triggerName: .custom, functionName: "testFn")
        XCTAssertNotNil(ketchUI.pendingTrigger)

        ketchUI.handle(webPresentationEvent: .configurationLoaded(emptyConfiguration))

        XCTAssertNil(ketchUI.pendingTrigger)
    }

    func testConfigurationLoaded_deferredShow_leavesTagBootedTrue() {
        // Regression test: a deferred first show used to reset isTagBooted (then isConfigLoaded)
        // back to false, so every later trigger() queued forever and never fired.
        let ketchUI = makeKetchUI()
        ketchUI.showConsent() // defers, since the tag hasn't booted yet

        ketchUI.handle(webPresentationEvent: .configurationLoaded(emptyConfiguration))

        XCTAssertTrue(ketchUI.isTagBooted)
    }

    func testReload_resetsTagBootedState() {
        let ketchUI = makeKetchUI()
        ketchUI.handle(webPresentationEvent: .configurationLoaded(emptyConfiguration))
        XCTAssertTrue(ketchUI.isTagBooted)

        ketchUI.reload()

        XCTAssertFalse(
            ketchUI.isTagBooted,
            "a trigger() issued during the reload window must take the cold path, not evaluate JS against a page that hasn't loaded yet"
        )
    }

    func testReload_preservesAPendingTrigger() {
        let ketchUI = makeKetchUI()
        _ = ketchUI.trigger(triggerName: .custom, functionName: "testFn")
        XCTAssertNotNil(ketchUI.pendingTrigger)

        ketchUI.reload()

        XCTAssertNotNil(
            ketchUI.pendingTrigger,
            "the caller was already told trigger() returned true; a reload must not silently discard it"
        )
    }
}
