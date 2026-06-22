//
//  KetchSDK.swift
//  KetchSDK
//

import Combine
import Foundation

public enum KetchSDK {
    /// Instantiation of Ketch core class
    /// - Parameters:
    ///   - organizationCode: Organization defined in the platform side.
    ///   - propertyCode: Property defined in the platform side.
    ///   - environmentCode: Environment defined in the platform side.
    ///   - identities: Identifiers of current instance of app. Possible types defined in the platform side. For iOS it is usually "idfa" (AdvertisementIdentifier)
    ///   - dataCenter: CDN region for headless API calls (defaults to US).
    /// - Returns: Ketch instance.
    public static func create(
        organizationCode: String,
        propertyCode: String,
        environmentCode: String,
        identities: [Ketch.Identity],
        dataCenter: KetchDataCenter = .us
    ) -> Ketch {
        Ketch(
            organizationCode: organizationCode,
            propertyCode: propertyCode,
            environmentCode: environmentCode,
            identities: identities,
            dataCenter: dataCenter
        )
    }
}

// MARK: - Headless API (static, web/v3)

extension KetchSDK {
    /// GeoIP / jurisdiction hint (`GET /ip`).
    public static func fetchLocation(
        dataCenter: KetchDataCenter = .us
    ) -> AnyPublisher<LocationResponse, KetchError> {
        KetchApiRequest(dataCenter: dataCenter).fetchLocation()
    }

    /// Minimal config (`GET .../boot.json`).
    public static func fetchBootstrapConfiguration(
        organization: String,
        property: String,
        dataCenter: KetchDataCenter = .us
    ) -> AnyPublisher<Configuration, KetchError> {
        KetchApiRequest(dataCenter: dataCenter)
            .fetchBootstrapConfiguration(organization: organization, property: property)
    }

    /// Full config with optional env / jurisdiction / language and hash query param.
    public static func fetchFullConfiguration(
        request: FullConfigurationRequest,
        dataCenter: KetchDataCenter = .us
    ) -> AnyPublisher<Configuration, KetchError> {
        KetchApiRequest(dataCenter: dataCenter).fetchFullConfiguration(request: request)
    }

    /// Server consent including `protocols` (`POST .../consent/{org}/get`).
    public static func fetchConsent(
        config: ConsentConfig,
        dataCenter: KetchDataCenter = .us
    ) -> AnyPublisher<ConsentStatus, KetchError> {
        KetchApiRequest(dataCenter: dataCenter).fetchConsent(config: config)
    }

    /// Protocol strings only (same endpoint as fetchConsent).
    public static func fetchProtocols(
        config: ConsentConfig,
        dataCenter: KetchDataCenter = .us
    ) -> AnyPublisher<ConsentStatus, KetchError> {
        KetchApiRequest(dataCenter: dataCenter).fetchProtocols(config: config)
    }

    /// Updates consent; returns server response with computed `protocols`. Does not send `protocols` in the request body.
    public static func setConsent(
        update: ConsentUpdate,
        dataCenter: KetchDataCenter = .us
    ) -> AnyPublisher<ConsentStatus, KetchError> {
        KetchApiRequest(dataCenter: dataCenter).setConsent(update: headlessUpdate(from: update))
    }

    private static func headlessUpdate(from update: ConsentUpdate) -> ConsentUpdate {
        ConsentUpdate(
            organizationCode: update.organizationCode,
            propertyCode: update.propertyCode,
            environmentCode: update.environmentCode,
            identities: update.identities,
            jurisdictionCode: update.jurisdictionCode,
            migrationOption: update.migrationOption,
            purposes: update.purposes,
            vendors: update.vendors,
            protocols: update.protocols
        )
    }

    /// Invokes a data subject right (`POST .../rights/{org}/invoke`).
    public static func invokeRight(
        request: InvokeRightRequest,
        dataCenter: KetchDataCenter = .us
    ) -> AnyPublisher<Void, KetchError> {
        KetchApiRequest(dataCenter: dataCenter).invokeRight(request: request)
    }

    /// Gets profile preferences (`POST .../profile/{org}/get`).
    public static func getProfile(
        request: GetProfileRequest,
        dataCenter: KetchDataCenter = .us
    ) -> AnyPublisher<GetProfileResponse, KetchError> {
        KetchApiRequest(dataCenter: dataCenter).getProfile(request: request)
    }

    /// Updates profile preferences (`POST .../profile/{org}/put`).
    public static func putProfile(
        request: PutProfileRequest,
        dataCenter: KetchDataCenter = .us
    ) -> AnyPublisher<Void, KetchError> {
        KetchApiRequest(dataCenter: dataCenter).putProfile(request: request)
    }

    /// Gets subscription topics/controls (`POST .../subscriptions/{org}/get`).
    public static func getSubscriptions(
        request: SubscriptionsRequest,
        dataCenter: KetchDataCenter = .us
    ) -> AnyPublisher<SubscriptionsResponse, KetchError> {
        KetchApiRequest(dataCenter: dataCenter).getSubscriptions(request: request)
    }

    /// Updates subscription topics/controls (`POST .../subscriptions/{org}/update`).
    public static func setSubscriptions(
        request: SubscriptionsRequest,
        dataCenter: KetchDataCenter = .us
    ) -> AnyPublisher<Void, KetchError> {
        KetchApiRequest(dataCenter: dataCenter).setSubscriptions(request: request)
    }

    public static func fetchSubscriptionsConfiguration(
        request: SubscriptionConfigurationRequest,
        dataCenter: KetchDataCenter = .us
    ) -> AnyPublisher<SubscriptionConfiguration, KetchError> {
        KetchApiRequest(dataCenter: dataCenter).fetchSubscriptionsConfiguration(request: request)
    }

    public static func preferenceQRUrl(
        request: PreferenceQRRequest,
        dataCenter: KetchDataCenter = .us
    ) -> URL? {
        HeadlessApiClient(dataCenter: dataCenter).preferenceQRUrl(request: request)
    }

    public static func webReport(
        channel: String,
        request: WebReportRequest,
        dataCenter: KetchDataCenter = .us
    ) -> AnyPublisher<Void, KetchError> {
        KetchApiRequest(dataCenter: dataCenter).webReport(channel: channel, request: request)
    }
}

// MARK: - Legacy static publishers

extension KetchSDK {
    /// Retrieves full organization configuration data.
    public static func config(
        organization: String,
        property: String,
        dataCenter: KetchDataCenter = .us
    ) -> AnyPublisher<Configuration, KetchError> {
        KetchApiRequest(dataCenter: dataCenter)
            .fetchConfig(organization: organization, property: property)
    }

    /// Retrieves currently set consent status from the CDN.
    public static func getConsent(
        organizationCode: String,
        propertyCode: String,
        environmentCode: String,
        jurisdictionCode: String,
        identities: [String: String],
        purposes: [String: ConsentConfig.PurposeLegalBasis],
        dataCenter: KetchDataCenter = .us
    ) -> AnyPublisher<ConsentStatus, KetchError> {
        fetchConsent(
            config: ConsentConfig(
                organizationCode: organizationCode,
                propertyCode: propertyCode,
                environmentCode: environmentCode,
                jurisdictionCode: jurisdictionCode,
                identities: identities,
                purposes: purposes
            ),
            dataCenter: dataCenter
        )
    }

    /// Sends a request for updating consent status; completes when the CDN accepts the update.
    public static func setConsent(
        organizationCode: String,
        propertyCode: String,
        environmentCode: String,
        identities: [String: String],
        jurisdictionCode: String,
        migrationOption: ConsentUpdate.MigrationOption,
        purposes: [String: ConsentUpdate.PurposeAllowedLegalBasis],
        vendors: [String]?,
        protocols: [String: String]?,
        dataCenter: KetchDataCenter = .us
    ) -> AnyPublisher<Void, KetchError> {
        setConsent(
            update: ConsentUpdate(
                organizationCode: organizationCode,
                propertyCode: propertyCode,
                environmentCode: environmentCode,
                identities: identities,
                jurisdictionCode: jurisdictionCode,
                migrationOption: migrationOption,
                purposes: purposes,
                vendors: vendors,
                protocols: protocols
            ),
            dataCenter: dataCenter
        )
        .map { _ in () }
        .eraseToAnyPublisher()
    }

    /// Invokes the specified rights.
    public static func invokeRights(
        organizationCode: String,
        propertyCode: String,
        environmentCode: String,
        identities: [String: String],
        invokedAt: Int?,
        jurisdictionCode: String,
        rightCode: String,
        user: InvokeRightConfig.User,
        dataCenter: KetchDataCenter = .us
    ) -> AnyPublisher<Void, KetchError> {
        KetchApiRequest(dataCenter: dataCenter)
            .invokeRights(
                organization: organizationCode,
                config: InvokeRightConfig(
                    propertyCode: propertyCode,
                    environmentCode: environmentCode,
                    jurisdictionCode: jurisdictionCode,
                    invokedAt: invokedAt,
                    identities: identities,
                    rightCode: rightCode,
                    user: user
                )
            )
    }

    /// Retrieves list of consent vendors.
    public static func getVendors(
        dataCenter: KetchDataCenter = .us
    ) -> AnyPublisher<Vendors, KetchError> {
        KetchApiRequest(dataCenter: dataCenter).getVendors()
    }
}

extension KetchSDK {
    public enum HideExperienceStatus: String, Codable {
        case SetConsent = "setConsent"
        case InvokeRight = "invokeRight"
        case Close = "close"
        case CloseWithoutSettingConsent = "closeWithoutSettingConsent"
        case WillNotShow = "willNotShow"
        case SetSubscriptions = "setSubscriptions"
        case None = "none"
    }
    
    public enum WillShowExperienceType: String, Codable {
        case ConsentExperience = "experiences.consent"
        case PreferenceExperience = "experiences.preference"
        case None = "none"
    }
}
