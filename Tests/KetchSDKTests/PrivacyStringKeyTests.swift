//
//  PrivacyStringKeyTests.swift
//  KetchSDKTests
//

import XCTest
@testable import KetchSDK

/// The tag writes these exact keys, and the Android and Flutter SDKs read the same
/// names. A rename here silently breaks every consumer reading the strings back.
final class PrivacyStringKeyTests: XCTestCase {
    func testKeysMatchIABSpecification() {
        XCTAssertEqual(Ketch.PrivacyStringKey.tcfTCString, "IABTCF_TCString")
        XCTAssertEqual(Ketch.PrivacyStringKey.usPrivacyString, "IABUSPrivacy_String")
        XCTAssertEqual(Ketch.PrivacyStringKey.gppHDRGppString, "IABGPP_HDR_GppString")
    }
}
