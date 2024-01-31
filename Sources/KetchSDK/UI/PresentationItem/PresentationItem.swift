//
//  PresentationItem.swift
//  KetchSDK
//

import SwiftUI

extension KetchUI {
    /// Essential presentation entity provided for client for presentation
    public struct PresentationItem: Identifiable {
        let itemType: ItemType
        let config: KetchSDK.Configuration
        let consent: KetchSDK.ConsentStatus
        let localizedStrings: KetchSDK.Configuration.Translations?

        public var id: String { String(describing: itemType) }
    }
}

extension KetchUI.PresentationItem {
    /// Supported types of visual presentations
    enum ItemType {
        case banner(BannerItem)
        case modal(ModalItem)
        case jit(JitItem)
        case preference(PreferenceItem)
    }
}

extension KetchUI.PresentationItem.ItemType {
    /// Internal implementation of Banner PresentationItem that contains possible actions handler
    struct BannerItem {
        let config: KetchSDK.Configuration.Experience.ConsentExperience.Banner
        let localizedStrings: KetchSDK.Configuration.Translations?
        let actionHandler: (Action) -> KetchUI.PresentationItem?

        enum Action {
            case openUrl(URL)
            case primary
            case secondary
            case close
        }
    }

    /// Internal implementation of Modal PresentationItem that contains possible actions handler
    struct ModalItem {
        let config: KetchSDK.Configuration.Experience.ConsentExperience.Modal
        let localizedStrings: KetchSDK.Configuration.Translations?
        let actionHandler: (Action) -> KetchUI.PresentationItem?

        enum Action {
            case openUrl(URL)
            case save(purposesConsent: KetchSDK.ConsentStatus)
            case close
        }
    }

    /// Internal implementation of Just In Time PresentationItem that contains possible actions handler
    struct JitItem {
        let config: KetchSDK.Configuration.Experience.ConsentExperience.JIT
        let localizedStrings: KetchSDK.Configuration.Translations?
        let purpose: KetchSDK.Configuration.Purpose
        let actionHandler: (Action) -> KetchUI.PresentationItem?

        enum Action {
            case openUrl(URL)
            case save(purposeCode: String, consent: Bool, vendors: [String]?)
            case moreInfo
            case close
        }
    }

    /// Internal implementation of Preference PresentationItem that contains possible actions handler
    struct PreferenceItem {
        let config: KetchSDK.Configuration.PreferenceExperience
        let localizedStrings: KetchSDK.Configuration.Translations?
        let actionHandler: (Action) -> KetchUI.PresentationItem?

        enum Action {
            case onShow
            case openUrl(URL)
            case save(purposesConsent: KetchSDK.ConsentStatus)
            case request(right: DataRightCoding, user: UserDataCoding)
            case close
        }
    }
}

extension KetchUI.PresentationItem {
    /// Static builder method for generating ready PresentationItem according Banner type setup
    /// - Parameters:
    ///   - bannerConfig: Banner model received from platform
    ///   - config: Config defined in consumed Ketch dependency
    ///   - consent: Current Consent status in consumed Ketch dependency
    ///   - actionHandler: PresentationItem actions handling for Banner
    /// - Returns: PresentationItem ready to consume by client
    static func banner(
        bannerConfig: KetchSDK.Configuration.Experience.ConsentExperience.Banner,
        config: KetchSDK.Configuration,
        localizedStrings: KetchSDK.Configuration.Translations?,
        consent: KetchSDK.ConsentStatus,
        actionHandler: @escaping (ItemType.BannerItem.Action) -> KetchUI.PresentationItem?
    ) -> Self {
        Self(
            itemType: .banner(
                ItemType.BannerItem(
                    config: bannerConfig,
                    localizedStrings: localizedStrings,
                    actionHandler: actionHandler
                )
            ),
            config: config,
            consent: consent,
            localizedStrings: localizedStrings
        )
    }

    /// Static builder method for generating ready PresentationItem according Modal type setup
    /// - Parameters:
    ///   - modalConfig: Modal model received from platform
    ///   - config: Config defined in consumed Ketch dependency
    ///   - consent: Current Consent status in consumed Ketch dependency
    ///   - actionHandler: PresentationItem actions handling for Modal
    /// - Returns: PresentationItem ready to consume by client
    static func modal(
        modalConfig: KetchSDK.Configuration.Experience.ConsentExperience.Modal,
        config: KetchSDK.Configuration,
        localizedStrings: KetchSDK.Configuration.Translations?,
        consent: KetchSDK.ConsentStatus,
        actionHandler: @escaping (ItemType.ModalItem.Action) -> KetchUI.PresentationItem?
    ) -> Self {
        Self(
            itemType: .modal(
                ItemType.ModalItem(
                    config: modalConfig,
                    localizedStrings: localizedStrings,
                    actionHandler: actionHandler
                )
            ),
            config: config,
            consent: consent,
            localizedStrings: localizedStrings
        )
    }

    /// Static builder method for generating ready PresentationItem according Preference type setup
    /// - Parameters:
    ///   - preferenceConfig: Preference model received from platform
    ///   - config: Config defined in consumed Ketch dependency
    ///   - consent: Current Consent status in consumed Ketch dependency
    ///   - actionHandler: PresentationItem actions handling for Preference
    /// - Returns: PresentationItem ready to consume by client
    static func preference(
        preferenceConfig: KetchSDK.Configuration.PreferenceExperience,
        config: KetchSDK.Configuration,
        localizedStrings: KetchSDK.Configuration.Translations?,
        consent: KetchSDK.ConsentStatus,
        actionHandler: @escaping (ItemType.PreferenceItem.Action) -> KetchUI.PresentationItem?
    ) -> Self {
        Self(
            itemType: .preference(
                ItemType.PreferenceItem(
                    config: preferenceConfig,
                    localizedStrings: localizedStrings,
                    actionHandler: actionHandler
                )
            ),
            config: config,
            consent: consent,
            localizedStrings: localizedStrings
        )
    }

    /// Static builder method for generating ready PresentationItem according Just In Time type setup
    /// - Parameters:
    ///   - jitConfig: Preference model received from platform
    ///   - config: Config defined in consumed Ketch dependency
    ///   - purpose: Purpose for which user should be asked
    ///   - consent: Current Consent status in consumed Ketch dependency
    ///   - actionHandler: PresentationItem actions handling for Just In Time
    /// - Returns: PresentationItem ready to consume by client
    static func jit(
        jitConfig: KetchSDK.Configuration.Experience.ConsentExperience.JIT,
        config: KetchSDK.Configuration,
        localizedStrings: KetchSDK.Configuration.Translations?,
        purpose: KetchSDK.Configuration.Purpose,
        consent: KetchSDK.ConsentStatus,
        actionHandler: @escaping (ItemType.JitItem.Action) -> KetchUI.PresentationItem?
    ) -> Self {
        Self(
            itemType: .jit(
                ItemType.JitItem(
                    config: jitConfig,
                    localizedStrings: localizedStrings,
                    purpose: purpose,
                    actionHandler: actionHandler
                )
            ),
            config: config,
            consent: consent,
            localizedStrings: localizedStrings
        )
    }
}
