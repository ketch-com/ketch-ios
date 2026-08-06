import Combine
import XCTest
@testable import KetchSDK

final class HeadlessConsentTests: XCTestCase {
    private var cancellables: Set<AnyCancellable> = []

    override func tearDown() {
        cancellables.removeAll()
        super.tearDown()
    }
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

    func testFetchConsentPropagatesHTTPFailure() {
        let client = HeadlessApiClient(dataCenter: .us, apiClient: StubApiClient { _ in
            Fail(error: .unknownError).eraseToAnyPublisher()
        })

        let expectation = expectation(description: "getConsent failure")
        client.getConsent(config: sampleConsentConfig())
            .sink(
                receiveCompletion: { completion in
                    if case .failure = completion {
                        expectation.fulfill()
                    } else {
                        XCTFail("Expected getConsent to fail on HTTP 500")
                    }
                },
                receiveValue: { _ in
                    XCTFail("Expected no value on HTTP 500")
                }
            )
            .store(in: &cancellables)
        wait(for: [expectation], timeout: 5)
    }

    func testSetConsentPropagatesNetworkFailure() {
        let client = HeadlessApiClient(dataCenter: .us, apiClient: StubApiClient { _ in
            Fail(error: .unknownError).eraseToAnyPublisher()
        })

        let expectation = expectation(description: "setConsent failure")
        client.setConsent(update: sampleConsentUpdate())
            .sink(
                receiveCompletion: { completion in
                    if case .failure = completion {
                        expectation.fulfill()
                    } else {
                        XCTFail("Expected setConsent to fail on network error")
                    }
                },
                receiveValue: { _ in
                    XCTFail("Expected no value on network error")
                }
            )
            .store(in: &cancellables)
        wait(for: [expectation], timeout: 5)
    }

    func testSetConsentAcceptsProtocolsOnlyResponse() throws {
        let body = """
        {"protocols":{"gpp":"DBABLA~BVQqAAAAAAJY.QA"}}
        """
        let client = HeadlessApiClient(dataCenter: .us, apiClient: StubApiClient { _ in
            Just(Data(body.utf8)).setFailureType(to: ApiClientError.self).eraseToAnyPublisher()
        })

        let expectation = expectation(description: "setConsent protocols")
        client.setConsent(update: sampleConsentUpdate())
            .sink(
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        XCTFail("setConsent failed: \(error)")
                    }
                    expectation.fulfill()
                },
                receiveValue: { status in
                    XCTAssertNil(status.purposes)
                    XCTAssertEqual(status.protocols?["gpp"], "DBABLA~BVQqAAAAAAJY.QA")
                }
            )
            .store(in: &cancellables)
        wait(for: [expectation], timeout: 5)
    }

    func testSetConsentFallsBackToCallerProtocolsWhenResponseOmitsThem() throws {
        let body = """
        {"purposes":{"analytics":true}}
        """
        let client = HeadlessApiClient(dataCenter: .us, apiClient: StubApiClient { _ in
            Just(Data(body.utf8)).setFailureType(to: ApiClientError.self).eraseToAnyPublisher()
        })

        var update = sampleConsentUpdate()
        update = .init(
            organizationCode: update.organizationCode,
            propertyCode: update.propertyCode,
            environmentCode: update.environmentCode,
            identities: update.identities,
            jurisdictionCode: update.jurisdictionCode,
            migrationOption: update.migrationOption,
            purposes: update.purposes,
            vendors: update.vendors,
            protocols: ["gpp": "DBABLA~BVQqAAAAAAJY.QA"]
        )

        let expectation = expectation(description: "setConsent caller protocols")
        client.setConsent(update: update)
            .sink(
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        XCTFail("setConsent failed: \(error)")
                    }
                    expectation.fulfill()
                },
                receiveValue: { status in
                    XCTAssertEqual(status.purposes?["analytics"], true)
                    XCTAssertEqual(status.protocols?["gpp"], "DBABLA~BVQqAAAAAAJY.QA")
                }
            )
            .store(in: &cancellables)
        wait(for: [expectation], timeout: 5)
    }

    func testFetchConsentAcceptsVendorsOnlyResponse() throws {
        let body = """
        {"vendors":["google","meta"]}
        """
        let client = HeadlessApiClient(dataCenter: .us, apiClient: StubApiClient { _ in
            Just(Data(body.utf8)).setFailureType(to: ApiClientError.self).eraseToAnyPublisher()
        })

        let expectation = expectation(description: "getConsent vendors")
        client.getConsent(config: sampleConsentConfig())
            .sink(
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        XCTFail("getConsent failed: \(error)")
                    }
                    expectation.fulfill()
                },
                receiveValue: { status in
                    XCTAssertNil(status.purposes)
                    XCTAssertEqual(status.vendors, ["google", "meta"])
                    XCTAssertNil(status.protocols)
                }
            )
            .store(in: &cancellables)
        wait(for: [expectation], timeout: 5)
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

// MARK: - Consent HTTP stubs

private final class StubApiClient: ApiClient {
    private let handler: (ApiRequest) -> AnyPublisher<Data, ApiClientError>

    init(handler: @escaping (ApiRequest) -> AnyPublisher<Data, ApiClientError>) {
        self.handler = handler
    }

    func execute(request: ApiRequest) -> AnyPublisher<Data, ApiClientError> {
        handler(request)
    }
}

private func sampleConsentConfig() -> KetchSDK.ConsentConfig {
    .init(
        organizationCode: "org",
        propertyCode: "prop",
        environmentCode: "production",
        jurisdictionCode: "default",
        identities: ["email": "user@example.com"],
        purposes: ["analytics": .init(legalBasisCode: "consent_optin")]
    )
}

private func sampleConsentUpdate() -> KetchSDK.ConsentUpdate {
    .init(
        organizationCode: "org",
        propertyCode: "prop",
        environmentCode: "production",
        identities: ["email": "user@example.com"],
        jurisdictionCode: "default",
        migrationOption: .migrateDefault,
        purposes: ["analytics": .init(allowed: true, legalBasisCode: "consent_optin")],
        vendors: nil,
        protocols: nil
    )
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
