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

    private var ketch: Ketch
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
        webPresentationItem = nil
        preloadedPresentationItem?.preloaded = preloaded
        preloadedPresentationItem?.presentationConfig = presentationConfig
        webPresentationItem = preloadedPresentationItem
    }
    
    public func showBanner() {

    }

    public func showModal() {

    }

    public func showPreferences() {
        preloaded?.evaluateJavaScript("ketch('showPreferences')")
    }
    
    public func showConsent() {
        preloaded?.evaluateJavaScript("ketch('showConsent')")
    }
        
    public func getFullConfig() {
        preloaded?.evaluateJavaScript("ketch('getFullConfig')") { val, err in
            print(val, err)
        }
    }
    
    public func getFullConfig2() {
        preloaded?.evaluateJavaScript("getFullConfig") { val, err in
            print(val, err)
        }
    }
    
//    public func removeCookies() {
//        let cookieJar = HTTPCookieStorage.shared
//
//        for cookie in cookieJar.cookies! {
//            cookieJar.deleteCookie(cookie)
//        }
//    }
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
}
