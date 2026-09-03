import XCTest
@testable import KetchSDK

/// Covers the document URL handed to WebKit. The origin must never be `file:` — a `file:` document
/// has an opaque origin that serializes as `null`, which breaks reCAPTCHA's postMessage handshake.
final class WebConfigDocumentURLTests: XCTestCase {
    private func makeConfig(
        params: [String: String] = [:],
        identities: [Ketch.Identity] = []
    ) -> WebConfig {
        var config = WebConfig(
            orgCode: "testorg",
            propertyName: "testproperty",
            environmentCode: "production",
            identities: identities
        )
        config.params = params
        return config
    }

    /// Query item order comes from a Dictionary and is not stable, so assert on parsed pairs
    /// rather than on the URL string.
    private func queryPairs(_ url: URL) -> [String: String] {
        let items = URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems ?? []
        return items.reduce(into: [String: String]()) { $0[$1.name] = $1.value }
    }

    func testDocumentURL_usesHTTPLocalhostNotFile() throws {
        let url = try XCTUnwrap(makeConfig().documentURL)

        XCTAssertEqual(url.scheme, "http")
        XCTAssertEqual(url.host, "localhost")
        XCTAssertNotEqual(url.scheme, "file")
    }

    func testDocumentURL_pathMatchesBundledHTMLFileName() throws {
        let url = try XCTUnwrap(makeConfig().documentURL)

        XCTAssertEqual(url.path, "/index.html")
    }

    func testDocumentURL_carriesRequiredQueryItems() throws {
        let url = try XCTUnwrap(makeConfig().documentURL)
        let pairs = queryPairs(url)

        XCTAssertEqual(pairs["propertyName"], "testproperty")
        XCTAssertEqual(pairs["orgCode"], "testorg")
        XCTAssertEqual(pairs["ketch_env"], "production")
        XCTAssertEqual(pairs["isMobileSdk"], "true")
    }

    func testDocumentURL_omitsCSSAndResourceOverrideParams() throws {
        let config = makeConfig(params: [
            "ketch_css_inject": "body { color: red; }",
            "ketch_web_resource_overrides": #"{"/a.js":"http://localhost:9000/a.js"}"#
        ])
        let pairs = queryPairs(try XCTUnwrap(config.documentURL))

        XCTAssertNil(pairs["ketch_css_inject"])
        XCTAssertNil(pairs["ketch_web_resource_overrides"])
    }

    func testDocumentURL_lowercasesKetchLang() throws {
        let config = makeConfig(params: ["ketch_lang": "EN-US"])
        let pairs = queryPairs(try XCTUnwrap(config.documentURL))

        XCTAssertEqual(pairs["ketch_lang"], "en-us")
    }

    func testDocumentURL_includesAdvertisingIdentifiers() throws {
        let config = makeConfig(identities: [
            Ketch.Identity(key: "idfa", value: "abc-123")
        ])
        let pairs = queryPairs(try XCTUnwrap(config.documentURL))

        XCTAssertEqual(pairs["idfa"], "abc-123")
    }

    func testDocumentURL_passesThroughArbitraryParams() throws {
        let config = makeConfig(params: ["ketch_att": "authorized"])
        let pairs = queryPairs(try XCTUnwrap(config.documentURL))

        XCTAssertEqual(pairs["ketch_att"], "authorized")
    }

    func testDocumentURL_isNotNilWithEmptyValues() throws {
        var config = WebConfig(
            orgCode: "",
            propertyName: "",
            environmentCode: "",
            identities: []
        )
        config.params = ["": ""]

        XCTAssertNotNil(config.documentURL)
    }
}
