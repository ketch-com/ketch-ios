import XCTest
@testable import KetchSDK

final class HeadlessConsentTests: XCTestCase {
    func testSetConsentPayloadOmitsProtocols() throws {
        let update = KetchSDK.ConsentUpdate(
            organizationCode: "org",
            propertyCode: "prop",
            environmentCode: "production",
            identities: ["id": "1"],
            jurisdictionCode: "default",
            migrationOption: .migrateDefault,
            purposes: [
                "analytics": .init(allowed: true, legalBasisCode: "consent_optin"),
            ],
            vendors: nil,
            protocols: ["gpp": "DBABLA~"]
        )
        let payload = SetConsentPayloadForTesting(update: update)
        let data = try JSONEncoder().encode(payload)
        let json = try XCTUnwrap(JSONSerialization.jsonObject(with: data) as? [String: Any])
        XCTAssertNil(json["protocols"])
        XCTAssertEqual(json["organizationCode"] as? String, "org")
    }

    func testConsentConfigPayloadOmitsCachedAt() throws {
        let config = KetchSDK.ConsentConfig(
            organizationCode: "org",
            propertyCode: "prop",
            environmentCode: "production",
            jurisdictionCode: "default",
            identities: [:],
            purposes: [:]
        )
        let payload = ConsentConfigPayloadForTesting(config: config)
        let data = try JSONEncoder().encode(payload)
        let json = try XCTUnwrap(JSONSerialization.jsonObject(with: data) as? [String: Any])
        XCTAssertNil(json["cachedAt"])
    }
}

/// Mirrors private `SetConsentPayload` in HeadlessApiClient for contract tests.
private struct SetConsentPayloadForTesting: Encodable {
    let organizationCode: String
    let propertyCode: String
    let environmentCode: String
    let identities: [String: String]
    let jurisdictionCode: String
    let migrationOption: KetchSDK.ConsentUpdate.MigrationOption
    let purposes: [String: KetchSDK.ConsentUpdate.PurposeAllowedLegalBasis]
    let vendors: [String]?

    init(update: KetchSDK.ConsentUpdate) {
        organizationCode = update.organizationCode
        propertyCode = update.propertyCode
        environmentCode = update.environmentCode
        identities = update.identities
        jurisdictionCode = update.jurisdictionCode
        migrationOption = update.migrationOption
        purposes = update.purposes
        vendors = update.vendors
    }
}

private struct ConsentConfigPayloadForTesting: Encodable {
    let organizationCode: String
    let propertyCode: String
    let environmentCode: String
    let jurisdictionCode: String
    let identities: [String: String]
    let purposes: [String: KetchSDK.ConsentConfig.PurposeLegalBasis]

    init(config: KetchSDK.ConsentConfig) {
        organizationCode = config.organizationCode
        propertyCode = config.propertyCode
        environmentCode = config.environmentCode
        jurisdictionCode = config.jurisdictionCode
        identities = config.identities
        purposes = config.purposes
    }
}
