import XCTest
@testable import KetchSDK

final class LocationRegionCodeTests: XCTestCase {
    private func ipInfo(countryCode: String?, regionCode: String?) -> KetchSDK.IPInfo {
        KetchSDK.IPInfo(
            ip: nil,
            hostname: nil,
            continentCode: nil,
            continentName: nil,
            countryCode: countryCode,
            countryName: nil,
            regionCode: regionCode,
            regionName: nil,
            city: nil,
            postalCode: nil,
            timezone: nil
        )
    }

    func testToRegionCode_countryAndRegion_combinesWithHyphen() {
        XCTAssertEqual(ipInfo(countryCode: "US", regionCode: "CA").toRegionCode(), "US-CA")
    }

    func testToRegionCode_countryOnly() {
        XCTAssertEqual(ipInfo(countryCode: "US", regionCode: nil).toRegionCode(), "US")
    }

    func testToRegionCode_countryOnly_blankRegion() {
        XCTAssertEqual(ipInfo(countryCode: "US", regionCode: "").toRegionCode(), "US")
    }

    func testToRegionCode_regionOnly_whenCountryAbsent() {
        XCTAssertEqual(ipInfo(countryCode: nil, regionCode: "CA").toRegionCode(), "CA")
    }

    func testToRegionCode_regionOnly_whenCountryBlank() {
        XCTAssertEqual(ipInfo(countryCode: "", regionCode: "CA").toRegionCode(), "CA")
    }

    func testToRegionCode_bothAbsent_returnsNil() {
        XCTAssertNil(ipInfo(countryCode: nil, regionCode: nil).toRegionCode())
    }

    func testToRegionCode_bothBlank_returnsNil() {
        XCTAssertNil(ipInfo(countryCode: "", regionCode: "").toRegionCode())
    }
}
