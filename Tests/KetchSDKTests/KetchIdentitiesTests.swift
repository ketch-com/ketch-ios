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

    func testGetIdentitiesMergesInAResolvedIdentity() {
        let ketch = makeKetch(identities: [Ketch.Identity(key: "email", value: "test@example.com")])
        ketch.recordIdentityResolveAttempt(key: "swb_acme", value: "resolved-value")

        let identities = Dictionary(uniqueKeysWithValues: ketch.getIdentities().map { ($0.key, $0.value) })

        XCTAssertEqual(identities["email"], "test@example.com")
        XCTAssertEqual(identities["swb_acme"], "resolved-value")
    }

    func testResolvedValueWinsOnKeyCollision() {
        let ketch = makeKetch(identities: [Ketch.Identity(key: "swb_acme", value: "stale-app-supplied")])
        ketch.recordIdentityResolveAttempt(key: "swb_acme", value: "resolved-value")

        let identities = Dictionary(uniqueKeysWithValues: ketch.getIdentities().map { ($0.key, $0.value) })

        XCTAssertEqual(identities["swb_acme"], "resolved-value")
    }

    func testResolveAttemptWithNoValueFoundDoesNotAddAnIdentity() {
        let ketch = makeKetch()
        ketch.recordIdentityResolveAttempt(key: "swb_acme", value: nil)
        XCTAssertEqual(ketch.getIdentities(), [])
    }

    func testPutForAKeyNeverAskedAboutIsIgnored() {
        // Mirrors ketch-react-native's identityKeysRef guard: nativeStoragePut also carries
        // unrelated tag writes (consent version, IAB privacy strings), so a put for a key that
        // was never the subject of a resolve must not be treated as an identity.
        let ketch = makeKetch()
        ketch.recordIdentityPut(key: "consent_version", value: "3")
        XCTAssertEqual(ketch.getIdentities(), [])
    }

    func testPutForAPreviouslyResolvedKeyIsRecorded() {
        // The mint path: a resolve finds nothing, the tag mints, then nativeStoragePut arrives
        // for that same key.
        let ketch = makeKetch()
        ketch.recordIdentityResolveAttempt(key: "swb_acme", value: nil)
        ketch.recordIdentityPut(key: "swb_acme", value: "minted-value")

        let identities = Dictionary(uniqueKeysWithValues: ketch.getIdentities().map { ($0.key, $0.value) })
        XCTAssertEqual(identities["swb_acme"], "minted-value")
    }

    func testClearIdentitiesRemovesResolvedIdentitiesFromMemoryAndStorage() {
        let storage = NativeStorage(userDefaults: userDefaults)
        storage.write(key: "swb_acme", value: "resolved-value")
        let ketch = makeKetch()
        ketch.recordIdentityResolveAttempt(key: "swb_acme", value: "resolved-value")

        ketch.clearIdentities()

        XCTAssertEqual(ketch.getIdentities(), [])
        XCTAssertNil(storage.readIfPresent(key: "swb_acme"))
    }

    func testClearIdentitiesLeavesAppSuppliedIdentitiesUntouched() {
        let ketch = makeKetch(identities: [Ketch.Identity(key: "email", value: "test@example.com")])
        ketch.recordIdentityResolveAttempt(key: "swb_acme", value: "resolved-value")

        ketch.clearIdentities()

        XCTAssertEqual(ketch.getIdentities().map(\.key), ["email"])
    }
}

extension Ketch.Identity: Equatable {
    public static func == (lhs: Ketch.Identity, rhs: Ketch.Identity) -> Bool {
        lhs.key == rhs.key && lhs.value == rhs.value
    }
}
