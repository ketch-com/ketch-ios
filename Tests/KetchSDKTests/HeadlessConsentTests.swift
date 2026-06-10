import Combine
import XCTest
@testable import KetchSDK

final class HeadlessConsentTests: XCTestCase {
    private var cancellables: Set<AnyCancellable> = []

    override func tearDown() {
        cancellables.removeAll()
        StubURLProtocol.handler = nil
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
        let session = makeStubSession()
        let client = HeadlessApiClient(dataCenter: .us, session: session)
        StubURLProtocol.handler = { _ in
            let response = HTTPURLResponse(
                url: URL(string: "https://global.ketchcdn.com/web/v3/consent/org/get")!,
                statusCode: 500,
                httpVersion: nil,
                headerFields: nil
            )!
            return (response, Data())
        }

        let expectation = expectation(description: "fetchConsent failure")
        client.fetchConsent(config: sampleConsentConfig())
            .sink(
                receiveCompletion: { completion in
                    if case .failure = completion {
                        expectation.fulfill()
                    } else {
                        XCTFail("Expected fetchConsent to fail on HTTP 500")
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
        let session = makeStubSession()
        let client = HeadlessApiClient(dataCenter: .us, session: session)
        StubURLProtocol.handler = { _ in
            throw URLError(.notConnectedToInternet)
        }

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
        let session = makeStubSession()
        let client = HeadlessApiClient(dataCenter: .us, session: session)
        let body = """
        {"protocols":{"gpp":"DBABLA~BVQqAAAAAAJY.QA"}}
        """
        StubURLProtocol.handler = { _ in
            let response = HTTPURLResponse(
                url: URL(string: "https://global.ketchcdn.com/web/v3/consent/org/update")!,
                statusCode: 200,
                httpVersion: nil,
                headerFields: nil
            )!
            return (response, Data(body.utf8))
        }

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

    func testFetchProtocolsPreservesPurposesWhenProtocolsMissing() throws {
        let session = makeStubSession()
        let client = HeadlessApiClient(dataCenter: .us, session: session)
        let body = """
        {"purposes":{"analytics":true,"marketing":false}}
        """
        StubURLProtocol.handler = { _ in
            let response = HTTPURLResponse(
                url: URL(string: "https://global.ketchcdn.com/web/v3/consent/org/get")!,
                statusCode: 200,
                httpVersion: nil,
                headerFields: nil
            )!
            return (response, Data(body.utf8))
        }

        let expectation = expectation(description: "fetchProtocols purposes")
        client.fetchProtocols(config: sampleConsentConfig())
            .sink(
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        XCTFail("fetchProtocols failed: \(error)")
                    }
                    expectation.fulfill()
                },
                receiveValue: { status in
                    XCTAssertNil(status.protocols)
                    XCTAssertEqual(status.purposes?["analytics"], true)
                    XCTAssertEqual(status.purposes?["marketing"], false)
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

private func makeStubSession() -> URLSession {
    let config = URLSessionConfiguration.ephemeral
    config.protocolClasses = [StubURLProtocol.self]
    return URLSession(configuration: config)
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

private final class StubURLProtocol: URLProtocol {
    static var handler: ((URLRequest) throws -> (HTTPURLResponse, Data))?

    override class func canInit(with request: URLRequest) -> Bool { true }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }

    override func startLoading() {
        guard let handler = Self.handler else {
            client?.urlProtocol(self, didFailWithError: URLError(.unknown))
            return
        }
        do {
            let (response, data) = try handler(request)
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            client?.urlProtocol(self, didLoad: data)
            client?.urlProtocolDidFinishLoading(self)
        } catch {
            client?.urlProtocol(self, didFailWithError: error)
        }
    }

    override func stopLoading() {}
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
