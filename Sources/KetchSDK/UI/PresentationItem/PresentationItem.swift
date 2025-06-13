//
//  PresentationItem.swift
//  KetchSDK
//

import SwiftUI
import WebKit

extension KetchUI {
    public struct WebPresentationItem: Equatable {
        public enum Event {
            case onClose(KetchSDK.HideExperienceStatus)
            case show(Content)
            case willShowExperience(KetchSDK.WillShowExperienceType)
            case configurationLoaded(KetchSDK.Configuration)
            case onCCPAUpdated(String?)
            case onTCFUpdated(String?)
            case onGPPUpdated(String?)
            case onConsentUpdated(consent: KetchSDK.ConsentStatus)
            case error(description: String)
            case tapOutside
            case environment(String?)
            case regionInfo(String?)
            case jurisdiction(String?)
            case identities(String?)

            public enum Content {
                case consent, preference
            }
        }
        
        public static func == (lhs: Self, rhs: Self) -> Bool { lhs.webView == rhs.webView }
        
        let item: WebExperienceItem
        let config: WebConfig
        let onEvent: ((Event) -> Void)?
        private let userDefaults: UserDefaults = .standard
        private var configuration: KetchSDK.Configuration?
        private let webNavigationHandler = WebNavigationHandler()
        
        private(set) var webView: WKWebView?
        private var presentedItem: WebPresentationItem.Event.Content?
        
        // Protocol prefixes to delete on every load
        private static let prefixesToRemove = ["IABTCF", "IABGPP", "IABUS"]
        
        init(item: WebExperienceItem, onEvent: ((Event) -> Void)?) {
            self.item = item
            config = WebConfig(
                orgCode: item.orgCode,
                propertyName: item.propertyName,
                environmentCode: item.environmentCode,
                advertisingIdentifiers: item.advertisingIdentifiers
            )
            
            self.onEvent = onEvent
            
            // Clear keys during initialization
            clearKeysWithPrefixes()
        }
        
        struct WebExperienceItem {
            let orgCode: String
            let propertyName: String
            let environmentCode: String
            let advertisingIdentifiers: [Ketch.Identity]
        }
        
        @ViewBuilder
        public var content: some View {
            webExperience(
                orgCode: item.orgCode,
                propertyName: item.propertyName,
                advertisingIdentifiers: item.advertisingIdentifiers
            )
        }
        
        public mutating func reload(options: [ExperienceOption] = []) {
            let options = validateOptions(options)
            
            let webHandler = WebHandler(onEvent: handle)
            var config = config
            config.params = Dictionary(uniqueKeysWithValues: options.map { ($0.queryParameter.key, $0.queryParameter.value) })

            webView?.configuration.userContentController.removeAllScriptMessageHandlers()
            webView = config.preferencesWebView(with: webHandler)
            webView?.navigationDelegate = webNavigationHandler
            webView?.uiDelegate = webNavigationHandler
            
            // Clear keys during reload
            clearKeysWithPrefixes()
        }
        
        private func validateOptions(_ options: [ExperienceOption]) -> [ExperienceOption] {
            // validate css
            guard let cssString = options.compactMap({
                if case let .css(value) = $0 { return value }
                else { return nil }
            }).first else {
                return options
            }
            
            func clearedOptions() -> [ExperienceOption] {
                // remove css from options
                return options.filter {
                    if case .css(_) = $0 {
                        return false
                    }
                    return true
                }
            }
            
            if cssString.count > 1024 {
                onEvent?(.error(description: "[Ketch] CSS injection rejected: CSS too long (>1kb limit)!"))
                return clearedOptions()
            } else if cssString.range(of: "<[^>]+>", options: .regularExpression) != nil  {
                onEvent?(.error(description: "Ketch] CSS injection rejected: must not contain HTML tags!"))
                return clearedOptions()
            }
            
            return options
        }
        
        // Utility function to clear keys with specified prefixes
        private func clearKeysWithPrefixes() {
            let keysToRemove = userDefaults.dictionaryRepresentation().keys.filter { key in
                WebPresentationItem.prefixesToRemove.contains { prefix in key.hasPrefix(prefix) }
            }
            
            keysToRemove.forEach { key in
                userDefaults.removeObject(forKey: key)
            }
            
            KetchLogger.log.debug("Cleared \(keysToRemove.count) keys with prefixes \(WebPresentationItem.prefixesToRemove)")
        }
        
        private func webExperience(orgCode: String,
                                   propertyName: String,
                                   advertisingIdentifiers: [Ketch.Identity]) -> some View {
            var config = config
            
            config.configWebApp?.configuration.userContentController.removeAllScriptMessageHandlers()
            config.configWebApp = webView ?? WKWebView(frame: .zero)

            return PreferencesWebView(config: config)
                .asResponsiveSheet(style: .custom)
        }
        
        private func handle(event: WebHandler.Event, body: Any) {
            switch event {
            case .showConsentExperience:
                KetchLogger.log.debug("webView onEvent: \(event.rawValue): \((body as? String) ?? "unknown")")
                onEvent?(.show(.consent))
                
            case .showPreferenceExperience:
                KetchLogger.log.debug("webView onEvent: \(event.rawValue): \((body as? String) ?? "unknown")")
                onEvent?(.show(.preference))

            case .hideExperience:
                KetchLogger.log.debug("webView onEvent: \(event.rawValue): \((body as? String) ?? "unknown")")
                
                // Parse status from event body
                let statusString = body as? String ?? ""
                let status = KetchSDK.HideExperienceStatus(rawValue: statusString) ?? KetchSDK.HideExperienceStatus.None
                    
                onEvent?(.onClose(status))
                return
                
            case .willShowExperience:
                KetchLogger.log.debug("webView onEvent: \(event.rawValue): \((body as? String) ?? "unknown")")
                
                // Parse type from event body
                let typeString = body as? String ?? ""
                let type = KetchSDK.WillShowExperienceType(rawValue: typeString) ?? KetchSDK.WillShowExperienceType.None
                
                onEvent?(.willShowExperience(type))
                
            case .tapOutside:
                KetchLogger.log.debug("webView onEvent: \(event.rawValue): \((body as? String) ?? "-")")
                onEvent?(.tapOutside)
                
            case .updateCCPA:
                guard let stringBody = body as? String else {
                    KetchLogger.log.error("Failed to retrieve CCPA string")
                    return
                }
                
                KetchLogger.log.debug("CCPA Updated: \(stringBody)")
                
                onEvent?(.onCCPAUpdated(stringBody))
                
                savePrivacyString(stringBody, for: "CCPA")
                
            case .updateTCF:
                guard let stringBody = body as? String else {
                    KetchLogger.log.error("Failed to retrieve TCF string")
                    return
                }
                
                KetchLogger.log.debug("TCF Updated: \(stringBody)")
                
                onEvent?(.onTCFUpdated(stringBody))
                
                savePrivacyString(stringBody, for: "TCF")
                
            case .updateGPP:
                guard let stringBody = body as? String else {
                    KetchLogger.log.error("Failed to retrieve CPP string")
                    return
                }
                
                KetchLogger.log.debug("GPP Updated: \(stringBody)")
                
                onEvent?(.onGPPUpdated(stringBody))
                
                savePrivacyString(stringBody, for: "GPP")
                
            case .consent:
                guard let consentStatus: KetchSDK.ConsentStatus = payload(with: body) else {
                    KetchLogger.log.error("\(event.rawValue): ConsentStatus decoding failed")
                    return
                }
                
                KetchLogger.log.debug("consentStatus: \((body as? String) ?? "")")
                onEvent?(.onConsentUpdated(consent: consentStatus))
                
                
            case .onConfigLoaded:
                guard let configuration: KetchSDK.Configuration = payload(with: body) else {
                    KetchLogger.log.error("Unable to parse Config")
                    return
                }
                
                KetchLogger.log.debug("webView onEvent: \(event.rawValue)")
                onEvent?(.configurationLoaded(configuration))
                
            case .error:
                KetchLogger.log.error("error: \((body as? String) ?? "")")

                guard let description = body as? String else {
                    KetchLogger.log.error("Unable to parse Error")
                    return
                }
                onEvent?(.error(description: description))
                
            case .environment:
                KetchLogger.log.debug("webView onEvent: \(event.rawValue): \((body as? String) ?? "unknown")")
                onEvent?(.environment(body as? String))
            case .regionInfo:
                KetchLogger.log.debug("webView onEvent: \(event.rawValue): \((body as? String) ?? "unknown")")
                onEvent?(.regionInfo(body as? String))
            case .jurisdiction:
                KetchLogger.log.debug("webView onEvent: \(event.rawValue): \((body as? String) ?? "unknown")")
                onEvent?(.jurisdiction(body as? String))
            case .identities:
                KetchLogger.log.debug("webView onEvent: \(event.rawValue): \((body as? String) ?? "unknown")")
                onEvent?(.identities(body as? String))
            default:
                break;
            }
        }
        
        private func payload<T: Decodable>(with payload: Any) -> T? {
            guard let payload = payload as? String,
                  let payloadData = payload.data(using: .utf8)
            else { return nil }
            
            return try? JSONDecoder().decode(T.self, from: payloadData)
        }
        
        private func savePrivacyString(_ string: String, for privacyType: String) {
            guard let data = string.data(using: .utf8),
                  let privacyObject = try? JSONSerialization.jsonObject(with: data) as? [Any],
                  let privacyStrings = privacyObject.last as? [String: Any?] else {
                KetchLogger.log.error("Failed to parse \(privacyType) privacy string: \(string)")
                return
            }

            // Save privacy strings to UserDefaults
            privacyStrings.forEach { pair in
                userDefaults.set(pair.value, forKey: pair.key)
            }

            // Log the number of keys saved and the privacy type
            KetchLogger.log.debug("\(privacyType) - Saved \(privacyStrings.count) privacy keys to NSUserDefaults.")
        }
    }
}

extension KetchUI.WebPresentationItem {
    public func showPreferences() {
        webView?.evaluateJavaScript("ketch('showPreferences')")
    }
    
    public func showConsent() {
        webView?.evaluateJavaScript("ketch('showConsent')")
    }
}

extension KetchUI.ExperienceOption {
    var queryParameter: (key: String, value: String) {
        switch self {
        case .logLevel(let level):
            return (key: "ketch_log", value: level.rawValue)
            
        case .forceExperience(let exp):
            return (key: "ketch_show", value: exp.rawValue)
            
        case .organizationCode(let code):
            return (key: "orgCode", value: code)
            
        case .propertyCode(let code):
            return (key: "propertyName", value: code)
            
        case .environment(let value):
            return (key: "ketch_env", value: value)
            
        case .region(let value):
            return (key: "ketch_region", value: value)

        case .jurisdiction(let code):
            return (key: "ketch_jurisdiction", value: code)

        case .language(let langId):
            return (key: "ketch_lang", value: langId)

        case .preferencesTab(let tab):
            return (key: "ketch_preferences_tab", tab.rawValue)
            
        case .preferencesTabs(let tabs):
            return (key: "ketch_preferences_tabs", tabs)
            
        case .ketchURL(let url):
            return (key: "ketch_mobilesdk_url", value: url)
        
        case .identity(let identity):
            return (key: identity.key, value: identity.value)
            
        case .css(let string):
            return (key: "ketch_css_inject", value: string)
        }
    }
}

class WebHandler: NSObject, WKScriptMessageHandler {
    enum Event: String, CaseIterable {
        case updateCCPA = "usprivacy_updated_data"
        case updateTCF = "tcf_updated_data"
        case updateGPP = "gpp_updated_data"
        case hideExperience
        case environment
        case regionInfo
        case jurisdiction
        case identities
        case consent
        case showConsentExperience
        case showPreferenceExperience
        case willShowExperience
        case onConfigLoaded
        case error
        case tapOutside
        case geoip

    }
    
    private var onEvent: ((Event, Any) -> Void)?
    
    init(onEvent: ((Event, Any) -> Void)?) {
        self.onEvent = onEvent
    }
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        guard let event = Event(rawValue: message.name) else {
            KetchLogger.log.error("Ketch Preference Center: Unable to handle unknown event \"\(message.name)\"")
            return
        }
        
        onEvent?(event, message.body)
    }
}

private struct ConsentModel: Codable {
    let valueUSPrivacy: String?
    let valueTC: String?
    let valueGPP: String?
    let valueGDPRApplies: Int?

    enum CodingKeys: String, CodingKey {
        case valueUSPrivacy = "IABUSPrivacy_String"
        case valueTC = "IABTCF_TCString"
        case valueGDPRApplies = "IABTCF_gdprApplies"
        case valueGPP = "IABGPP_HDR_GppString"
    }
}

public enum ExperienceTransition: String {
    case modal = "experiencedisplays.modal"
    case banner = "experiencedisplays.banner"
    case fullScreen = "experiencedisplays.preference"
}

fileprivate class WebNavigationHandler: NSObject, WKNavigationDelegate, WKUIDelegate {
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if navigationAction.navigationType == .linkActivated {
            guard let url = navigationAction.request.url else {
                decisionHandler(.cancel)
                return
            }
            
            decisionHandler(.cancel)
            UIApplication.shared.open(url)
            
            return
        }
        
        decisionHandler(.allow)
    }
    
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        guard let url = navigationAction.request.url else {
            return nil
        }
        
        UIApplication.shared.open(url)
        return nil
    }
}
