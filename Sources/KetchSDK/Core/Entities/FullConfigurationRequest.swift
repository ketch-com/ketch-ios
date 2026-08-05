//
//  FullConfigurationRequest.swift
//  KetchSDK
//

import Foundation

extension KetchSDK {
    /// Parameters for v3 `getFullConfiguration` (ketch-types `GetFullConfigurationRequest`).
    public struct FullConfigurationRequest: Sendable {
        public let organizationCode: String
        public let propertyCode: String
        public let environmentCode: String?
        public let jurisdictionCode: String?
        public let languageCode: String?
        public let hash: String?
        public let regionCode: String?

        public init(
            organizationCode: String,
            propertyCode: String,
            environmentCode: String? = nil,
            jurisdictionCode: String? = nil,
            languageCode: String? = nil,
            hash: String? = nil,
            regionCode: String? = nil
        ) {
            self.organizationCode = organizationCode
            self.propertyCode = propertyCode
            self.environmentCode = environmentCode
            self.jurisdictionCode = jurisdictionCode
            self.languageCode = languageCode
            self.hash = hash
            self.regionCode = regionCode
        }
    }
}

extension KetchSDK.FullConfigurationRequest {
    /// The env/jurisdiction/language segment appended to the full-config path, or `nil` if any of
    /// the three is absent or blank — matching ketch-tag, which treats a blank value the same as
    /// unset. Single source of truth so the actual HTTP path (`HeadlessApiClient`) and any cache
    /// keyed on it (`Ketch.buildConfigCacheKey`) can never disagree about what "the same request"
    /// means.
    func configPathSegment() -> (env: String, jurisdiction: String, language: String)? {
        guard let env = environmentCode, !env.isEmpty,
              let jurisdiction = jurisdictionCode, !jurisdiction.isEmpty
        else {
            return nil
        }
        // A missing language must not silently drop env/jurisdiction to the short path —
        // synthesize it from the device locale so the long path is always used once both
        // env and jurisdiction are known.
        let language = languageCode?.isEmpty == false ? languageCode! : Self.deviceLanguageTag()
        return (env, jurisdiction, language)
    }

    /// Non-blank hash, or `nil` — a blank hash is treated the same as an absent one.
    func normalizedHash() -> String? {
        guard let hash, !hash.isEmpty else { return nil }
        return hash
    }

    /// Matches ketch-tag's `formatLanguage` ("fr-CA"), tolerant of `Locale.preferredLanguages`' "fr_CA" form.
    /// Preserves a script subtag (4 letters, e.g. "Hans") in title case and a region subtag
    /// (2 letters or 3 digits, e.g. "CN"/"419") uppercased, so multi-part tags like "zh-Hans-CN"
    /// survive intact instead of collapsing to "zh-HANS" with the region silently dropped.
    static func formatLanguageTag(_ raw: String) -> String {
        guard !raw.isEmpty else { return "en" }
        let parts = raw.split(whereSeparator: { $0 == "-" || $0 == "_" }).map(String.init)
        guard let first = parts.first, !first.isEmpty else { return "en" }
        var result = [first.lowercased()]
        for part in parts.dropFirst() {
            if part.count == 4, part.allSatisfy(\.isLetter) {
                result.append(part.prefix(1).uppercased() + part.dropFirst().lowercased())
            } else if (part.count == 2 && part.allSatisfy(\.isLetter)) || (part.count == 3 && part.allSatisfy(\.isNumber)) {
                result.append(part.uppercased())
            }
        }
        return result.joined(separator: "-")
    }

    static func deviceLanguageTag() -> String {
        formatLanguageTag(Locale.preferredLanguages.first ?? "en")
    }

    /// Query items for `getFullConfiguration`. On the short path (see `configPathSegment`), a
    /// missing `languageCode` defaults to `deviceLanguage` rather than "en". Shared with
    /// `Ketch.buildConfigCacheKey`.
    func configQueryItems(deviceLanguage: () -> String = Self.deviceLanguageTag) -> [URLQueryItem] {
        var items: [URLQueryItem] = []
        if configPathSegment() == nil {
            let language = languageCode?.isEmpty == false ? languageCode! : deviceLanguage()
            items.append(URLQueryItem(name: "language", value: language))
            if let jurisdictionCode, !jurisdictionCode.isEmpty {
                items.append(URLQueryItem(name: "jurisdiction", value: jurisdictionCode))
            }
            if let regionCode, !regionCode.isEmpty {
                items.append(URLQueryItem(name: "region", value: regionCode))
            }
        }
        if let hash = normalizedHash() {
            items.append(URLQueryItem(name: "hash", value: hash))
        }
        return items
    }
}
