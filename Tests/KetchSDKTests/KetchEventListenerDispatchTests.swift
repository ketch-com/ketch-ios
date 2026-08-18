import XCTest
@testable import KetchSDK

final class KetchEventListenerDispatchTests: XCTestCase {

    /// `KetchUI` stores its listener as `KetchEventListener?` and calls
    /// `onNativeStoragePut` through that existential. A member declared only in a
    /// protocol extension dispatches statically there, so the empty default body runs
    /// and the conformer's implementation is skipped without any compiler diagnostic.
    /// Calling through the existential — rather than through `SpyEventListener` — is
    /// what makes this test able to catch that.
    func testNativeStoragePutReachesConformerThroughExistential() {
        let spy = SpyEventListener()
        let listener: KetchEventListener? = spy

        listener?.onNativeStoragePut(key: "IABTCF_TCString", value: "CPabc123")

        XCTAssertEqual(spy.nativeStoragePuts.count, 1)
        XCTAssertEqual(spy.nativeStoragePuts.first?.key, "IABTCF_TCString")
        XCTAssertEqual(spy.nativeStoragePuts.first?.value, "CPabc123")
    }

    /// The extension default keeps `onNativeStoragePut` optional for conformers.
    /// `MinimalEventListener` omits it, so this file failing to compile is the
    /// assertion; the call confirms the default is reachable and inert at runtime.
    func testConformerOmittingNativeStoragePutStillCompilesAndNoOps() {
        let listener: KetchEventListener? = MinimalEventListener()

        listener?.onNativeStoragePut(key: "key", value: "value")
    }
}

// MARK: - Test doubles

private final class SpyEventListener: KetchEventListener {
    private(set) var nativeStoragePuts: [(key: String, value: String)] = []

    func onNativeStoragePut(key: String, value: String) {
        nativeStoragePuts.append((key: key, value: value))
    }

    func onShow() { }
    func onWillShowExperience(type: KetchSDK.WillShowExperienceType) { }
    func onHasShownExperience() { }
    func onDismiss(status: KetchSDK.HideExperienceStatus) { }
    func onEnvironmentUpdated(environment: String?) { }
    func onRegionInfoUpdated(regionInfo: String?) { }
    func onJurisdictionUpdated(jurisdiction: String?) { }
    func onIdentitiesUpdated(identities: String?) { }
    func onConsentUpdated(consent: KetchSDK.ConsentStatus) { }
    func onError(description: String) { }
    func onCCPAUpdated(ccpaString: String?) { }
    func onTCFUpdated(tcfString: String?) { }
    func onGPPUpdated(gppString: String?) { }
}

/// Deliberately does not implement `onNativeStoragePut`.
private final class MinimalEventListener: KetchEventListener {
    func onShow() { }
    func onWillShowExperience(type: KetchSDK.WillShowExperienceType) { }
    func onHasShownExperience() { }
    func onDismiss(status: KetchSDK.HideExperienceStatus) { }
    func onEnvironmentUpdated(environment: String?) { }
    func onRegionInfoUpdated(regionInfo: String?) { }
    func onJurisdictionUpdated(jurisdiction: String?) { }
    func onIdentitiesUpdated(identities: String?) { }
    func onConsentUpdated(consent: KetchSDK.ConsentStatus) { }
    func onError(description: String) { }
    func onCCPAUpdated(ccpaString: String?) { }
    func onTCFUpdated(tcfString: String?) { }
    func onGPPUpdated(gppString: String?) { }
}
