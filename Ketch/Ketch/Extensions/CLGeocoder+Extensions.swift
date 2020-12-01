//
//  String+Extensions.swift
//  Ketch
//
//  Created by Aleksey Bodnya on 3/30/20.
//  Copyright © 2020 Switchbit. All rights reserved.
//

import Foundation
import CoreLocation

extension CLGeocoder {

    /// Convenient method to reverse passed coordinates and generate `Location` structure. The reversed location will be in-memory cached.
    /// - Parameter coordinate: input coordinate
    /// - Parameter completionHandler: completion handler that provides `Location` structure as a success result or error as a failure result
    func reverseCoordinate(_ coordinate: CLLocationCoordinate2D, completionHandler: @escaping (Location?, Error?) -> Void) {
        if let cache = GeocoderCache.shared.get(coordinate: coordinate) {
            completionHandler(cache, nil)
            return
        }
        reverseGeocodeLocation(CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)) { (placemarks, error) in
            guard error == nil else {
                let nsError = (error! as NSError)
                if nsError.domain == kCLErrorDomain && nsError.code == 10 {
                    // cancel
                    return
                }
                completionHandler(nil, error)
                return
            }

            if let placemark = placemarks?.first, let location = Location(placemark: placemark) {
                GeocoderCache.shared.add(coordinate: coordinate, location: location)
                completionHandler(location, nil)
            } else {
                completionHandler(nil, nil)
            }
        }
    }
}

// MARK: -

/// Local cache for geocoded data
private class GeocoderCache {

    /// Shared instance
    static let shared = GeocoderCache()

    /// Queue for updating cache and getting the cached data
    private lazy var queue = DispatchQueue(label: "GeocoderCache")

    /// In-memory cache map
    private var cache: [String: Location] = [:]

    /// Convenient method to get key from coordinate
    /// - Parameter coordinate: coordinate
    /// - Returns: string key
    private func key(coordinate: CLLocationCoordinate2D) -> String {
        return "\(coordinate.latitude),\(coordinate.longitude)"
    }

    /// Adds location associated with coordinate in the cache
    /// - Parameter coordinate: The coordinate to add in the cache as a key
    /// - Parameter location: The location to add in cache as a value
    func add(coordinate: CLLocationCoordinate2D, location: Location) {
        queue.sync { [unowned self] in
            self.cache[self.key(coordinate: coordinate)] = location
        }
    }

    /// Retrieves location associated with coordinate from the cache
    /// - Parameter coordinate: The coordinate to add in the cache as a key
    /// - Returns: The location from cache associated with coordinate of nil if missed in the cache
    func get(coordinate: CLLocationCoordinate2D) -> Location? {
        return queue.sync(execute: { [unowned self] in
            return self.cache[self.key(coordinate: coordinate)]
        })
    }
}

// MARK: -

private extension Location {

    init?(placemark: CLPlacemark) {
        guard let country = placemark.isoCountryCode?.uppercased() else {
            return nil
        }
        self.init(countryCode: country, regionCode: Location.shortCode(administrativeArea: placemark.administrativeArea))
    }

    /// Convenient method to generate short state code from provided `administrativeArea`
    /// The Apple Documentation says that `administrativeArea` may be short or long code. We need short code.
    ///
    /// Apple Documentation:
    /// The string in this property can be either the spelled out name of the administrative area or its designated abbreviation, if one exists. If the placemark location is Apple’s headquarters, for example, the value for this property would be the string “CA” or “California”.
    ///
    /// - Parameter administrativeArea: The value retrieved from `CLPlacemark` object
    /// - Returns: short code of passed `administrativeArea` parameter
    private static func shortCode(administrativeArea: String?) -> String? {
        guard let administrativeArea = administrativeArea else {
            return nil
        }
        if administrativeArea.count == 2 {
            return administrativeArea.uppercased()
        }
        let map = [
            "alabama": "AL",
            "alaska": "AK",
            "arizona": "AZ",
            "arkansas": "AR",
            "california": "CA",
            "colorado": "CO",
            "connecticut": "CT",
            "delaware": "DE",
            "district of columbia": "DC",
            "florida": "FL",
            "georgia": "GA",
            "hawaii": "HI",
            "idaho": "ID",
            "illinois": "IL",
            "indiana": "IN",
            "iowa": "IA",
            "kansas": "KS",
            "kentucky": "KY",
            "louisiana": "LA",
            "maine": "ME",
            "maryland": "MD",
            "massachusetts": "MA",
            "michigan": "MI",
            "minnesota": "MN",
            "mississippi": "MS",
            "missouri": "MO",
            "montana": "MT",
            "nebraska": "NE",
            "nevada": "NV",
            "new hampshire": "NH",
            "new jersey": "NJ",
            "new mexico": "NM",
            "new york": "NY",
            "north carolina": "NC",
            "north dakota": "ND",
            "ohio": "OH",
            "oklahoma": "OK",
            "oregon": "OR",
            "pennsylvania": "PA",
            "rhode island": "RI",
            "south carolina": "SC",
            "south dakota": "SD",
            "tennessee": "TN",
            "texas": "TX",
            "utah": "UT",
            "vermont": "VT",
            "virginia": "VA",
            "washington": "WA",
            "west virginia": "WV",
            "wisconsin": "WI",
            "wyoming": "WY"
        ]

        return map[administrativeArea.lowercased()]
    }
}
