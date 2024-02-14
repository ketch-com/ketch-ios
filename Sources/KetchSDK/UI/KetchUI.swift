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

    /// Configuration updates stream
    /// Reflected from Ketch dependency
    @Published public var configuration: KetchSDK.Configuration?
    
    /// Localized Strings updates stream
    /// Reflected from Ketch dependency
    @Published public var localizedStrings: KetchSDK.LocalizedStrings?

    /// Consent updates stream
    /// Reflected from Ketch dependency
    @Published public var consentStatus: KetchSDK.ConsentStatus?

    public weak var eventListener: KetchEventListener?

    private(set) public var ketch: Ketch
    private var subscriptions = Set<AnyCancellable>()
    private var options = [ExperienceOption]()
    private var isConfigLoaded = false
    private var experienceToShow: KetchUI.WebPresentationItem.Event.Content?

    /// Instantiation of UI dialogs
    /// - Parameter ketch: Instance of Ketch that will provide request and storage services,
    /// protocol plugins updates
    public init(ketch: Ketch, experienceOptions options: [ExperienceOption] = []) {
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
            }
            .store(in: &subscriptions)
    }
    
    private var preloadedPresentationItem: WebPresentationItem?

    private func preloadWebExperience() {
        preloadedPresentationItem = webExperience(onEvent: handle)
        preloadedPresentationItem?.reload(options: options)
    }
    
    private func handle(webPresentationEvent: WebPresentationItem.Event) {
        switch webPresentationEvent {
        case .onClose:
            didCloseExperience()
            
        case .show(let content):
            switch content {
            case .consent: eventListener?.showConsent()
            case .preference: eventListener?.showPreferences()
            }
            
            if isConfigLoaded {
                self.showExperience()
            }
            
        case .tapOutside:
            if display == .banner {
                if ketch.configuration?.theme?.banner?.container?.backdrop.disableContentInteractions == false {
                    didCloseExperience()
                }
            } else if display == .modal {
                if ketch.configuration?.theme?.modal?.container?.backdrop.disableContentInteractions == false {
                    didCloseExperience()
                }
            }
            
        case .configurationLoaded(let configuration):
            self.ketch.configuration = configuration
            eventListener?.onConfigUpdated(config: configuration)
            
            isConfigLoaded = true
            
            if let experienceToShow {
                showExperience()
                self.experienceToShow = nil
                isConfigLoaded = false
            }

        case .onCCPAUpdated(let value):
            eventListener?.onCCPAUpdated(ccpaString: value)
            
        case .onTCFUpdated(let value):
            eventListener?.onTCFUpdated(tcfString: value)
            
        case .onGPPUpdated(let value):
            eventListener?.onTCFUpdated(tcfString: value)
            
        case .onConsentUpdated(let consent):
            eventListener?.onConsentUpdated(consent: consent)
            
        case .error(let description):
            eventListener?.onError(description: description)
        }
    }
    
    private func didCloseExperience() {
        webPresentationItem = nil
        eventListener?.onClose()
    }
    
    private var display: KetchSDK.Configuration.Experience.ContentDisplay {
        ketch.configuration?.experiences?.content?.display
        ?? .banner
    }
        
    private var bannerPosition: KetchSDK.Configuration.BannerContainerConfig.Position {
        ketch.configuration?.theme?.banner?.container?.position
        ?? .bottomMiddle
    }
    
    private var modalPosition: KetchSDK.Configuration.ModalContainerConfig.Position {
        ketch.configuration?.theme?.modal?.container?.position
        ?? .center
    }
}

// MARK: - Direct trigger of dialog item presentation
extension KetchUI {
    public func reload(with options: [ExperienceOption] = []) {
        self.options = options
        preloadedPresentationItem?.reload(options: options)
    }
    
    public func showExperience(presentationConfig: PresentationConfig? = nil) {
        preloadedPresentationItem?.presentationConfig = presentationConfig
        webPresentationItem = preloadedPresentationItem
    }

    public func showPreferences() {
        experienceToShow = .preference
        preloadedPresentationItem?.showPreferences()
    }
    
    public func showConsent() {
        experienceToShow = .consent
        preloadedPresentationItem?.showConsent()
    }
    
    public func closeExperience() {
        webPresentationItem = nil
    }
}

// MARK: - Public
extension KetchUI {
    public enum ExperienceOption {
        // ketch_show forces an experience to show
        case forceExperience(ExperienceToShow)
        
        // staging, production overrides environment detection and uses a specific environment
        case environement(Environement)
        
        // ketch_region (swb_region) ISO-3166 country code overrides region detection and uses a specific region
        case region(String)
        
        // ketch_jurisdiction (swb_p) jurisdiction code overrides jurisdiction detection and uses a specific jurisdiction
        case jurisdiction(code: String)
        
        // ketch_lang (lang, swb_l) ISO 639-1 language code, with optional regional extension    overrides language detection and uses a specific language
        case language(langId: String)
        
        // ketch_preferences_tab, default tab that will be opened
        case preferencesTab(PreferencesTab)
        
        /// `ketch_preferences_tabs`, comma separated list of tabs to display on the preference experience
        case preferencesTabs(String)
        
        /// URL string for SDK, including `https://`
        case sdkEnvironmentURL(String)
        
        public enum ExperienceToShow: String {
            case consent, preferences
        }
        
        public enum Environement: String {
            case staging, production
        }
        
        public enum PreferencesTab: String, CaseIterable {
            case overviewTab, rightsTab, consentsTab, subscriptionsTab
        }
    }
}

// MARK: - Dialog presentation item generation of each type
extension KetchUI {
    private func webExperience(onEvent: ((WebPresentationItem.Event) -> Void)?) -> WebPresentationItem? {
        guard
            let advertisingIdentifier = ketch.identities
//                .compactMap({
//                    if case .idfa(let id) = $0 { return id }
//                    return nil
//                })
                .first?
                .value,
            let uuid = UUID(uuidString: advertisingIdentifier)
        else { return nil }
        
        return WebPresentationItem(
            item: .init(
                orgCode: ketch.organizationCode,
                propertyName: ketch.propertyCode,
                advertisingIdentifier: uuid
            ),
            onEvent: onEvent
        )
    }
}

// MARK: - Dialog presentation item generation of each type

public protocol KetchEventListener: AnyObject {
    func showConsent()
    func showPreferences()
    func onCCPAUpdated(ccpaString: String?)
    func onTCFUpdated(tcfString: String?)
    func onConfigUpdated(config: KetchSDK.Configuration?)
    func onConsentUpdated(consent: KetchSDK.ConsentStatus)
    func onClose()
    func onError(description: String)
}
