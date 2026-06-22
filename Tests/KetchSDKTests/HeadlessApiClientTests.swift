import Combine
import XCTest
@testable import KetchSDK

final class HeadlessApiClientTests: XCTestCase {
    private var client: HeadlessApiClient!
    private var cancellables = Set<AnyCancellable>()

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

    func testFetchConfig_includesPreferredLanguageQueryParam() throws {
        let preferredLanguage = Locale.preferredLanguages[0]
        var capturedURL: URL?
        let apiClient = CapturingApiClient { request in
            capturedURL = request.endPoint.url
            return Just(Data("{}".utf8))
                .setFailureType(to: ApiClientError.self)
                .eraseToAnyPublisher()
        }
        let client = HeadlessApiClient(dataCenter: .us, apiClient: apiClient)

        let expectation = expectation(description: "fetchConfig language query")
        client.fetchConfig(organization: "acme", property: "prop")
            .sink(
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        XCTFail("fetchConfig failed: \(error)")
                    }
                    expectation.fulfill()
                },
                receiveValue: { _ in }
            )
            .store(in: &cancellables)
        wait(for: [expectation], timeout: 5)

        let url = try XCTUnwrap(capturedURL)
        XCTAssertEqual(url.path, "/web/v3/config/acme/prop/config.json")
        XCTAssertEqual(
            URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems,
            [URLQueryItem(name: "language", value: preferredLanguage)]
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

// MARK: - Test doubles

private final class CapturingApiClient: ApiClient {
    private let handler: (ApiRequest) -> AnyPublisher<Data, ApiClientError>

    init(handler: @escaping (ApiRequest) -> AnyPublisher<Data, ApiClientError>) {
        self.handler = handler
    }

    func execute(request: ApiRequest) -> AnyPublisher<Data, ApiClientError> {
        handler(request)
    }
}
