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

        public init(
            organizationCode: String,
            propertyCode: String,
            environmentCode: String? = nil,
            jurisdictionCode: String? = nil,
            languageCode: String? = nil,
            hash: String? = nil
        ) {
            self.organizationCode = organizationCode
            self.propertyCode = propertyCode
            self.environmentCode = environmentCode
            self.jurisdictionCode = jurisdictionCode
            self.languageCode = languageCode
            self.hash = hash
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
              let jurisdiction = jurisdictionCode, !jurisdiction.isEmpty,
              let language = languageCode, !language.isEmpty
        else {
            return nil
        }
        return (env, jurisdiction, language)
    }

    /// Non-blank hash, or `nil` — a blank hash is treated the same as an absent one.
    func normalizedHash() -> String? {
        guard let hash, !hash.isEmpty else { return nil }
        return hash
    }
}
