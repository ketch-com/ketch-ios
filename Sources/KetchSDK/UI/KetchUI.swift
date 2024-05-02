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
    /// - Parameter options: default options
    /// protocol plugins updates
    public init(ketch: Ketch, experienceOptions options: [ExperienceOption] = []) {
        self.ketch = ketch
        self.options = options
        
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
            if isConfigLoaded {
                self.showExperience()
                eventListener?.onShow()
            } else {
                experienceToShow = content
            }
            
        case .tapOutside:
            didCloseExperience()
            
        case .configurationLoaded(let configuration):
            self.ketch.configuration = configuration
            
            isConfigLoaded = true
            
            if experienceToShow != nil {
                showExperience()
                self.experienceToShow = nil
                isConfigLoaded = false
                eventListener?.onShow()
            }

        case .onCCPAUpdated(let value):
            eventListener?.onCCPAUpdated(ccpaString: value)
            
        case .onTCFUpdated(let value):
            eventListener?.onTCFUpdated(tcfString: value)
            
        case .onGPPUpdated(let value):
            eventListener?.onGPPUpdated(gppString: value)
            
        case .onConsentUpdated(let consent):
            eventListener?.onConsentUpdated(consent: consent)
            
        case .error(let description):
            eventListener?.onError(description: description)
        case .environment(let env):
            eventListener?.onEnvironmentUpdated(environment: env)
            
        case .regionInfo(let region):
            eventListener?.onRegionInfoUpdated(regionInfo: region)
            
        case .jurisdiction(let jurisdiction):
            eventListener?.onJurisdictionUpdated(jurisdiction: jurisdiction)
            
        case .identities(let identities):
            eventListener?.onIdentitiesUpdated(identities: identities)
        }
    }
    
    private func didCloseExperience() {
        webPresentationItem = nil
        eventListener?.onDismiss()
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
        // merge options, override existing if needed
        var newOptions = self.options
        options.forEach { option in
            if let duplicateIndex = newOptions.firstIndex(of: option) {
                newOptions.remove(at: duplicateIndex)
            }
            
            newOptions.append(option)
        }
        
        preloadedPresentationItem?.reload(options: newOptions)
    }
    
    public func showExperience() {
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
    public enum ExperienceOption: Equatable {
        
        /// Enables console logging by Ketch components
        case logLevel(LogLevel)
        
        /// Forces an experience to show
        case forceExperience(ExperienceToShow)
        
        /// Overrides environment detection and uses a specific environment
        case environment(String)
        
        /// ISO-3166 country code overrides region detection and uses a specific region
        case region(code: String)
        
        /// Jurisdiction code overrides jurisdiction detection and uses a specific jurisdiction
        case jurisdiction(code: String)
        
        /// ISO 639-1 language code, with optional regional extension overrides language detection and uses a specific language
        case language(code: String)
        
        /// Default tab that will be opened
        case preferencesTab(PreferencesTab)
        
        /// Comma separated list of tabs to display on the preference experience
        case preferencesTabs(String)
        
        /// URL string for SDK, including `https://`
        case ketchURL(String)
        
        public enum ExperienceToShow: String {
            case consent, preferences
        }
        
        public enum PreferencesTab: String, CaseIterable {
            case overviewTab, rightsTab, consentsTab, subscriptionsTab
        }
        
        public enum LogLevel: String, Codable {
            case trace, debug, info, warn, error
        }
        
        public static func == (lhs: ExperienceOption, rhs: ExperienceOption) -> Bool {
            switch (lhs, rhs) {
            case (.logLevel(_), .logLevel(_)):
                return true
            case (.forceExperience(_), .forceExperience(_)):
                return true
            case (.environment(_), .environment(_)):
                return true
            case (.region(code: _), .region(code: _)):
                return true
            case (.jurisdiction(code: _), .jurisdiction(code: _)):
                return true
            case (.language(code: _), .language(code: _)):
                return true
            case (.preferencesTab(_), .preferencesTab(_)):
                return true
            case (.preferencesTabs(_), .preferencesTabs(_)):
                return true
            case (.ketchURL(_), .ketchURL(_)):
                return true
            default:
                return false
            }
        }
    }
}

// MARK: - Dialog presentation item generation of each type
extension KetchUI {
    private func webExperience(onEvent: ((WebPresentationItem.Event) -> Void)?) -> WebPresentationItem? {
        WebPresentationItem(
            item: .init(
                orgCode: ketch.organizationCode,
                propertyName: ketch.propertyCode,
                advertisingIdentifiers: ketch.identities
            ),
            onEvent: onEvent
        )
    }
}

// MARK: - Dialog presentation item generation of each type

public protocol KetchEventListener: AnyObject {
    func onShow()
    func onDismiss()
    func onEnvironmentUpdated(environment: String?)
    func onRegionInfoUpdated(regionInfo: String?)
    func onJurisdictionUpdated(jurisdiction: String?)
    func onIdentitiesUpdated(identities: String?)
    func onConsentUpdated(consent: KetchSDK.ConsentStatus)
    func onError(description: String)
    func onCCPAUpdated(ccpaString: String?)
    func onTCFUpdated(tcfString: String?)
    func onGPPUpdated(gppString: String?)
}
