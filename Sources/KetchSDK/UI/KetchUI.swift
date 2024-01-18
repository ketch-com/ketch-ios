//
//  KetchUI.swift
//  KetchSDK
//

import SwiftUI
import Combine
import WebKit

/// Container for UI features
public final class KetchUI: ObservableObject {
    /// Stream of UI dialogs required to show
    @Published public var webPresentationItem: WebPresentationItem?
    
    /// Stream of UI dialogs required to show
    @Published public var presentationItem: PresentationItem?

    /// Configuration updates stream
    /// Reflected from Ketch dependency
    @Published public var configuration: KetchSDK.Configuration?
    
    /// Localized Strings updates stream
    /// Reflected from Ketch dependency
    @Published public var localizedStrings: KetchSDK.LocalizedStrings?

    /// Consent updates stream
    /// Reflected from Ketch dependency
    @Published public var consentStatus: KetchSDK.ConsentStatus?

    public var showDialogsIfNeeded = false

    private var ketch: Ketch
    private var subscriptions = Set<AnyCancellable>()

    /// Instantiation of UI dialogs
    /// - Parameter ketch: Instance of Ketch that will provide request and storage services,
    /// protocol plugins updates
    public init(ketch: Ketch) {
        self.ketch = ketch

        bindInput()
    }

    public func bindInput() {
        preloadWebExperience()
        
        ketch.$configuration
            .sink { configuration in
                self.configuration = configuration
            }
            .store(in: &subscriptions)
        
        ketch.$localizedStrings
            .sink { localizedStrings in
                self.localizedStrings = localizedStrings
            }
            .store(in: &subscriptions)

        ketch.$consent
            .sink { consentStatus in
                self.consentStatus = consentStatus
                if self.showDialogsIfNeeded {
                    self.showConsentExperience()
                }
            }
            .store(in: &subscriptions)
    }
    
    private var preloadedPresentationItem: WebPresentationItem?
    private var preloaded: WKWebView?

    private func preloadWebExperience() {
        preloadedPresentationItem = webExperience()
        preloaded = preloadedPresentationItem?.config.preferencesWebView(onClose: { self.webPresentationItem = nil })
    }
}

// MARK: - Direct trigger of dialog item presentation
extension KetchUI {
    public func reload() {
        preloaded = preloadedPresentationItem?.config.preferencesWebView(onClose: { self.webPresentationItem = nil })
    }
    
    public func showExperience(presentationConfig: WebPresentationItem.PresentationConfig? = nil) {
        preloadedPresentationItem?.preloaded = preloaded
        preloadedPresentationItem?.presentationConfig = presentationConfig
        webPresentationItem = preloadedPresentationItem
    }
    
    public func showBanner() {
        presentationItem = banner()
    }

    public func showModal() {
        presentationItem = modal()
    }

    public func showJIT(purpose: KetchSDK.Configuration.Purpose) {
        presentationItem = jit(purpose: purpose)
    }

    public func showPreference() {
        presentationItem = preference()
    }
}

// MARK: - Dialog presentation item generation of each type
extension KetchUI {
    private func webExperience() -> WebPresentationItem? {
        guard
            let advertisingIdentifier = ketch.identities.compactMap({
                if case .idfa(let id) = $0 {
                    return id
                }
                
                return nil
            }).first,
            let uuid = UUID(uuidString: advertisingIdentifier)
        else { return nil }
        
        return .init(
            item: WebPresentationItem.WebExperienceItem(
                orgCode: ketch.organizationCode,
                propertyName: ketch.propertyCode,
                advertisingIdentifier: uuid
            )
        )
    }
    
    private func banner() -> PresentationItem? {
        guard
            let configuration,
            let consentStatus,
            let localizedStrings,
            let banner = configuration.experiences?.consent?.banner
        else { return nil }

        return .banner(
            bannerConfig: banner,
            config: configuration,
            localizedStrings: localizedStrings,
            consent: consentStatus,
            actionHandler: { [weak self] action in
                self?.actionHandler(action)
            }
        )
    }

    private func modal() -> PresentationItem? {
        guard
            let configuration,
            let consentStatus,
            let localizedStrings,
            let modal = configuration.experiences?.consent?.modal
        else { return nil }

        return .modal(
            modalConfig: modal,
            config: configuration,
            localizedStrings: localizedStrings,
            consent: consentStatus,
            actionHandler: { [weak self] action in
                self?.actionHandler(action)
            }
        )
    }

    private func jit(purpose: KetchSDK.Configuration.Purpose) -> PresentationItem? {
        guard
            let configuration,
            let consentStatus,
            let localizedStrings,
            let jit = configuration.experiences?.consent?.jit
        else { return nil }

        return .jit(
            jitConfig: jit,
            config: configuration,
            localizedStrings: localizedStrings,
            purpose: purpose,
            consent: consentStatus,
            actionHandler: { [weak self] action in
                self?.actionHandler(action)
            }
        )
    }

    private func preference() -> PresentationItem? {
        guard
            let configuration,
            let consentStatus,
            let localizedStrings,
            let preference = configuration.experiences?.preference
        else { return nil }

        return .preference(
            preferenceConfig: preference,
            config: configuration,
            localizedStrings: localizedStrings,
            consent: consentStatus,
            actionHandler: { [weak self] action in
                self?.actionHandler(action, preferenceVersion: preference.version)
            }
        )
    }

    /// Generating child dialog according to triggered url on presentation
    /// - Parameter url: url from Item config
    /// - Returns: PresentationItem if action triggered internal dialog transition,
    /// otherwise is nil (nothing to show as child)
    private func child(with url: URL) -> PresentationItem? {
        let externalUrlString: String?
        switch PresentationItem.Link(rawValue: url) {
        case .triggerModal:
            return modal()

        case .url(let urlToOpen):
            UIApplication.shared.open(urlToOpen)
            return nil

        case .privacyPolicy:
            externalUrlString = configuration?.privacyPolicy?.url

        case .termsOfService:
            externalUrlString = configuration?.termsOfService?.url
        }

        if let externalUrlString, let externalUrl = URL(string: externalUrlString) {
            UIApplication.shared.open(externalUrl)
        }

        return nil
    }
}

// MARK: - action handlers for presentation item of each type
extension KetchUI {
    private func actionHandler(_ action: PresentationItem.ItemType.BannerItem.Action) -> PresentationItem? {
        switch action {
        case .close: if shouldShowPreference { showPreference() }

        case .openUrl(let url): return child(with: url)

        case .primary:
            if let configuration = configuration,
               let consentStatus = consentStatus,
               let banner = configuration.experiences?.consent?.banner,
               let primaryButtonAction = banner.primaryButtonAction {
                switch primaryButtonAction {
                case .saveCurrentState: saveConsentState(configuration: configuration, consentStatus: consentStatus)
                case .acceptAll: acceptAll(configuration: configuration)
                }
            }

        case .secondary:
            if let configuration = configuration,
               let banner = configuration.experiences?.consent?.banner,
               let secondaryButtonDestination = banner.secondaryButtonDestination {
                switch secondaryButtonDestination {
                case .gotoModal: return modal()
                case .gotoPreference: return preference()
                case .rejectAll: rejectAll(configuration: configuration)
                }
            }
        }

        return nil
    }

    private func actionHandler(_ action: PresentationItem.ItemType.ModalItem.Action) -> PresentationItem? {
        switch action {
        case .close: if shouldShowPreference { showPreference() }

        case .openUrl(let url): return child(with: url)

        case .save(let purposesConsent):
            if let configuration = configuration {
                self.saveConsentState(configuration: configuration, consentStatus: purposesConsent)
            }
        }

        return nil
    }

    private func actionHandler(_ action: PresentationItem.ItemType.JitItem.Action) -> PresentationItem? {
        switch action {
        case .close: break

        case .openUrl(let url): return child(with: url)

        case .save(let purposeCode, let consent, let vendors):
            if let configuration = configuration {
                var purposes = consentStatus?.purposes ?? [:]
                purposes[purposeCode] = consent
                let purposesConsent = KetchSDK.ConsentStatus(purposes: purposes, vendors: vendors)

                saveConsentState(configuration: configuration, consentStatus: purposesConsent)
            }

        case .moreInfo:
            if let configuration = configuration,
               let jit = configuration.experiences?.consent?.jit,
               let moreInfoDestination = jit.moreInfoDestination {
                switch moreInfoDestination {
                case .gotoModal: return modal()
                case .gotoPreference: return preference()
                case .rejectAll: rejectAll(configuration: configuration)
                }
            }
        }

        return nil
    }

    private func actionHandler(
        _ action: PresentationItem.ItemType.PreferenceItem.Action,
        preferenceVersion: Int
    ) -> PresentationItem? {
        switch action {
        case .onShow: ketch.updatePreferenceVersion(version: preferenceVersion)

        case .close: break

        case .openUrl(let url): return child(with: url)

        case .save(let purposesConsent):
            if let configuration = configuration {
                saveConsentState(configuration: configuration, consentStatus: purposesConsent)
            }

        case .request(let right, let user):
            ketch.invokeRights(right: right.configRight, user: user.configUserData)
        }

        return nil
    }
}

// MARK: - Dialog result handling according corresponding experience config
extension KetchUI {
    private func showConsentExperience() {
        if let defaultExperience = configuration?.experiences?.consent?.experienceDefault {
            switch defaultExperience {
            case .banner:
                if shouldShowBanner { showBanner() }
                else if shouldShowPreference { showPreference() }

            case .modal:
                if shouldShowModal { showModal() }
                else if shouldShowPreference { showPreference() }
            }
        }
    }

    private var shouldShowBanner: Bool {
        guard let consentVersion = ketch.getConsentVersion() else { return true }

        return consentVersion != configuration?.experiences?.consent?.version
    }

    private var shouldShowModal: Bool {
        guard let consentVersion = ketch.getConsentVersion() else { return true }

        if consentVersion != configuration?.experiences?.consent?.version { return true }

        return shouldShowConsent
    }

    private var shouldShowPreference: Bool {
        guard let preferenceVersion = ketch.getPreferenceVersion() else { return true }

        if preferenceVersion != configuration?.experiences?.preference?.version { return true }

        guard let consentVersion = ketch.getConsentVersion() else { return true }

        if consentVersion != configuration?.experiences?.consent?.version { return true }

        return shouldShowConsent
    }

    private var shouldShowConsent: Bool {
        configuration?.purposes?.contains { purpose in
            consentStatus?.purposes.first(where: { $0.key == purpose.code })?.value == nil
        } ?? false
    }
}

// MARK: - Consent action result handling according corresponding experience config
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
        ketch.updateConsentVersion(version: configuration.experiences?.consent?.version)
    }
}
