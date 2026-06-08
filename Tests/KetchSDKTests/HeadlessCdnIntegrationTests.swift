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

    private let orgCode = "ketch_samples"
    private let propertyCode = "ios"
    private let environmentCode = "production"

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

    func testHeadlessColdStartConsentRoundTrip() {
        let identities = ["email": "headless-\(UUID().uuidString)@integration.ketch.test"]
        let expectation = expectation(description: "coldStart")
        var bootConfig: KetchSDK.Configuration?

        client.fetchBootstrapConfiguration(organization: orgCode, property: propertyCode)
            .flatMap { boot -> AnyPublisher<KetchSDK.Configuration, KetchSDK.KetchError> in
                bootConfig = boot
                return self.client.fetchFullConfiguration(
                    request: .init(
                        organizationCode: self.orgCode,
                        propertyCode: self.propertyCode
                    )
                )
            }
            .map { full in
                let purposes = full.purposes ?? bootConfig?.purposes ?? []
                XCTAssertFalse(purposes.isEmpty, "Expected purposes in configuration")
                let jurisdiction = full.jurisdiction?.code
                    ?? full.jurisdiction?.defaultJurisdictionCode
                    ?? bootConfig?.jurisdiction?.code
                    ?? "us"
                let purposeMap = Dictionary(
                    uniqueKeysWithValues: purposes.map { purpose in
                        (
                            purpose.code,
                            KetchSDK.ConsentConfig.PurposeLegalBasis(legalBasisCode: purpose.legalBasisCode)
                        )
                    }
                )
                return KetchSDK.ConsentConfig(
                    organizationCode: self.orgCode,
                    propertyCode: self.propertyCode,
                    environmentCode: self.environmentCode,
                    jurisdictionCode: jurisdiction,
                    identities: identities,
                    purposes: purposeMap
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
