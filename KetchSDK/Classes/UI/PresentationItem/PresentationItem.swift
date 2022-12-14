//
//  PresentationItem.swift
//  KetchSDK
//
//  Created by Anton Lyfar on 10.11.2022.
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
        let actionHandler: (Action) -> Void

        enum Action {
            case primary
            case secondary
        }
    }

    struct ModalItem {
        let config: KetchSDK.Configuration.Experience.ConsentExperience.Modal
        let actionHandler: (Action) -> Void

        enum Action {
            case save(purposesConsent: KetchSDK.ConsentStatus)
        }
    }

    struct JitItem {
        let config: KetchSDK.Configuration.Experience.ConsentExperience.JIT
        let actionHandler: (Action) -> Void

        enum Action {

        }
    }

    struct PreferenceItem {
        let config: KetchSDK.Configuration.PreferenceExperience
        let actionHandler: (Action) -> Void

        enum Action {
            case save(purposesConsent: KetchSDK.ConsentStatus)
            case request(right: DataRightCoding, user: UserDataCoding)
        }
    }
}

extension KetchUI.PresentationItem {
    static func banner(
        bannerConfig: KetchSDK.Configuration.Experience.ConsentExperience.Banner,
        config: KetchSDK.Configuration,
        consent: KetchSDK.ConsentStatus,
        actionHandler: @escaping (ItemType.BannerItem.Action) -> Void
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
        actionHandler: @escaping (ItemType.ModalItem.Action) -> Void
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
        actionHandler: @escaping (ItemType.PreferenceItem.Action) -> Void
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
        consent: KetchSDK.ConsentStatus,
        actionHandler: @escaping (ItemType.JitItem.Action) -> Void
    ) -> Self {
        Self(
            itemType: .jit(
                ItemType.JitItem(
                    config: jitConfig,
                    actionHandler: actionHandler
                )
            ),
            config: config,
            consent: consent
        )
    }
}
