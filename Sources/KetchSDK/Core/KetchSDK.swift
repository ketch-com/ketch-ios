//
//  KetchSDK.swift
//  KetchSDK
//

import Combine

public enum KetchSDK {
    public static func create(
        organizationCode: String,
        propertyCode: String,
        environmentCode: String,
        controllerCode: String,
        identities: [Ketch.Identity]
    ) -> Ketch {
        Ketch(
            organizationCode: organizationCode,
            propertyCode: propertyCode,
            environmentCode: environmentCode,
            controllerCode: controllerCode,
            identities: identities
        )
    }
}

extension KetchSDK {
    /// Retrieves full organization configuration data.
    /// - Parameters:
    ///   - organization: organization code
    ///   - property: property code
    /// - Returns: Publisher of organization configuration request result.
    public func config(
        organization: String,
        property: String
    ) -> AnyPublisher<Configuration, KetchError> {
        KetchApiRequest()
            .fetchConfig(organization: organization, property: property)
            .eraseToAnyPublisher()
    }

    /// Retrieves currently set consent status.
    /// - Parameters:
    ///   - organizationCode: organization code
    ///   - controllerCode: controller code
    ///   - propertyCode: property code
    ///   - environmentCode: environment code
    ///   - jurisdictionCode: jurisdiction code
    ///   - identities: map of identity code and value
    ///   - purposes: map of purpose code and PurposeLegalBasis
    /// - Returns: Publisher of set consent request result.
    public func getConsent(
        organizationCode: String,
        controllerCode: String,
        propertyCode: String,
        environmentCode: String,
        jurisdictionCode: String,
        identities: [String : String],
        purposes: [String : ConsentConfig.PurposeLegalBasis]
    ) -> AnyPublisher<ConsentStatus, KetchError> {
        KetchApiRequest()
            .getConsent(
                config: ConsentConfig(
                    organizationCode: organizationCode,
                    controllerCode: controllerCode,
                    propertyCode: propertyCode,
                    environmentCode: environmentCode,
                    jurisdictionCode: jurisdictionCode,
                    identities: identities,
                    purposes: purposes
                )
            )
            .eraseToAnyPublisher()
    }

    /// Sends a request for updating consent status
    /// - Parameters:
    ///   - organizationCode: organization code
    ///   - controllerCode: controller code
    ///   - propertyCode: property code
    ///   - environmentCode: environment code
    ///   - identities: map of identity code and value
    ///   - jurisdictionCode: jurisdiction code
    ///   - migrationOption: migration option.
    ///   - purposes: map of purpose code and PurposeLegalBasis
    ///   - vendors: list of vendors
    /// - Returns: Publisher of get consent request result.
    public func setConsent(
        organizationCode: String,
        controllerCode: String,
        propertyCode: String,
        environmentCode: String,
        identities: [String : String],
        jurisdictionCode: String,
        migrationOption: ConsentUpdate.MigrationOption,
        purposes: [String : ConsentUpdate.PurposeAllowedLegalBasis],
        vendors: [String]?
    ) -> AnyPublisher<Void, KetchError> {
        KetchApiRequest()
            .updateConsent(
                update: ConsentUpdate(
                    organizationCode: organizationCode,
                    controllerCode: controllerCode,
                    propertyCode: propertyCode,
                    environmentCode: environmentCode,
                    identities: identities,
                    jurisdictionCode: jurisdictionCode,
                    migrationOption: migrationOption,
                    purposes: purposes,
                    vendors: vendors
                )
            )
            .eraseToAnyPublisher()
    }

    /// Invokes the specified rights.
    /// - Parameters:
    ///   - organizationCode: organization code
    ///   - controllerCode: controller code
    ///   - propertyCode: property code
    ///   - environmentCode: environment code
    ///   - identities: jurisdiction code
    ///   - invokedAt: the current time
    ///   - jurisdictionCode: map of identity code and value
    ///   - rightCode: right code
    ///   - user: current user object
    /// - Returns: Publisher of invoke rights request result.
    public func invokeRights(
        organizationCode: String,
        controllerCode: String,
        propertyCode: String,
        environmentCode: String,
        identities: [String : String],
        invokedAt: Int?,
        jurisdictionCode: String,
        rightCode: String,
        user: InvokeRightConfig.User
    ) -> AnyPublisher<Void, KetchError> {
        KetchApiRequest()
            .invokeRights(
                organization: organizationCode,
                config: InvokeRightConfig(
                    controllerCode: controllerCode,
                    propertyCode: propertyCode,
                    environmentCode: environmentCode,
                    jurisdictionCode: jurisdictionCode,
                    invokedAt: invokedAt,
                    identities: identities,
                    rightCode: rightCode,
                    user: user
                )
            )
            .eraseToAnyPublisher()
    }

    public func getVendors() -> AnyPublisher<Vendors, KetchError> {
        KetchApiRequest()
            .getVendors()
            .eraseToAnyPublisher()
    }
}
