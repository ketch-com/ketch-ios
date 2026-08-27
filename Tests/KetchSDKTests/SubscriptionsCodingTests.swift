import XCTest
@testable import KetchSDK

final class SubscriptionsCodingTests: XCTestCase {

    /// Verbatim response body from a subscriptions get.
    private let liveGetResponse = """
    {"controllerCode":"","controls":{},"environmentCode":"production",
     "identities":{"email":"someone@example.com"},"jurisdictionCode":"california",
     "properties":{},"propertyCode":"ios","regionCode":"","topics":{}}
    """

    func testDecodesLiveResponse() throws {
        let response = try JSONDecoder().decode(
            KetchSDK.SubscriptionsResponse.self,
            from: Data(liveGetResponse.utf8)
        )

        XCTAssertEqual(response.propertyCode, "ios")
        XCTAssertEqual(response.jurisdictionCode, "california")
        XCTAssertEqual(response.topics, [:])
    }

    func testDecodesPopulatedTopics() throws {
        let json = """
        {"propertyCode":"ios","topics":{
          "marketing_emails":{"email":{"status":"granted"},"sms":{"status":"denied"}}
        },"controls":{"global_opt_out":{"status":"denied","impact":1}}}
        """

        let response = try JSONDecoder().decode(
            KetchSDK.SubscriptionsResponse.self,
            from: Data(json.utf8)
        )

        XCTAssertEqual(response.topics?["marketing_emails"]?["email"]?.status, .granted)
        XCTAssertEqual(response.topics?["marketing_emails"]?["sms"]?.status, .denied)
        XCTAssertEqual(response.controls?["global_opt_out"]?.status, .denied)
        XCTAssertEqual(response.controls?["global_opt_out"]?.impact, 1)
    }

    /// The server rejects a bare string for a contact method setting.
    func testEncodesTopicsAsPerContactMethodObjects() throws {
        let request = KetchSDK.SubscriptionsRequest(
            organizationCode: "acme",
            propertyCode: "ios",
            topics: ["marketing_emails": ["email": .init(status: .granted)]]
        )

        let encoded = try JSONEncoder().encode(request)
        let json = try XCTUnwrap(
            JSONSerialization.jsonObject(with: encoded) as? [String: Any]
        )
        let topics = try XCTUnwrap(json["topics"] as? [String: Any])
        let emails = try XCTUnwrap(topics["marketing_emails"] as? [String: Any])
        let email = try XCTUnwrap(emails["email"] as? [String: Any])

        XCTAssertEqual(email["status"] as? String, "granted")
    }

    func testStatusRoundTripsThroughItsWireStrings() throws {
        XCTAssertEqual(KetchSDK.SubscriptionStatus(rawValue: "granted"), .granted)
        XCTAssertEqual(KetchSDK.SubscriptionStatus(rawValue: "denied"), .denied)
        XCTAssertNil(KetchSDK.SubscriptionStatus(rawValue: "true"))
    }
}
