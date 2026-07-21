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

    func testFormatLanguageTag_underscoreSeparator_becomesHyphenWithUppercaseDialect() {
        XCTAssertEqual(KetchSDK.FullConfigurationRequest.formatLanguageTag("fr_CA"), "fr-CA")
    }

    func testFormatLanguageTag_lowercaseDialect_isUppercased() {
        XCTAssertEqual(KetchSDK.FullConfigurationRequest.formatLanguageTag("fr-ca"), "fr-CA")
    }

    func testFormatLanguageTag_rootOnly_isLowercased() {
        XCTAssertEqual(KetchSDK.FullConfigurationRequest.formatLanguageTag("EN"), "en")
    }

    func testFormatLanguageTag_blank_fallsBackToEnglish() {
        XCTAssertEqual(KetchSDK.FullConfigurationRequest.formatLanguageTag(""), "en")
    }

    func testConfigQueryItems_allPresent_onlyIncludesHash() {
        let request = KetchSDK.FullConfigurationRequest(
            organizationCode: "acme",
            propertyCode: "prop",
            environmentCode: "production",
            jurisdictionCode: "us-ca",
            languageCode: "en-US",
            hash: "abc123"
        )
        XCTAssertEqual(request.configQueryItems(deviceLanguage: { "fr-CA" }), [URLQueryItem(name: "hash", value: "abc123")])
    }

    func testConfigQueryItems_allPresent_noHash_isEmpty() {
        let request = KetchSDK.FullConfigurationRequest(
            organizationCode: "acme",
            propertyCode: "prop",
            environmentCode: "production",
            jurisdictionCode: "us-ca",
            languageCode: "en-US"
        )
        XCTAssertEqual(request.configQueryItems(deviceLanguage: { "fr-CA" }), [])
    }

    func testConfigQueryItems_nothingSet_defaultsLanguageFromDevice() {
        let request = KetchSDK.FullConfigurationRequest(organizationCode: "acme", propertyCode: "prop")
        XCTAssertEqual(request.configQueryItems(deviceLanguage: { "fr-CA" }), [URLQueryItem(name: "language", value: "fr-CA")])
    }

    func testConfigQueryItems_explicitLanguage_winsOverDeviceLocale() {
        let request = KetchSDK.FullConfigurationRequest(
            organizationCode: "acme",
            propertyCode: "prop",
            languageCode: "de-DE"
        )
        XCTAssertEqual(request.configQueryItems(deviceLanguage: { "fr-CA" }), [URLQueryItem(name: "language", value: "de-DE")])
    }

    func testConfigQueryItems_jurisdictionOnly_includesJurisdictionAndDefaultedLanguage() {
        let request = KetchSDK.FullConfigurationRequest(
            organizationCode: "acme",
            propertyCode: "prop",
            jurisdictionCode: "us-ca"
        )
        XCTAssertEqual(
            request.configQueryItems(deviceLanguage: { "fr-CA" }),
            [URLQueryItem(name: "language", value: "fr-CA"), URLQueryItem(name: "jurisdiction", value: "us-ca")]
        )
    }

    func testConfigQueryItems_regionOnly_includesRegionAndDefaultedLanguage() {
        let request = KetchSDK.FullConfigurationRequest(
            organizationCode: "acme",
            propertyCode: "prop",
            regionCode: "US-CA"
        )
        XCTAssertEqual(
            request.configQueryItems(deviceLanguage: { "fr-CA" }),
            [URLQueryItem(name: "language", value: "fr-CA"), URLQueryItem(name: "region", value: "US-CA")]
        )
    }

    func testConfigQueryItems_blankFieldsTreatedAsAbsent() {
        let request = KetchSDK.FullConfigurationRequest(
            organizationCode: "acme",
            propertyCode: "prop",
            jurisdictionCode: "",
            hash: "",
            regionCode: ""
        )
        XCTAssertEqual(request.configQueryItems(deviceLanguage: { "fr-CA" }), [URLQueryItem(name: "language", value: "fr-CA")])
    }
}
