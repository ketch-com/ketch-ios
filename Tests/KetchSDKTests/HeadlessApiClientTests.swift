import XCTest
@testable import KetchSDK

final class HeadlessApiClientTests: XCTestCase {
    private var client: HeadlessApiClient!

    override func setUp() {
        super.setUp()
        client = HeadlessApiClient(dataCenter: .us)
    }

    func testBuildURL_ip() {
        let url = client.buildURL(path: "/ip")
        XCTAssertEqual(url?.absoluteString, "https://global.ketchcdn.com/web/v3/ip")
    }

    func testBuildURL_bootstrap() {
        let url = client.buildURL(path: "/config/acme/prop/boot.json")
        XCTAssertEqual(
            url?.absoluteString,
            "https://global.ketchcdn.com/web/v3/config/acme/prop/boot.json"
        )
    }

    func testBuildURL_fullConfigurationWithHash() {
        let url = client.buildURL(
            path: "/config/acme/prop/prod/us-ca/en-US/config.json",
            queryItems: [URLQueryItem(name: "hash", value: "8913461971881236311")]
        )
        XCTAssertEqual(
            url?.absoluteString,
            "https://global.ketchcdn.com/web/v3/config/acme/prop/prod/us-ca/en-US/config.json?hash=8913461971881236311"
        )
    }

    func testBuildURL_euDataCenter() {
        let eu = HeadlessApiClient(dataCenter: .eu)
        let url = eu.buildURL(path: "/ip")
        XCTAssertEqual(url?.absoluteString, "https://eu.ketchcdn.com/web/v3/ip")
    }

    func testPreferenceQRUrl_matchesContractFixture() {
        let url = client.preferenceQRUrl(
            request: .init(
                organizationCode: "switchbitcorp",
                propertyCode: "switchbit",
                environmentCode: "production",
                imageSize: 1024,
                path: "/policy.html",
                backgroundColor: "white",
                foregroundColor: "black",
                parameters: ["foo": "bar"]
            )
        )
        XCTAssertEqual(
            url?.absoluteString,
            "https://global.ketchcdn.com/web/v3/qr/switchbitcorp/switchbit/preferences.png?env=production&size=1024&path=%2Fpolicy.html&bgcolor=white&fgcolor=black&foo=bar"
        )
    }

    func testBuildURL_rightsProfileSubscriptions() {
        let invoke = client.buildURL(path: "/rights/switchbitcorp/invoke")
        XCTAssertEqual(
            invoke?.absoluteString,
            "https://global.ketchcdn.com/web/v3/rights/switchbitcorp/invoke"
        )
        let profile = client.buildURL(path: "/profile/acme/get")
        XCTAssertEqual(
            profile?.absoluteString,
            "https://global.ketchcdn.com/web/v3/profile/acme/get"
        )
        let subs = client.buildURL(path: "/subscriptions/acme/update")
        XCTAssertEqual(
            subs?.absoluteString,
            "https://global.ketchcdn.com/web/v3/subscriptions/acme/update"
        )
    }

    func testKetchDataCenterBaseURLs() {
        XCTAssertEqual(KetchDataCenter.us.baseURL.absoluteString, "https://global.ketchcdn.com/web/v3")
        XCTAssertEqual(KetchDataCenter.eu.baseURL.absoluteString, "https://eu.ketchcdn.com/web/v3")
        XCTAssertEqual(KetchDataCenter.uat.baseURL.absoluteString, "https://dev.ketchcdn.com/web/v3")
    }
}
