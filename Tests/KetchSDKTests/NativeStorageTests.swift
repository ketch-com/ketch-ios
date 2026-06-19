//
//  NativeStorageTests.swift
//  KetchSDKTests
//

import XCTest
@testable import KetchSDK

final class NativeStorageTests: XCTestCase {
    private var userDefaults: UserDefaults!
    private var suiteName: String!

    override func setUp() {
        super.setUp()
        suiteName = "NativeStorageTests.\(UUID().uuidString)"
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

    func testReadReturnsDefaultWhenKeyMissing() {
        let storage = NativeStorage(userDefaults: userDefaults)
        XCTAssertEqual(storage.read(key: "missing", defaultValue: "notDetermined"), "notDetermined")
    }

    func testWriteAndReadRoundTrip() {
        let storage = NativeStorage(userDefaults: userDefaults)
        storage.write(key: "sample_key", value: "sample_value")
        XCTAssertEqual(storage.read(key: "sample_key", defaultValue: ""), "sample_value")
    }

    func testSetAndValueRoundTripForInt() {
        let storage = NativeStorage(userDefaults: userDefaults)
        storage.set(42, forKey: "consent_version")
        XCTAssertEqual(storage.value(forKey: "consent_version") as? Int, 42)
    }

    func testSetNilRemovesValue() {
        let storage = NativeStorage(userDefaults: userDefaults)
        storage.set(7, forKey: "some_key")
        storage.set(nil, forKey: "some_key")
        XCTAssertNil(storage.value(forKey: "some_key"))
    }

    func testRemoveObjectDeletesKey() {
        let storage = NativeStorage(userDefaults: userDefaults)
        storage.write(key: "to_remove", value: "bye")
        storage.removeObject(forKey: "to_remove")
        XCTAssertEqual(storage.read(key: "to_remove", defaultValue: "gone"), "gone")
    }

    func testRemoveValuesWithPrefixesOnlyRemovesMatching() {
        let storage = NativeStorage(userDefaults: userDefaults)
        storage.write(key: "IABTCF_TCString", value: "abc")
        storage.write(key: "IABGPP_HDR_Version", value: "1")
        storage.write(key: "keep_me", value: "safe")

        let removed = storage.removeValues(withPrefixes: ["IABTCF", "IABGPP", "IABUS"])

        XCTAssertEqual(removed, 2)
        XCTAssertEqual(storage.read(key: "IABTCF_TCString", defaultValue: "missing"), "missing")
        XCTAssertEqual(storage.read(key: "IABGPP_HDR_Version", defaultValue: "missing"), "missing")
        XCTAssertEqual(storage.read(key: "keep_me", defaultValue: "missing"), "safe")
    }
}
