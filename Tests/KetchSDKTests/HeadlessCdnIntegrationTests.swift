import Combine
import XCTest
@testable import KetchSDK

/// Live CDN headless round-trip tests (web/v3, sandbox org).
///
/// Run with network enabled:
/// `KETCH_INTEGRATION_TESTS=1 xcodebuild -scheme KetchSDK -destination 'platform=iOS Simulator,name=iPhone 17' test -only-testing:KetchSDKTests/HeadlessCdnIntegrationTests`
final class HeadlessCdnIntegrationTests: XCTestCase {
    private var client: HeadlessApiClient!
    private var cancellables: Set<AnyCancellable> = []

    override func setUp() {
        super.setUp()
        try? XCTSkipUnless(
            ProcessInfo.processInfo.environment["KETCH_INTEGRATION_TESTS"] == "1",
            "Set KETCH_INTEGRATION_TESTS=1 to run live CDN tests"
        )
        client = HeadlessApiClient(dataCenter: .us)
        cancellables = []
    }

    override func tearDown() {
        cancellables.removeAll()
        super.tearDown()
    }

    func testFetchLocationReturnsGeoIP() {
        let expectation = expectation(description: "fetchLocation")
        client.fetchLocation()
            .sink(
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        XCTFail("fetchLocation failed: \(error)")
                    }
                    expectation.fulfill()
                },
                receiveValue: { response in
                    XCTAssertFalse(response.location?.countryCode?.isEmpty ?? true)
                }
            )
            .store(in: &cancellables)
        wait(for: [expectation], timeout: 45)
    }

    func testFetchBootstrapConfiguration() {
        let expectation = expectation(description: "fetchBootstrapConfiguration")
        client.fetchBootstrapConfiguration(
            organization: HeadlessIntegrationSupport.orgCode,
            property: HeadlessIntegrationSupport.propertyCode
        )
        .sink(
            receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    XCTFail("fetchBootstrapConfiguration failed: \(error)")
                }
                expectation.fulfill()
            },
            receiveValue: { boot in
                let hasMetadata = boot.experiences != nil
                    || boot.jurisdiction != nil
                    || !(boot.purposes?.isEmpty ?? true)
                XCTAssertTrue(hasMetadata, "Bootstrap should include experiences metadata")
            }
        )
        .store(in: &cancellables)
        wait(for: [expectation], timeout: 45)
    }

    func testHeadlessColdStartConsentRoundTrip() {
        let identities = HeadlessIntegrationSupport.uniqueEmailIdentity()
        let expectation = expectation(description: "coldStart")

        client.fetchBootstrapConfiguration(
            organization: HeadlessIntegrationSupport.orgCode,
            property: HeadlessIntegrationSupport.propertyCode
        )
        .flatMap { _ in
            self.client.fetchFullConfiguration(
                request: .init(
                    organizationCode: HeadlessIntegrationSupport.orgCode,
                    propertyCode: HeadlessIntegrationSupport.propertyCode
                )
            )
        }
        .map { full in
            HeadlessIntegrationSupport.consentConfigFrom(
                configuration: full,
                identities: identities
            )
        }
        .flatMap { config in
            self.client.fetchConsent(config: config)
        }
        .sink(
            receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    XCTFail("cold start failed: \(error)")
                }
                expectation.fulfill()
            },
            receiveValue: { consent in
                let hasProtocols = !(consent.protocols?.isEmpty ?? true)
                let hasPurposes = !(consent.purposes?.isEmpty ?? true)
                XCTAssertTrue(hasProtocols || hasPurposes, "Expected protocols and/or purposes from CDN")
            }
        )
        .store(in: &cancellables)

        wait(for: [expectation], timeout: 60)
    }
}
