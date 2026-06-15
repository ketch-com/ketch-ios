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
        storage.write(key: NativeStorage.ketchAttLastKey, value: "denied")
        XCTAssertEqual(storage.read(key: NativeStorage.ketchAttLastKey, defaultValue: "notDetermined"), "denied")
    }
}
