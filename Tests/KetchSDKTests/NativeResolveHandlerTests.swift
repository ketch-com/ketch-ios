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
