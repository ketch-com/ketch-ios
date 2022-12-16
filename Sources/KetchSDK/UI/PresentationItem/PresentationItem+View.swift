//
//  PresentationItem+View.swift
//  KetchSDK
//
//  Created by Anton Lyfar on 14.12.2022.
//

import SwiftUI

extension KetchUI.PresentationItem {
    @ViewBuilder
    public var content: some View {
        switch itemType {
        case .banner(let bannerItem): banner(item: bannerItem)
        case .modal(let modalItem): modal(item: modalItem)
        case .jit(let jitItem): jit(item: jitItem)
        case .preference(let preferenceItem): preference(item: preferenceItem)
        }
    }

    private func banner(item: ItemType.BannerItem) -> some View {
        let theme = Props.Banner.Theme(with: config.theme)

        var primaryButton: Props.Button?
        var secondaryButton: Props.Button?

        if item.config.buttonText.isEmpty == false {
            primaryButton = .init(text: item.config.buttonText, theme: theme.primaryButtonTheme)
        }

        if
            let secondaryButtonText = item.config.secondaryButtonText,
            secondaryButtonText.isEmpty == false
        {
            secondaryButton = .init(text: secondaryButtonText, theme: theme.secondaryButtonTheme)
        }

        let bannerProps = Props.Banner(
            title: item.config.title ?? String(),
            text: item.config.footerDescription,
            primaryButton: primaryButton,
            secondaryButton: secondaryButton,
            theme: theme
        )

        return BannerView(props: bannerProps, actionHandler: handleAction(for: item))
            .asResponsiveSheet(style: .bottomSheet(backgroundColor: theme.backgroundColor))
    }

    private func modal(item: ItemType.ModalItem) -> some View {
        let theme = Props.Modal.Theme(with: config.theme)

        let hideConsentTitle = item.config.hideConsentTitle ?? false

        let purposesProps = Props.PurposesList(
            bodyTitle: item.config.bodyTitle ?? String(),
            bodyDescription: item.config.bodyDescription ?? String(),
            consentTitle: hideConsentTitle ? nil : item.config.consentTitle,
            hideConsentTitle: hideConsentTitle,
            hideLegalBases: item.config.hideLegalBases ?? false,
            purposes: config.purposes,
            vendors: config.vendors,
            purposesConsent: consent.purposes,
            vendorsConsent: consent.vendors,
            theme: theme.purposesListTheme
        )

        let buttonProps = Props.Button(
            text: item.config.buttonText,
            theme: theme.firstButtonTheme
        )

        let modalProps = Props.Modal(
            title: item.config.title,
            showCloseIcon: item.config.showCloseIcon ?? false,
            purposes: purposesProps,
            saveButton: buttonProps,
            theme: theme
        )

        return ModalView(props: modalProps, actionHandler: handleAction(for: item))
            .asResponsiveSheet(style: .popUp)
    }

    private func jit(item: ItemType.JitItem) -> some View {
        let theme = Props.Jit.Theme(with: config.theme)

        let purpose = Props.Purpose(
            with: item.purpose,
            consent: false,
            legalBasisName: item.purpose.legalBasisName,
            legalBasisDescription: item.purpose.legalBasisDescription
        )

        let vendors = config.vendors?.map { vendor in
            Props.Vendor(
                with: vendor,
                consent: consent.vendors?.contains(vendor.id) ?? false
            )
        }

        let jitProps = Props.Jit(
            title: item.config.title,
            showCloseIcon: item.config.showCloseIcon ?? false,
            description: item.config.bodyDescription,
            purpose: purpose,
            vendors: vendors ?? [],
            acceptButtonText: item.config.acceptButtonText,
            declineButtonText: item.config.declineButtonText,
            moreInfoText: item.config.moreInfoText,
            moreInfoDestinationEnabled: item.config.moreInfoDestination != nil,
            theme: theme
        )

        return JitView(props: jitProps, actionHandler: handleAction(for: item))
            .asResponsiveSheet(style: .popUp)
    }

    private func preference(item: ItemType.PreferenceItem) -> some View {
        let theme = Props.Preference.Theme(with: config.theme)

        let purposesProps = Props.PurposesList(
            bodyTitle: item.config.consents.bodyTitle ?? String(),
            bodyDescription: item.config.consents.bodyDescription ?? String(),
            consentTitle: "Purposes",
            purposes: config.purposes,
            vendors: config.vendors,
            purposesConsent: consent.purposes,
            vendorsConsent: consent.vendors,
            theme: theme.purposesListTheme
        )

        let preferenceProps = Props.Preference(
            title: item.config.title,
            overview: .init(
                tabName: item.config.overview.tabName,
                title: item.config.overview.bodyTitle,
                text: item.config.overview.bodyDescription
            ),
            consents: .init(
                tabName: item.config.consents.tabName,
                buttonText: item.config.consents.buttonText,
                purposes: purposesProps
            ),
            rights: .init(
                tabName: item.config.rights.tabName,
                title: item.config.rights.bodyTitle,
                text: item.config.rights.bodyDescription,
                buttonText: item.config.rights.buttonText,
                rights: config.rights?.map(\.props) ?? []
            ),
            theme: theme
        )

        return PreferenceView(props: preferenceProps, actionHandler: handleAction(for: item))
            .asResponsiveSheet(style: .screenCover)
    }

    // MARK: - Actions processing -
    private func handleAction(
        for item: ItemType.BannerItem
    ) -> ((BannerView.Action) -> KetchUI.PresentationItem?) {
        { action in
            switch action {
            case .primary: return item.actionHandler(.primary)
            case .secondary: return item.actionHandler(.secondary)
            case .close: return nil
            case .openUrl(let url): return item.actionHandler(.openUrl(url))
            }
        }
    }

    private func handleAction(
        for item: ItemType.ModalItem
    ) -> ((ModalView.Action) -> KetchUI.PresentationItem?) {
        { action in
            switch action {
            case .save(let purposesConsent, let vendors):
                return item.actionHandler(
                    .save(
                        purposesConsent: KetchSDK.ConsentStatus(
                            purposes: purposesConsent,
                            vendors: vendors
                        )
                    )
                )

            case .close: return nil
            case .openUrl(let url): return item.actionHandler(.openUrl(url))
            }
        }
    }

    private func handleAction(
        for item: ItemType.JitItem
    ) -> ((JitView.Action) -> KetchUI.PresentationItem?) {
        { action in
            switch action {
            case .moreInfo: return item.actionHandler(.moreInfo)
            case .close: return nil
            case .openUrl(let url): return item.actionHandler(.openUrl(url))
            case .save(purposeCodeConsent: let purposeCodeConsent, vendors: let vendors):
                return item.actionHandler(
                    .save(
                        purposeCode: item.purpose.code,
                        consent: purposeCodeConsent,
                        vendors: vendors
                    )
                )
            }
        }
    }

    private func handleAction(
        for item: ItemType.PreferenceItem
    ) -> ((PreferenceView.Action) -> KetchUI.PresentationItem?) {
        { action in
            switch action {
            case .save(let purposesConsent, let vendors):
                return item.actionHandler(
                    .save(
                        purposesConsent: KetchSDK.ConsentStatus(
                            purposes: purposesConsent,
                            vendors: vendors
                        )
                    )
                )

            case .close: return nil
            case .openUrl(let url): return item.actionHandler(.openUrl(url))
            case .request(let right, let user): return item.actionHandler(.request(right: right, user: user))
            }
        }
    }
}

extension KetchUI.PresentationItem {
    enum Link {
        case url(URL)
        case triggerModal
        case privacyPolicy
        case termsOfService

        init(rawValue: URL) {
            switch rawValue.absoluteString {
            case "triggerModal": self = .triggerModal
            case "privacyPolicy": self = .privacyPolicy
            case "termsOfService": self = .termsOfService
            default: self = .url(rawValue)
            }
        }
    }
}
