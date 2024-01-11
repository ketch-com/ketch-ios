//
//  Config.swift
//  KetchSDK
//

import Foundation

extension KetchSDK {
    public struct WebExpConfiguration: Codable {
        
    }
    
    public struct Configuration: Codable {
        public let language: String?
        public let organization: Organization?
        public let property: Property?
        public let environments: [Environment]?
        public let jurisdiction: Jurisdiction?
        public let identities: [String: Identity]?
        public let scripts: [String]?
        public let environment: Environment?
        public let deployment: Deployment?
        public let privacyPolicy: Policy?
        public let termsOfService: Policy?
        public let rights: [Right]?
        public let regulations: [String]?
        public let theme: Theme?
        public let experiences: Experience?
        public let purposes: [Purpose]?
        public let canonicalPurposes: [String: CanonicalPurpose]?
        public let services: [String: String]?
        public let options: [String: String]?
        public let legalBases: [LegalBase]?
        public let vendors: [Vendor]?
    }
}

extension KetchSDK.Configuration {
    public struct Organization: Codable {
        public let code: String?
    }

    public struct Property: Codable {
        public let code: String?
        public let name: String?
        public let platform: String?
    }

    public struct Environment: Codable {
        public let code: String?
        public let pattern: String?
        public let hash: String?
    }

    public struct Jurisdiction: Codable {
        public let code: String?
        public let defaultJurisdictionCode: String?
        public let variable: String?
        public let jurisdictions: [String: String]?
    }

    public struct Identity: Codable {
        public let type: String?
        public let variable: String?
        public let jwtKey: String?
        public let jwtLocation: Int?
    }

    public struct Deployment: Codable {
        public let code: String?
        public let version: Int?
    }

    public struct Policy: Codable {
        public let code: String?
        public let version: Int?
        public let url: String?
    }

    public struct Right: Codable {
        public let code: String
        public let name: String
        public let description: String
    }

    public struct Theme: Codable {
        public let code: String?
        public let name: String?
        public let description: String?

        public let watermark: Bool?

        public let buttonBorderRadius: Int?

        public let bannerBackgroundColor: String?
        public var bannerContentColor: String?
        public let bannerButtonColor: String?
        public let bannerSecondaryButtonColor: String?
        public let bannerSecondaryButtonVariant: String?
        public let bannerPosition: BannerPosition?

        public let modalHeaderBackgroundColor: String?
        public let modalHeaderContentColor: String?
        public var modalContentColor: String?
        public let modalButtonColor: String?
        public let modalPosition: ModalPosition?
        public var modalSwitchOffColor: String?
        public var modalSwitchOnColor: String?

        public let lightboxRibbonColor: String?
        public let formHeaderColor: String?
        public let statusColor: String?
        public let highlightColor: String?
        public let feedbackColor: String?
        public let font: String?

        public let formHeaderBackgroundColor: String?
        public var formHeaderContentColor: String?
        public let formContentColor: String?
        public let formButtonColor: String?
        public var formSwitchOffColor: String?
        public var formSwitchOnColor: String?

        public enum BannerPosition: Int, Codable {
            case UNKNOWN = 0
            case BOTTOM = 1
            case TOP = 2
            case BOTTOM_LEFT = 3
            case BOTTOM_RIGHT = 4
        }

        public enum ModalPosition: Int, Codable {
            case UNKNOWN = 0
            case CENTER = 1
            case LEFT_FULL_HEIGHT = 2
            case RIGHT_FULL_HEIGHT = 3
        }
    }

    public struct Experience: Codable {
        public let consent: ConsentExperience?
        public let preference: PreferenceExperience?

        public struct ConsentExperience: Codable {
            public let code: String
            public let version: Int
            public let banner: Banner
            public let modal: Modal
            public let jit: JIT?
            public let experienceDefault: ExperienceDefault

            public struct Banner: Codable {
                public let title: String?
                public let footerDescription: String
                public let buttonText: String
                public let primaryButtonAction: ExperiencePrimaryButtonAction?
                public let secondaryButtonText: String?
                public let secondaryButtonDestination: ExperienceButtonDestination?
            }

            public enum ExperiencePrimaryButtonAction: Int, Codable {
                case saveCurrentState = 1
                case acceptAll = 2
            }

            public enum ExperienceButtonDestination: Int, Codable {
                case gotoModal = 1
                case gotoPreference = 2
                case rejectAll = 3
            }

            public struct Modal: Codable {
                public let title: String
                public let bodyTitle: String?
                public let bodyDescription: String?
                public let buttonText: String

                public let showCloseIcon: Bool?
                public let consentTitle: String?
                public let hideConsentTitle: Bool?
                public let hideLegalBases: Bool?
                public let extensions: [String: String]?
            }

            public struct JIT: Codable {
                public let title: String?
                public let showCloseIcon: Bool?
                public let bodyDescription: String?
                public let acceptButtonText: String
                public let declineButtonText: String
                public let moreInfoText: String?
                public let moreInfoDestination: ExperienceButtonDestination?
            }

            public enum ExperienceDefault: Int, Codable {
                case banner = 1
                case modal
            }
        }
    }

    public struct PreferenceExperience: Codable {
        public let code: String
        public let version: Int
        public let title: String
        public let rights: RightsTab?
        public let consents: ConsentsTab
        public let overview: OverviewTab

        public struct RightsTab: Codable {
            public let tabName: String
            public let bodyTitle: String?
            public let bodyDescription: String?
            public let buttonText: String
        }

        public struct ConsentsTab: Codable {
            public let tabName: String
            public let bodyTitle: String?
            public let bodyDescription: String?
            public let buttonText: String
        }

        public struct OverviewTab: Codable {
            public let tabName: String
            public let bodyTitle: String?
            public let bodyDescription: String
        }
    }

    public struct Purpose: Codable {
        public let code: String
        public let name: String?
        public let description: String?
        public let legalBasisCode: String
        public let requiresPrivacyPolicy: Bool?
        public let requiresOptIn: Bool?
        public let allowsOptOut: Bool?
        public let requiresDisplay: Bool?
        public let categories: [PurposeCategory]?
        public let tcfType: String?
        public let tcfID: String?
        public let canonicalPurposeCode: String?
        public let legalBasisName: String?
        public let legalBasisDescription: String?

        public struct PurposeCategory: Codable {
            public let name: String
            public let description: String
            public let retentionPeriod: String
            public let externalTransfers: String
        }
    }

    public struct CanonicalPurpose: Codable {
        public let code: String?
        public let name: String?
        public let purposeCodes: [String]?
    }

    public struct LegalBase: Codable {
        public let code: String?
        public let name: String?
        public let description: String?
    }

    public struct Vendor: Codable {
        public let id: String
        public let name: String
        public let purposes: [VendorPurpose]?
        public let specialPurposes: [VendorPurpose]?
        public let features: [VendorPurpose]?
        public let specialFeatures: [VendorPurpose]?
        public let policyUrl: String?
        public let cookieMaxAgeSeconds: Int?
        public let usesCookies: Bool?
        public let usesNonCookieAccess: Bool?

        public struct VendorPurpose: Codable {
            public let name: String
            public let legalBasis: String?
        }
    }
}
