//
//  KetchUI.swift
//  KetchSDK
//
//  Created by Anton Lyfar on 08.11.2022.
//

import SwiftUI
import Combine

public class KetchUI: ObservableObject {
    @Published public var presentationItem: PresentationItem?

    private let ketch: Ketch

    private var subscriptions = Set<AnyCancellable>()
    private var configuration: KetchSDK.Configuration?
    private var consentStatus: KetchSDK.ConsentStatus?

    public init(ketch: Ketch) {
        self.ketch = ketch

        bindInput()
    }

    public func bindInput() {
        ketch.configurationPublisher
            .replaceError(with: nil)
            .sink { configuration in
                self.configuration = configuration
            }
            .store(in: &subscriptions)

        ketch.consentPublisher
            .replaceError(with: nil)
            .sink { consentStatus in
                self.consentStatus = consentStatus
            }
            .store(in: &subscriptions)
    }

    public func showBanner() {
        guard
            let configuration,
            let consentStatus,
            let banner = configuration.experiences?.consent?.banner
        else { return }

        presentationItem = PresentationItem.banner(
            bannerConfig: banner,
            config: configuration,
            consent: consentStatus
        ) { action in
            switch action {
            case .primary:
                if let primaryButtonAction = banner.primaryButtonAction {
                    switch primaryButtonAction {
                    case .saveCurrentState: self.saveConsentState(configuration: configuration, consentStatus: consentStatus)
                    case .acceptAll: self.acceptAll(configuration: configuration)
                    }
                }

            case .secondary:
                if let secondaryButtonDestination = banner.secondaryButtonDestination {
                    switch secondaryButtonDestination {
                    case .gotoModal: self.showModal()
                    case .gotoPreference: break
                    case .rejectAll: self.rejectAll(configuration: configuration)
                    }
                }
            }
        }
    }

    public func showModal() {
        guard
            let configuration,
            let consentStatus,
            let modal = configuration.experiences?.consent?.modal
        else { return }

        presentationItem = PresentationItem.modal(
            modalConfig: modal,
            config: configuration,
            consent: consentStatus
        ) { action in
            switch action {
            case .save(let purposesConsent):
                self.saveConsentState(configuration: configuration, consentStatus: purposesConsent)
            }
        }
    }

    public func showJIT() {
        guard
            let configuration,
            let consentStatus
        else { return }

        presentationItem = PresentationItem(
            itemType: .jit,
            config: configuration,
            consent: consentStatus
        )
    }

    public func showPreference() {
        guard
            let configuration,
            let consentStatus,
            let preference = configuration.experiences?.preference

        else { return }

        presentationItem = PresentationItem.preference(
            preferenceConfig: preference,
            config: configuration,
            consent: consentStatus
        ) { action in
            switch action {
            case .save(let purposesConsent):
                self.saveConsentState(configuration: configuration, consentStatus: purposesConsent)
            case .request(let right, let user):
                self.invokeRight(right: right.configRight, user: user.configUserData)
            }
        }
    }
}

extension KetchUI {
    private func acceptAll(configuration: KetchSDK.Configuration) {
        let purposes = configuration.purposes?
            .reduce(into: [String: KetchSDK.ConsentUpdate.PurposeAllowedLegalBasis]()) { result, purpose in
                result[purpose.code] = KetchSDK.ConsentUpdate.PurposeAllowedLegalBasis(
                    allowed: true,
                    legalBasisCode: purpose.legalBasisCode
                )
            }

        let vendors = configuration.vendors?.map(\.id)

        ketch.updateConsent(purposes: purposes, vendors: vendors)
        ketch.updateConsentVersion(version: configuration.experiences?.consent?.version)
    }

    private func rejectAll(configuration: KetchSDK.Configuration) {
        let purposes = configuration.purposes?
            .reduce(into: [String: KetchSDK.ConsentUpdate.PurposeAllowedLegalBasis]()) { result, purpose in
                result[purpose.code] = KetchSDK.ConsentUpdate.PurposeAllowedLegalBasis(
                    allowed: false,
                    legalBasisCode: purpose.legalBasisCode
                )
            }

        let vendors = [String]()

        ketch.updateConsent(purposes: purposes, vendors: vendors)
        ketch.updateConsentVersion(version: configuration.experiences?.consent?.version)
    }

    private func saveConsentState(configuration: KetchSDK.Configuration, consentStatus: KetchSDK.ConsentStatus) {
        let purposes = configuration.purposes?
            .reduce(into: [String: KetchSDK.ConsentUpdate.PurposeAllowedLegalBasis]()) { result, purpose in
                result[purpose.code] = KetchSDK.ConsentUpdate.PurposeAllowedLegalBasis(
                    allowed: consentStatus.purposes[purpose.code] ?? true,
                    legalBasisCode: purpose.legalBasisCode
                )
            }

        let vendors = consentStatus.vendors

        ketch.updateConsent(purposes: purposes, vendors: vendors)
    }

    private func invokeRight(right: KetchSDK.Configuration.Right, user: KetchSDK.InvokeRightConfig.User) {
        ketch.invokeRights(right: right.code, user: user)
    }
}
