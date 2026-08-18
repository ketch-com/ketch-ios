//
//  Location.swift
//  KetchSDK
//

import Foundation

extension KetchSDK {
    /// GeoIP details from `GET /ip` (ketch-types `IPInfo` / `GetLocationResponse`).
    public struct IPInfo: Codable, Sendable {
        public let ip: String?
        public let hostname: String?
        public let continentCode: String?
        public let continentName: String?
        public let countryCode: String?
        public let countryName: String?
        public let regionCode: String?
        public let regionName: String?
        public let city: String?
        public let postalCode: String?
        public let timezone: String?
    }

    /// Response from headless `getLocation()`.
    public struct LocationResponse: Codable, Sendable {
        public let location: IPInfo?

        public init(location: IPInfo?) {
            self.location = location
        }

        public init(from decoder: Decoder) throws {
            if let container = try? decoder.container(keyedBy: CodingKeys.self) {
                if let nested = try? container.decode(IPInfo.self, forKey: .location) {
                    location = nested
                    return
                }
                if (try? container.decodeNil(forKey: .location)) == true {
                    location = nil
                    return
                }
            }
            location = try IPInfo(from: decoder)
        }

        private enum CodingKeys: String, CodingKey {
            case location
        }
    }
}

extension KetchSDK.IPInfo {
    /// Combined ISO region code, e.g. "US-CA", or the country alone when no subdivision is known.
    func toRegionCode() -> String? {
        guard let country = countryCode, !country.isEmpty else {
            guard let region = regionCode, !region.isEmpty else { return nil }
            return region
        }
        guard let region = regionCode, !region.isEmpty else { return country }
        return "\(country)-\(region)"
    }
}
