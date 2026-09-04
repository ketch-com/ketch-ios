//
//  KetchIdentitiesTests.swift
//  KetchSDKTests
//

import XCTest
@testable import KetchSDK

final class KetchIdentitiesTests: XCTestCase {
    private var userDefaults: UserDefaults!
    private var suiteName: String!

    override func setUp() {
        super.setUp()
        suiteName = "KetchIdentitiesTests.\(UUID().uuidString)"
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

    private func makeKetch(identities: [Ketch.Identity] = []) -> Ketch {
        Ketch(
            organizationCode: "acme",
            propertyCode: "prop",
            environmentCode: "production",
            identities: identities,
            userDefaults: userDefaults
        )
    }

    func testConstructorSuppliedIdentitiesAreReadable() {
        let ketch = makeKetch(identities: [Ketch.Identity(key: "email", value: "test@example.com")])
        XCTAssertEqual(ketch.getIdentities().map(\.key), ["email"])
    }

    func testSetIdentitiesReplacesThePreviousArray() {
        let ketch = makeKetch(identities: [Ketch.Identity(key: "email", value: "test@example.com")])
        ketch.setIdentities([Ketch.Identity(key: "phone", value: "555-0100")])
        XCTAssertEqual(ketch.getIdentities().map(\.key), ["phone"])
    }

    func testGetIdentitiesMergesInTheManagedIdentityFromStorage() {
        NativeStorage(userDefaults: userDefaults).write(key: "swb_acme", value: "minted-value")
        let ketch = makeKetch(identities: [Ketch.Identity(key: "email", value: "test@example.com")])

        let identities = Dictionary(uniqueKeysWithValues: ketch.getIdentities().map { ($0.key, $0.value) })

        XCTAssertEqual(identities["email"], "test@example.com")
        XCTAssertEqual(identities["swb_acme"], "minted-value")
    }

    func testGetIdentitiesManagedValueWinsOnKeyCollision() {
        NativeStorage(userDefaults: userDefaults).write(key: "swb_acme", value: "from-storage")
        let ketch = makeKetch(identities: [Ketch.Identity(key: "swb_acme", value: "stale-app-supplied")])

        let identities = Dictionary(uniqueKeysWithValues: ketch.getIdentities().map { ($0.key, $0.value) })

        XCTAssertEqual(identities["swb_acme"], "from-storage")
    }

    func testClearIdentitiesRemovesTheManagedIdentityFromStorage() {
        NativeStorage(userDefaults: userDefaults).write(key: "swb_acme", value: "minted-value")
        let ketch = makeKetch()

        ketch.clearIdentities()

        XCTAssertNil(NativeStorage(userDefaults: userDefaults).readIfPresent(key: "swb_acme"))
    }

    func testClearIdentitiesLeavesAppSuppliedIdentitiesUntouched() {
        let ketch = makeKetch(identities: [Ketch.Identity(key: "email", value: "test@example.com")])

        ketch.clearIdentities()

        XCTAssertEqual(ketch.getIdentities().map(\.key), ["email"])
    }
}

extension Ketch.Identity: Equatable {
    public static func == (lhs: Ketch.Identity, rhs: Ketch.Identity) -> Bool {
        lhs.key == rhs.key && lhs.value == rhs.value
    }
}
