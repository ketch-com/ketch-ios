import Combine
import XCTest
@testable import KetchSDK

final class KetchHeadlessCachingTests: XCTestCase {
    func testGetRegion_cachesLocationAcrossCalls() {
        let apiClient = CountingApiClient { _ in
            Just(Data("""
            {"location":{"countryCode":"US","regionCode":"CA"}}
            """.utf8))
                .setFailureType(to: ApiClientError.self)
                .eraseToAnyPublisher()
        }
        let ketch = Ketch(
            organizationCode: "acme",
            propertyCode: "prop",
            environmentCode: "production",
            identities: [],
            apiClient: apiClient
        )

        let first = expectation(description: "first getRegion")
        ketch.getRegion { result in
            XCTAssertEqual(try? result.get(), "US-CA")
            first.fulfill()
        }
        wait(for: [first], timeout: 5)

        let second = expectation(description: "second getRegion")
        ketch.getRegion { result in
            XCTAssertEqual(try? result.get(), "US-CA")
            second.fulfill()
        }
        wait(for: [second], timeout: 5)

        XCTAssertEqual(apiClient.callCount, 1, "getRegion should hit the network only once; repeat calls should be served from cache")
    }

    func testGetFullConfiguration_sameRequest_servedFromCache() {
        let apiClient = CountingApiClient { _ in
            Just(Data("{}".utf8)).setFailureType(to: ApiClientError.self).eraseToAnyPublisher()
        }
        let ketch = Ketch(
            organizationCode: "acme",
            propertyCode: "prop",
            environmentCode: "production",
            identities: [],
            apiClient: apiClient
        )
        let request = KetchSDK.FullConfigurationRequest(
            organizationCode: "acme",
            propertyCode: "prop",
            environmentCode: "production",
            jurisdictionCode: "us-ca",
            languageCode: "en-US"
        )

        let first = expectation(description: "first getFullConfiguration")
        ketch.getFullConfiguration(request: request) { _ in first.fulfill() }
        wait(for: [first], timeout: 5)

        let second = expectation(description: "second getFullConfiguration")
        ketch.getFullConfiguration(request: request) { _ in second.fulfill() }
        wait(for: [second], timeout: 5)

        XCTAssertEqual(apiClient.callCount, 1, "Identical requests should be served from the config cache")
    }

    func testGetFullConfiguration_differentRequest_missesCache() {
        let apiClient = CountingApiClient { _ in
            Just(Data("{}".utf8)).setFailureType(to: ApiClientError.self).eraseToAnyPublisher()
        }
        let ketch = Ketch(
            organizationCode: "acme",
            propertyCode: "prop",
            environmentCode: "production",
            identities: [],
            apiClient: apiClient
        )

        let first = expectation(description: "first getFullConfiguration")
        ketch.getFullConfiguration(
            request: .init(
                organizationCode: "acme",
                propertyCode: "prop",
                environmentCode: "production",
                jurisdictionCode: "us-ca",
                languageCode: "en-US"
            )
        ) { _ in first.fulfill() }
        wait(for: [first], timeout: 5)

        let second = expectation(description: "second getFullConfiguration, different jurisdiction")
        ketch.getFullConfiguration(
            request: .init(
                organizationCode: "acme",
                propertyCode: "prop",
                environmentCode: "production",
                jurisdictionCode: "eu-fr",
                languageCode: "en-US"
            )
        ) { _ in second.fulfill() }
        wait(for: [second], timeout: 5)

        XCTAssertEqual(apiClient.callCount, 2, "Requests that hit different config URLs must not share a cache entry")
    }

    func testGetFullConfiguration_differentRegionOnShortPath_missesCache() {
        let apiClient = CountingApiClient { _ in
            Just(Data("{}".utf8)).setFailureType(to: ApiClientError.self).eraseToAnyPublisher()
        }
        let ketch = Ketch(
            organizationCode: "acme",
            propertyCode: "prop",
            environmentCode: "production",
            identities: [],
            apiClient: apiClient
        )

        let first = expectation(description: "first getFullConfiguration")
        ketch.getFullConfiguration(
            request: .init(organizationCode: "acme", propertyCode: "prop", regionCode: "US-CA")
        ) { _ in first.fulfill() }
        wait(for: [first], timeout: 5)

        let second = expectation(description: "second getFullConfiguration, different region")
        ketch.getFullConfiguration(
            request: .init(organizationCode: "acme", propertyCode: "prop", regionCode: "US-NY")
        ) { _ in second.fulfill() }
        wait(for: [second], timeout: 5)

        XCTAssertEqual(apiClient.callCount, 2, "A regionCode-only difference on the short path must not share a cache entry")
    }

    func testGetJurisdiction_returnsCodeFromConfig() {
        let apiClient = CountingApiClient { _ in
            Just(Data("""
            {"jurisdiction":{"code":"us-ca","defaultJurisdictionCode":"us"}}
            """.utf8))
                .setFailureType(to: ApiClientError.self)
                .eraseToAnyPublisher()
        }
        let ketch = Ketch(
            organizationCode: "acme",
            propertyCode: "prop",
            environmentCode: "production",
            identities: [],
            apiClient: apiClient
        )

        let expectation = expectation(description: "getJurisdiction")
        ketch.getJurisdiction { result in
            XCTAssertEqual(try? result.get(), "us-ca")
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 5)
    }

    func testGetJurisdiction_fallsBackToDefaultJurisdictionCode() {
        let apiClient = CountingApiClient { _ in
            Just(Data("""
            {"jurisdiction":{"defaultJurisdictionCode":"us"}}
            """.utf8))
                .setFailureType(to: ApiClientError.self)
                .eraseToAnyPublisher()
        }
        let ketch = Ketch(
            organizationCode: "acme",
            propertyCode: "prop",
            environmentCode: "production",
            identities: [],
            apiClient: apiClient
        )

        let expectation = expectation(description: "getJurisdiction fallback")
        ketch.getJurisdiction { result in
            XCTAssertEqual(try? result.get(), "us")
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 5)
    }
}

// MARK: - Test doubles

private final class CountingApiClient: ApiClient {
    private(set) var callCount = 0
    private let handler: (ApiRequest) -> AnyPublisher<Data, ApiClientError>

    init(handler: @escaping (ApiRequest) -> AnyPublisher<Data, ApiClientError>) {
        self.handler = handler
    }

    func execute(request: ApiRequest) -> AnyPublisher<Data, ApiClientError> {
        callCount += 1
        return handler(request)
    }
}
