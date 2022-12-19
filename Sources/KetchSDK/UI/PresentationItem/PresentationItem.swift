//
//  PresentationItem.swift
//  KetchSDK
//

import SwiftUI

extension KetchUI {
    public struct PresentationItem: Identifiable {
        let itemType: ItemType
        let config: KetchSDK.Configuration
        let consent: KetchSDK.ConsentStatus

        public var id: String { String(describing: itemType) }
    }
}

extension KetchUI.PresentationItem {
    enum ItemType {
        case banner(BannerItem)
        case modal(ModalItem)
        case jit(JitItem)
        case preference(PreferenceItem)

    }
}

extension KetchUI.PresentationItem.ItemType {
    struct BannerItem {
        let config: KetchSDK.Configuration.Experience.ConsentExperience.Banner
        let actionHandler: (Action) -> KetchUI.PresentationItem?

        enum Action {
            case openUrl(URL)
            case primary
            case secondary
            case close
        }
    }

    struct ModalItem {
        let config: KetchSDK.Configuration.Experience.ConsentExperience.Modal
        let actionHandler: (Action) -> KetchUI.PresentationItem?

        enum Action {
            case openUrl(URL)
            case save(purposesConsent: KetchSDK.ConsentStatus)
            case close
        }
    }

    struct JitItem {
        let config: KetchSDK.Configuration.Experience.ConsentExperience.JIT
        let purpose: KetchSDK.Configuration.Purpose
        let actionHandler: (Action) -> KetchUI.PresentationItem?

        enum Action {
            case openUrl(URL)
            case save(purposeCode: String, consent: Bool, vendors: [String]?)
            case moreInfo
            case close
        }
    }

    struct PreferenceItem {
        let config: KetchSDK.Configuration.PreferenceExperience
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
    static func banner(
        bannerConfig: KetchSDK.Configuration.Experience.ConsentExperience.Banner,
        config: KetchSDK.Configuration,
        consent: KetchSDK.ConsentStatus,
        actionHandler: @escaping (ItemType.BannerItem.Action) -> KetchUI.PresentationItem?
    ) -> Self {
        Self(
            itemType: .banner(
                ItemType.BannerItem(
                    config: bannerConfig,
                    actionHandler: actionHandler
                )
            ),
            config: config,
            consent: consent
        )
    }

    static func modal(
        modalConfig: KetchSDK.Configuration.Experience.ConsentExperience.Modal,
        config: KetchSDK.Configuration,
        consent: KetchSDK.ConsentStatus,
        actionHandler: @escaping (ItemType.ModalItem.Action) -> KetchUI.PresentationItem?
    ) -> Self {
        Self(
            itemType: .modal(
                ItemType.ModalItem(
                    config: modalConfig,
                    actionHandler: actionHandler
                )
            ),
            config: config,
            consent: consent
        )
    }

    static func preference(
        preferenceConfig: KetchSDK.Configuration.PreferenceExperience,
        config: KetchSDK.Configuration,
        consent: KetchSDK.ConsentStatus,
        actionHandler: @escaping (ItemType.PreferenceItem.Action) -> KetchUI.PresentationItem?
    ) -> Self {
        Self(
            itemType: .preference(
                ItemType.PreferenceItem(
                    config: preferenceConfig,
                    actionHandler: actionHandler
                )
            ),
            config: config,
            consent: consent
        )
    }

    static func jit(
        jitConfig: KetchSDK.Configuration.Experience.ConsentExperience.JIT,
        config: KetchSDK.Configuration,
        purpose: KetchSDK.Configuration.Purpose,
        consent: KetchSDK.ConsentStatus,
        actionHandler: @escaping (ItemType.JitItem.Action) -> KetchUI.PresentationItem?
    ) -> Self {
        Self(
            itemType: .jit(
                ItemType.JitItem(
                    config: jitConfig,
                    purpose: purpose,
                    actionHandler: actionHandler
                )
            ),
            config: config,
            consent: consent
        )
    }
}
