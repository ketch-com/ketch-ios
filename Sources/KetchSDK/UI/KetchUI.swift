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

    public var showDialogsIfNeeded = false

    private(set) public var ketch: Ketch
    private var subscriptions = Set<AnyCancellable>()

    /// Instantiation of UI dialogs
    /// - Parameter ketch: Instance of Ketch that will provide request and storage services,
    /// protocol plugins updates
    public init(ketch: Ketch) {
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
                if self.showDialogsIfNeeded {
//                    self.showConsentExperience()
                }
            }
            .store(in: &subscriptions)
    }
    
    private var preloadedPresentationItem: WebPresentationItem?

    private func preloadWebExperience() {
        preloadedPresentationItem = webExperience { event in
            switch event {
            case .onClose: self.webPresentationItem = nil
            case .show(let content):
                switch content {
                case.consent: self.showExperience(presentationConfig: .init(vpos: .bottom, hpos: .center))
                case .preference: self.showExperience(presentationConfig: .init(vpos: .center, hpos: .center))
                }
            case .configurationLoaded(let configuration):
                self.ketch.configuration = configuration
            }
        }
        preloadedPresentationItem?.reload()
    }
}

// MARK: - Direct trigger of dialog item presentation
extension KetchUI {
    public func reload() {
        preloadedPresentationItem?.reload()
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
