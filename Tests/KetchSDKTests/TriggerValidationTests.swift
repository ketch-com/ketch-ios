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

    // MARK: - Named trigger script

    func testTriggerScript_namedTrigger_encodesNameAsJSONStringWithOptions() {
        let optionsJson = KetchUI.jsonString(from: ["tab": "rightsTab"])

        let script = KetchUI.WebPresentationItem.triggerScript(triggerName: "dnsOpened", functionName: nil, optionsJson: optionsJson)

        XCTAssertEqual(script, #"ketch('trigger', "dnsOpened", {"tab":"rightsTab"})"#)
    }

    func testTriggerScript_namedTrigger_escapesQuotesInName() {
        let script = KetchUI.WebPresentationItem.triggerScript(triggerName: #"a"); x('"#, functionName: nil, optionsJson: "{}")

        XCTAssertEqual(script, #"ketch('trigger', "a\"); x('", {})"#)
    }

    func testTriggerScript_customTrigger_keepsFunctionNameForm() {
        let script = KetchUI.WebPresentationItem.triggerScript(triggerName: "custom", functionName: "managePrivacy", optionsJson: #"{"a":1}"#)

        XCTAssertEqual(script, #"ketch('trigger', 'custom', 'managePrivacy', {"a":1})"#)
    }

    func testValidTriggerName_acceptsTagTriggerNames() {
        XCTAssertTrue(KetchUI.isValidTriggerName("privacyPreferenceUnknown"))
        XCTAssertTrue(KetchUI.isValidTriggerName("preferencesOpened"))
        XCTAssertTrue(KetchUI.isValidTriggerName("dnsOpened"))
        XCTAssertTrue(KetchUI.isValidTriggerName("future_trigger-2"))
    }

    func testInvalidTriggerName_rejectsEmptyLeadingNonLetterAndScriptCharacters() {
        XCTAssertFalse(KetchUI.isValidTriggerName(""))
        XCTAssertFalse(KetchUI.isValidTriggerName("1dnsOpened"))
        XCTAssertFalse(KetchUI.isValidTriggerName("dns.opened"))
        XCTAssertFalse(KetchUI.isValidTriggerName("dnsOpened'); alert(1); //"))
        XCTAssertFalse(KetchUI.isValidTriggerName("dns\nOpened"))
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

    func testNamedTrigger_beforeTagBoots_queuesWithoutFunctionName() {
        let ketchUI = makeKetchUI()

        let accepted = ketchUI.trigger("dnsOpened", options: ["tab": "rightsTab"])

        XCTAssertTrue(accepted)
        XCTAssertEqual(ketchUI.pendingTrigger?.triggerName, "dnsOpened")
        XCTAssertNil(ketchUI.pendingTrigger?.functionName)
        XCTAssertEqual(ketchUI.pendingTrigger?.optionsJson, #"{"tab":"rightsTab"}"#)
    }

    func testNamedTrigger_afterTagBoots_firesImmediatelyWithoutQueueing() {
        let ketchUI = makeKetchUI()
        ketchUI.handle(webPresentationEvent: .configurationLoaded(emptyConfiguration))

        let accepted = ketchUI.trigger("preferencesOpened")

        XCTAssertTrue(accepted)
        XCTAssertNil(ketchUI.pendingTrigger)
    }

    func testNamedTrigger_rejectsCustom() {
        let ketchUI = makeKetchUI()

        XCTAssertFalse(ketchUI.trigger("custom"))
        XCTAssertNil(ketchUI.pendingTrigger)
    }

    func testNamedTrigger_rejectsHostileName() {
        let ketchUI = makeKetchUI()

        XCTAssertFalse(ketchUI.trigger("dnsOpened'); alert(1); //"))
        XCTAssertFalse(ketchUI.trigger(#"dnsOpened", {}); alert(1); //"#))
        XCTAssertNil(ketchUI.pendingTrigger)
    }

    func testCustomTrigger_queuesWithFunctionName() {
        let ketchUI = makeKetchUI()

        _ = ketchUI.trigger(triggerName: .custom, functionName: "testFn")

        XCTAssertEqual(ketchUI.pendingTrigger?.triggerName, "custom")
        XCTAssertEqual(ketchUI.pendingTrigger?.functionName, "testFn")
        XCTAssertEqual(ketchUI.pendingTrigger?.optionsJson, "{}")
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
