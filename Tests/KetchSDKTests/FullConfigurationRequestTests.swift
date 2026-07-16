import XCTest
@testable import KetchSDK

final class FullConfigurationRequestTests: XCTestCase {
    func testConfigPathSegment_allPresentAndNonBlank_returnsSegment() {
        let request = KetchSDK.FullConfigurationRequest(
            organizationCode: "acme",
            propertyCode: "prop",
            environmentCode: "production",
            jurisdictionCode: "us-ca",
            languageCode: "en-US"
        )
        let segment = request.configPathSegment()
        XCTAssertEqual(segment?.env, "production")
        XCTAssertEqual(segment?.jurisdiction, "us-ca")
        XCTAssertEqual(segment?.language, "en-US")
    }

    func testConfigPathSegment_nilField_returnsNil() {
        let request = KetchSDK.FullConfigurationRequest(
            organizationCode: "acme",
            propertyCode: "prop",
            environmentCode: nil,
            jurisdictionCode: "us-ca",
            languageCode: "en-US"
        )
        XCTAssertNil(request.configPathSegment())
    }

    func testConfigPathSegment_blankField_treatedAsAbsent() {
        let request = KetchSDK.FullConfigurationRequest(
            organizationCode: "acme",
            propertyCode: "prop",
            environmentCode: "",
            jurisdictionCode: "us-ca",
            languageCode: "en-US"
        )
        XCTAssertNil(request.configPathSegment(), "A blank environmentCode must be treated the same as nil")
    }

    func testConfigPathSegment_blankJurisdiction_treatedAsAbsent() {
        let request = KetchSDK.FullConfigurationRequest(
            organizationCode: "acme",
            propertyCode: "prop",
            environmentCode: "production",
            jurisdictionCode: "",
            languageCode: "en-US"
        )
        XCTAssertNil(request.configPathSegment())
    }

    func testConfigPathSegment_blankLanguage_treatedAsAbsent() {
        let request = KetchSDK.FullConfigurationRequest(
            organizationCode: "acme",
            propertyCode: "prop",
            environmentCode: "production",
            jurisdictionCode: "us-ca",
            languageCode: ""
        )
        XCTAssertNil(request.configPathSegment())
    }

    func testNormalizedHash_present_returnsHash() {
        let request = KetchSDK.FullConfigurationRequest(
            organizationCode: "acme",
            propertyCode: "prop",
            hash: "123"
        )
        XCTAssertEqual(request.normalizedHash(), "123")
    }

    func testNormalizedHash_nil_returnsNil() {
        let request = KetchSDK.FullConfigurationRequest(organizationCode: "acme", propertyCode: "prop")
        XCTAssertNil(request.normalizedHash())
    }

    func testNormalizedHash_blank_treatedAsAbsent() {
        let request = KetchSDK.FullConfigurationRequest(
            organizationCode: "acme",
            propertyCode: "prop",
            hash: ""
        )
        XCTAssertNil(request.normalizedHash())
    }
}
