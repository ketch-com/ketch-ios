import Combine
import XCTest
@testable import KetchSDK

/// Live CDN round-trip for the ported getRegion/getJurisdiction/trigger surface (sandbox org).
///
/// Run with network enabled:
/// `KETCH_INTEGRATION_TESTS=1 xcodebuild -scheme KetchSDK -destination 'platform=iOS Simulator,name=iPhone 17' test -only-testing:KetchSDKTests/KetchHeadlessLiveIntegrationTests`
final class KetchHeadlessLiveIntegrationTests: XCTestCase {
    private var cancellables: Set<AnyCancellable> = []

    override func setUpWithError() throws {
        try super.setUpWithError()
        try XCTSkipUnless(
            ProcessInfo.processInfo.environment["KETCH_INTEGRATION_TESTS"] == "1",
            "Set KETCH_INTEGRATION_TESTS=1 to run live CDN tests"
        )
        cancellables = []
    }

    override func tearDown() {
        cancellables.removeAll()
        super.tearDown()
    }

    private func makeKetch() -> Ketch {
        Ketch(
            organizationCode: HeadlessIntegrationSupport.orgCode,
            propertyCode: HeadlessIntegrationSupport.propertyCode,
            environmentCode: HeadlessIntegrationSupport.environmentCode,
            identities: []
        )
    }

    func testGetRegion_liveCDN_returnsRealValue() {
        let ketch = makeKetch()
        let expectation = expectation(description: "getRegion")
        ketch.getRegion { result in
            switch result {
            case .success(let region):
                XCTAssertFalse(region?.isEmpty ?? true, "Expected a non-empty region code from live GeoIP")
            case .failure(let error):
                XCTFail("getRegion failed: \(error)")
            }
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 45)
    }

    func testGetRegion_liveCDN_secondCallServedFromCache() {
        let ketch = makeKetch()
        let first = expectation(description: "first getRegion")
        var firstRegion: String?
        ketch.getRegion { result in
            firstRegion = try? result.get()
            first.fulfill()
        }
        wait(for: [first], timeout: 45)

        // A second call immediately after should return the same cached value without erroring.
        let second = expectation(description: "second getRegion")
        ketch.getRegion { result in
            XCTAssertEqual(try? result.get(), firstRegion)
            second.fulfill()
        }
        wait(for: [second], timeout: 5)
    }

    func testGetJurisdiction_liveCDN_returnsRealValue() {
        let ketch = makeKetch()
        let expectation = expectation(description: "getJurisdiction")
        ketch.getJurisdiction { result in
            switch result {
            case .success(let jurisdiction):
                XCTAssertFalse(jurisdiction?.isEmpty ?? true, "Expected a non-empty jurisdiction code from live config")
            case .failure(let error):
                XCTFail("getJurisdiction failed: \(error)")
            }
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 45)
    }

    func testStaticGetRegion_liveCDN_returnsRealValue() {
        let expectation = expectation(description: "static getRegion")
        KetchSDK.getRegion()
            .sink { completion in
                if case .failure(let error) = completion { XCTFail("static getRegion failed: \(error)") }
                expectation.fulfill()
            } receiveValue: { region in
                XCTAssertFalse(region?.isEmpty ?? true, "Expected a non-empty region code from live GeoIP")
            }
            .store(in: &cancellables)
        wait(for: [expectation], timeout: 45)
    }

    func testStaticGetJurisdiction_liveCDN_returnsRealValue() {
        let expectation = expectation(description: "static getJurisdiction")
        let request = KetchSDK.FullConfigurationRequest(
            organizationCode: HeadlessIntegrationSupport.orgCode,
            propertyCode: HeadlessIntegrationSupport.propertyCode,
            environmentCode: HeadlessIntegrationSupport.environmentCode
        )
        KetchSDK.getJurisdiction(request: request)
            .sink { completion in
                if case .failure(let error) = completion { XCTFail("static getJurisdiction failed: \(error)") }
                expectation.fulfill()
            } receiveValue: { jurisdiction in
                XCTAssertFalse(jurisdiction?.isEmpty ?? true, "Expected a non-empty jurisdiction code from live config")
            }
            .store(in: &cancellables)
        wait(for: [expectation], timeout: 45)
    }

    /// Drives a real WKWebView against the live CDN. Confirms the cold path (called before config
    /// loads, deferred) and the warm path (called after config loads, fires immediately) both
    /// return `true` and neither crashes nor throws at the Swift/JS bridge. This does not assert an
    /// experience actually appeared — that requires a backend onFunction rule for the given
    /// function name configured on the sandbox org, which is outside this test's control.
    func testTrigger_liveCDN_coldThenWarmPath() {
        let ketch = makeKetch()
        let ketchUI = KetchUI(ketch: ketch)

        // Cold path: fired immediately after init, before the tag has had a chance to boot.
        let coldAccepted = ketchUI.trigger(triggerName: .custom, functionName: "smokeTestColdTrigger")
        XCTAssertTrue(coldAccepted, "Cold trigger() should be accepted (deferred) even before config loads")

        let configLoaded = expectation(description: "configuration loaded")
        ketchUI.$configuration
            .compactMap { $0 }
            .first()
            .sink { _ in configLoaded.fulfill() }
            .store(in: &cancellables)
        wait(for: [configLoaded], timeout: 45)

        // Warm path: config is now loaded, so this should fire immediately via evaluateJavaScript.
        let warmAccepted = ketchUI.trigger(triggerName: .custom, functionName: "smokeTestWarmTrigger")
        XCTAssertTrue(warmAccepted, "Warm trigger() should be accepted once config has loaded")
    }

    func testTrigger_liveCDN_rejectsInvalidFunctionName() {
        let ketch = makeKetch()
        let ketchUI = KetchUI(ketch: ketch)
        XCTAssertFalse(ketchUI.trigger(triggerName: .custom, functionName: ""))
        XCTAssertFalse(ketchUI.trigger(triggerName: .custom, functionName: "has space"))
    }
}
