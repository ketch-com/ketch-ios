import XCTest
@testable import KetchSDK

/// The server sends `purposes` in three different shapes depending on the endpoint. Payloads here
/// are verbatim captures.
final class ConsentPurposeDecodingTests: XCTestCase {

    private func decode(_ json: String) throws -> KetchSDK.ConsentStatus {
        try JSONDecoder().decode(KetchSDK.ConsentStatus.self, from: Data(json.utf8))
    }

    func testDecodesStringifiedBools_stringified() throws {
        let status = try decode("""
        {"purposes":{"analytics_900":"false","targeted_advertising":"true"},"protocols":{"usps":"1---"}}
        """)

        XCTAssertEqual(status.purposes, ["analytics_900": false, "targeted_advertising": true])
        XCTAssertEqual(status.protocols, ["usps": "1---"])
    }

    func testDecodesObjectsCarryingAllowed_wrappedInObject() throws {
        let status = try decode("""
        {"protocols":{},"purposes":{
          "analytics_900":{"allowed":"false","collectedAt":0,"legalBasisCode":"consent_optout"},
          "targeted_advertising":{"allowed":"true","collectedAt":0,"legalBasisCode":"consent_optout"}
        }}
        """)

        XCTAssertEqual(status.purposes, ["analytics_900": false, "targeted_advertising": true])
    }

    func testDecodesNativeBools() throws {
        let status = try decode(#"{"purposes":{"analytics_900":true}}"#)

        XCTAssertEqual(status.purposes, ["analytics_900": true])
    }

    func testAbsentPurposesStaysNil() throws {
        let status = try decode(#"{"protocols":{"usps":"1---"}}"#)

        XCTAssertNil(status.purposes)
    }

    /// An unrecognized value is false rather than an error, and must not take the rest of the
    /// map down with it.
    func testUnrecognizedPurposeValueIsFalseAndKeepsTheMap() throws {
        let status = try decode(#"{"purposes":{"analytics_900":"yes","targeted_advertising":"true"}}"#)

        XCTAssertEqual(status.purposes, ["analytics_900": false, "targeted_advertising": true])
    }

    func testVendorsAndProtocolsStillDecode() throws {
        let status = try decode("""
        {"purposes":{"a":"true"},"vendors":["v1","v2"],"protocols":{"gpp":"DBABL~"}}
        """)

        XCTAssertEqual(status.vendors, ["v1", "v2"])
        XCTAssertEqual(status.protocols, ["gpp": "DBABL~"])
    }
}
