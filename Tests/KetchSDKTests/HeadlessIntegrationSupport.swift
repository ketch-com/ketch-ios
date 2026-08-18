import Foundation
@testable import KetchSDK

/// Shared sandbox config for live CDN integration tests.
enum HeadlessIntegrationSupport {
    static let orgCode = "ketch_samples"
    static let propertyCode = "ios"
    static let environmentCode = "production"

    static func uniqueEmailIdentity() -> [String: String] {
        ["email": "headless-\(UUID().uuidString)@integration.ketch.test"]
    }

    static func consentConfigFrom(
        configuration: KetchSDK.Configuration,
        identities: [String: String],
        organizationCode: String = orgCode,
        propertyCode: String = propertyCode,
        environmentCode: String = environmentCode
    ) -> KetchSDK.ConsentConfig {
        let jurisdiction = configuration.jurisdiction?.code
            ?? configuration.jurisdiction?.defaultJurisdictionCode
            ?? "us"
        let purposesList = configuration.purposes ?? []
        let purposeMap = Dictionary(
            uniqueKeysWithValues: purposesList.map { purpose in
                (
                    purpose.code,
                    KetchSDK.ConsentConfig.PurposeLegalBasis(
                        legalBasisCode: purpose.legalBasisCode
                    )
                )
            }
        )
        precondition(!purposeMap.isEmpty, "Configuration returned no purposes")
        return KetchSDK.ConsentConfig(
            organizationCode: organizationCode,
            propertyCode: propertyCode,
            environmentCode: environmentCode,
            jurisdictionCode: jurisdiction,
            identities: identities,
            purposes: purposeMap
        )
    }
}
