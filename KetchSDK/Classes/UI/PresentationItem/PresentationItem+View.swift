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
            purpose: nil,
            vendors: vendors,
            acceptButtonText: item.config.acceptButtonText,
            declineButtonText: item.config.declineButtonText,
            moreInfoText: item.config.moreInfoText,
            moreInfoDestination: {
                guard let moreInfoDestination = item.config.moreInfoDestination else { return nil }
                switch moreInfoDestination {
                case .gotoModal: return Props.Destination.modal
                case .gotoPreference: return Props.Destination.preference
                case .rejectAll: return Props.Destination.rejectAll
                }
            }(),
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

    private func child(with url: URL) -> Self? {
        switch url.absoluteString {
            //            case "triggerModal", "privacyPolicy", "termsOfService":
            //                return .init(
            //                    itemType: .modal(),
            //                    config: config,
            //                    consent: consent
            //                ) { _ in }

        default:
            UIApplication.shared.open(url)
            return nil
        }
    }

    // MARK: - Actions processing -
    private func handleAction(
        for item: ItemType.BannerItem
    ) -> ((BannerView.Action) -> KetchUI.PresentationItem?) {
        { action in
            switch action {
            case .primary: item.actionHandler(.primary)
            case .secondary: item.actionHandler(.secondary)
            case .close: break
            case .openUrl(let url): return child(with: url)
            }

            return nil
        }
    }

    private func handleAction(
        for item: ItemType.ModalItem
    ) -> ((ModalView.Action) -> KetchUI.PresentationItem?) {
        { action in
            switch action {
            case .save(let purposesConsent, let vendors):
                item.actionHandler(
                    .save(
                        purposesConsent: KetchSDK.ConsentStatus(
                            purposes: purposesConsent,
                            vendors: vendors
                        )
                    )
                )

            case .close: break
            case .openUrl(let url): return child(with: url)
            }

            return nil
        }
    }

    private func handleAction(
        for item: ItemType.JitItem
    ) -> ((JitView.Action) -> KetchUI.PresentationItem?) {
        { action in
            switch action {
            case .close: break
            case .openUrl(let url): return child(with: url)
            }

            return nil
        }
    }

    private func handleAction(
        for item: ItemType.PreferenceItem
    ) -> ((PreferenceView.Action) -> KetchUI.PresentationItem?) {
        { action in
            switch action {
            case .save(let purposesConsent, let vendors):
                item.actionHandler(
                    .save(
                        purposesConsent: KetchSDK.ConsentStatus(
                            purposes: purposesConsent,
                            vendors: vendors
                        )
                    )
                )

            case .close: break
            case .openUrl(let url): return child(with: url)
            case .request(let right, let user): item.actionHandler(.request(right: right, user: user))
            }

            return nil
        }
    }
}
