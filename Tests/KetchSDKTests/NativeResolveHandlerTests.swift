//
//  NativeResolveHandlerTests.swift
//  KetchSDKTests
//

import XCTest
@testable import KetchSDK

final class NativeResolveHandlerTests: XCTestCase {
    func testWellFormedBodyReturnsKey() {
        XCTAssertEqual(parseNativeResolveKey(from: ["key": "swb_x"]), "swb_x")
    }

    func testExtraFieldsAreIgnored() {
        XCTAssertEqual(parseNativeResolveKey(from: ["key": "swb_x", "extra": "ignored"]), "swb_x")
    }

    func testKeyIsTrimmed() {
        XCTAssertEqual(parseNativeResolveKey(from: ["key": "  swb_x  "]), "swb_x")
    }

    func testNonObjectBodyReturnsNil() {
        XCTAssertNil(parseNativeResolveKey(from: "swb_x"))
        XCTAssertNil(parseNativeResolveKey(from: 42))
        XCTAssertNil(parseNativeResolveKey(from: ["swb_x"]))
        XCTAssertNil(parseNativeResolveKey(from: NSNull()))
    }

    func testMissingKeyReturnsNil() {
        XCTAssertNil(parseNativeResolveKey(from: ["notKey": "swb_x"]))
    }

    func testNonStringKeyReturnsNil() {
        XCTAssertNil(parseNativeResolveKey(from: ["key": 42]))
    }

    func testEmptyKeyReturnsNil() {
        XCTAssertNil(parseNativeResolveKey(from: ["key": ""]))
    }

    func testWhitespaceOnlyKeyReturnsNil() {
        XCTAssertNil(parseNativeResolveKey(from: ["key": "   "]))
    }
}

final class ResolveNativeValueTests: XCTestCase {
    private var userDefaults: UserDefaults!
    private var suiteName: String!

    override func setUp() {
        super.setUp()
        suiteName = "ResolveNativeValueTests.\(UUID().uuidString)"
        userDefaults = UserDefaults(suiteName: suiteName)!
    }

    override func tearDown() {
        if let suiteName {
            userDefaults.removePersistentDomain(forName: suiteName)
        }
        userDefaults = nil
        suiteName = nil
        super.tearDown()
    }

    func testIDFVPresentReturnsVendorIdentifier() {
        let storage = NativeStorage(userDefaults: userDefaults)
        let value = resolveNativeValue(key: "ketch_idfv", nativeStorage: storage, identifierForVendor: { "ABC-123" })
        XCTAssertEqual(value, "ABC-123")
    }

    func testIDFVNilBeforeFirstUnlockReturnsNil() {
        let storage = NativeStorage(userDefaults: userDefaults)
        let value = resolveNativeValue(key: "ketch_idfv", nativeStorage: storage, identifierForVendor: { nil })
        XCTAssertNil(value)
    }

    func testOrdinaryKeyFallsThroughToStorageUnchanged() {
        userDefaults.set("stored-value", forKey: "swb_x")
        let storage = NativeStorage(userDefaults: userDefaults)
        let value = resolveNativeValue(key: "swb_x", nativeStorage: storage, identifierForVendor: { "should not be consulted" })
        XCTAssertEqual(value, "stored-value")
    }
}
