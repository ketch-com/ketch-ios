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
    public var overridePresentationConfig: WebPresentationItem.PresentationConfig?

    private(set) public var ketch: Ketch
    private var subscriptions = Set<AnyCancellable>()
    private var options = [ExperienceOption]()

    /// Instantiation of UI dialogs
    /// - Parameter ketch: Instance of Ketch that will provide request and storage services,
    /// protocol plugins updates
    public init(ketch: Ketch, experienceOptions options: [ExperienceOption] = []) {
        self.ketch = ketch

        bindInput()
        preloadWebExperience()
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
            self.webPresentationItem = nil
            eventListener?.onClose()
            
        case .show(let content):
            switch content {
            case .consent: eventListener?.showConsent()
            case .preference: eventListener?.showPreferences()
            }
            
            self.showExperience(
                presentationConfig: overridePresentationConfig ?? presentationConfig
            )
            
        case .configurationLoaded(let configuration):
            self.ketch.configuration = configuration
            eventListener?.onConfigUpdated(config: configuration)

        case .onCCPAUpdated(let value):
            eventListener?.onCCPAUpdated(ccpaString: value)
            
        case .onTCFUpdated(let value):
            eventListener?.onTCFUpdated(tcfString: value)
            
        case .onConsentUpdated(let consent):
            eventListener?.onConsentUpdated(consent: consent)
        }
    }
    
    private var presentationConfig: WebPresentationItem.PresentationConfig {
        switch display {
        case .banner:
            switch bannerPosition {
            case .bottom:       return .init(vpos: .bottom, hpos: .center)
            case .top:          return .init(vpos: .top,    hpos: .center)
            case .leftCorner:   return .init(vpos: .bottom, hpos: .left)
            case .rightCorner:  return .init(vpos: .bottom, hpos: .right)
            case .bottomMiddle: return .init(vpos: .bottom, hpos: .center)
            case .center:       return .init(vpos: .center, hpos: .center)
            }
        case .modal:
            switch modalPosition {
            case .left:     return .init(vpos: .center, hpos: .left)
            case .right:    return .init(vpos: .center, hpos: .right)
            case .center:   return .init(vpos: .center, hpos: .center)
            }
        }
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
    
    public func showExperience(presentationConfig: WebPresentationItem.PresentationConfig? = nil) {
        preloadedPresentationItem?.presentationConfig = presentationConfig
        webPresentationItem = preloadedPresentationItem
    }

    public func showPreferences() {
        preloadedPresentationItem?.showPreferences()
    }
    
    public func showConsent() {
        preloadedPresentationItem?.showConsent()
    }
        
    public func getConfig() {
        preloadedPresentationItem?.getConfig()
    }
    
    public func getConsent() {
        preloadedPresentationItem?.getConsent()
    }
}

// MARK: - Public
extension KetchUI {
    public enum ExperienceOption {
        // ketch_show forces an experience to show
        case forceExperience(ExperienceToShow)
        // staging, production    overrides environment detection and uses a specific environment
        case environement(Environement)
        //ketch_region (swb_region)    ISO-3166 country code    overrides region detection and uses a specific region
        case region(String)
        //ketch_jurisdiction (swb_p)    jurisdiction code    overrides jurisdiction detection and uses a specific jurisdiction
        case jurisdiction(code: String)
        //ketch_lang (lang, swb_l)    ISO 639-1 language code, with optional regional extension    overrides language detection and uses a specific language
        case language(langId: String)
        //ketch_preferences_tab (swb_preferences_tab)
        case preferencesTab(PreferencesTab)
        
        public enum ExperienceToShow: String {
            case cd, preferences
        }
        
        public enum Environement: String {
            case staging, production
        }
        
        public enum PreferencesTab: String {
            case overviewTab, rightsTab, consentsTab
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
        
        return .init(
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
    func onLoad()
    func showConsent()
    func showPreferences()
    func onCCPAUpdated(ccpaString: String?)
    func onTCFUpdated(tcfString: String?)
    func onConfigUpdated(config: KetchSDK.Configuration?)
    func onEnvironmentUpdated(environment: String?)
    func onRegionInfoUpdated(regionInfo: String?)
    func onJurisdictionUpdated(jurisdiction: String?)
    func onIdentitiesUpdated(identities: String?)
    func onConsentUpdated(consent: KetchSDK.ConsentStatus)
    func onClose()
}
