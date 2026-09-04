//
//  KetchIdentitiesTests.swift
//  KetchSDKTests
//

import XCTest
@testable import KetchSDK

final class KetchIdentitiesTests: XCTestCase {
    private func makeKetch(identities: [Ketch.Identity] = []) -> Ketch {
        Ketch(organizationCode: "acme", propertyCode: "prop", environmentCode: "production", identities: identities)
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

    func testClearIdentitiesEmptiesTheArray() {
        let ketch = makeKetch(identities: [Ketch.Identity(key: "email", value: "test@example.com")])
        ketch.clearIdentities()
        XCTAssertEqual(ketch.getIdentities(), [])
    }
}

extension Ketch.Identity: Equatable {
    public static func == (lhs: Ketch.Identity, rhs: Ketch.Identity) -> Bool {
        lhs.key == rhs.key && lhs.value == rhs.value
    }
}
