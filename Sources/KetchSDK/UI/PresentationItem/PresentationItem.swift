//
//  PresentationItem.swift
//  KetchSDK
//

import SwiftUI
import WebKit

extension KetchUI {
    public struct WebPresentationItem: Identifiable, Equatable {
        public enum Event {
            case onClose
            case show(Content)
            case hasChangedExperience(ExperienceTransition)
            case configurationLoaded(KetchSDK.Configuration)
            case onCCPAUpdated(String?)
            case onTCFUpdated(String?)
            case onGPPUpdated(String?)
            case onConsentUpdated(consent: KetchSDK.ConsentStatus)
            case error(description: String)

            public enum Content {
                case consent(CGSize), preference
            }
        }
        
        public static func == (lhs: Self, rhs: Self) -> Bool { lhs.id == rhs.id }
        
        let item: WebExperienceItem
        let config: WebConfig
        let onEvent: ((Event) -> Void)?
        private let userDefaults: UserDefaults = .standard
        private var consent: [String: Any]?
        private var configuration: KetchSDK.Configuration?
        private let webNavigationHandler = WebNavigationHandler()
        
        private(set) var preloaded: WKWebView
        public var presentationConfig: PresentationConfig?
        
        init(item: WebExperienceItem, onEvent: ((Event) -> Void)?) {
            self.item = item
            config = WebConfig(
                orgCode: item.orgCode,
                propertyName: item.propertyName,
                advertisingIdentifier: item.advertisingIdentifier
            )
            
            self.onEvent = onEvent
            
            let webHandler = WebHandler(onEvent: { _, _ in })
            preloaded = config.preferencesWebView(with: webHandler)
            preloaded.navigationDelegate = webNavigationHandler
        }
        
        public var id: String { String(describing: presentationConfig) }
        
        struct WebExperienceItem {
            let orgCode: String
            let propertyName: String
            let advertisingIdentifier: UUID
        }
        
        @ViewBuilder
        public var content: some View {
            webExperience(
                orgCode: item.orgCode,
                propertyName: item.propertyName,
                advertisingIdentifier: item.advertisingIdentifier
            )
        }
        
        public mutating func reload(options: [ExperienceOption] = []) {
            let webHandler = WebHandler(onEvent: handle)
            var config = config
            config.params = Dictionary(uniqueKeysWithValues: options.map { ($0.queryParameter.key, $0.queryParameter.value) })

            preloaded = config.preferencesWebView(with: webHandler)
            preloaded.navigationDelegate = webNavigationHandler
        }
        
        private func webExperience(orgCode: String,
                                   propertyName: String,
                                   advertisingIdentifier: UUID) -> some View {
            var config = config
            config.configWebApp = preloaded

            return PreferencesWebView(config: config)
                .asResponsiveSheet(style: .custom)
        }
        
        private func handle(event: WebHandler.Event, body: Any) {
            KetchLogger.log.debug("webView onEvent: \(event.rawValue)")
            
            switch event {
            case .hasShownExperience:
                let values = body as? [Any]
                
                if let type = values?.first as? String {
                    if type == "experiences.consent" {
                        if let size = values?.last as? [Double],
                           let width = size.first, let height = size.last {
                            onEvent?(.show(.consent(CGSizeMake(width, height))))
                        }
                    } else if type == "experiences.preferences" {
                        onEvent?(.show(.preference))
                    }
                }
                
            case .hideExperience:
                guard
                    let status = body as? String,
                    WebHandler.Event.Message(rawValue: status) == .willNotShow
                else {
                    KetchLogger.log.debug("onClose")
                    onEvent?(.onClose)
                    return
                }
                
            case .hasChangedExperience:
                guard let presentationString = body as? String,
                      let transition = ExperienceTransition(rawValue: presentationString) else {
                    return
                }
                onEvent?(.hasChangedExperience(transition))
                
            case .updateCCPA:
                guard let stringBody = body as? String else {
                    #warning("TODO: log")
                    KetchLogger.log.error("Failed to retrieve CCPA string")
                    return
                }
                
                KetchLogger.log.debug("CCPA Updated: \(stringBody)")
                
                onEvent?(.onCCPAUpdated(stringBody))
                
                savePrivacyString(stringBody)
                
            case .updateTCF:
                guard let stringBody = body as? String else {
                    KetchLogger.log.error("Failed to retrieve TCF string")
                    return
                }
                
                KetchLogger.log.debug("TCF Updated: \(stringBody)")
                
                onEvent?(.onTCFUpdated(stringBody))
                
                savePrivacyString(stringBody)
                
            case .updateGPP:
                guard let stringBody = body as? String else {
                    KetchLogger.log.error("Failed to retrieve CPP string")
                    return
                }
                
                KetchLogger.log.debug("GPP Updated: \(stringBody)")
                
                onEvent?(.onGPPUpdated(stringBody))
                
                savePrivacyString(stringBody)
                
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
                
                onEvent?(.configurationLoaded(configuration))
                
            case .error:
                KetchLogger.log.error("error: \((body as? String) ?? "")")

                guard let description = body as? String else {
                    KetchLogger.log.error("Unable to parse Error")
                    return
                }
                onEvent?(.error(description: description))
                
            default: break
            }
        }
        
        private func payload<T: Decodable>(with payload: Any) -> T? {
            guard let payload = payload as? String,
                  let payloadData = payload.data(using: .utf8)
            else { return nil }
            
            return try? JSONDecoder().decode(T.self, from: payloadData)
        }
        
        private func savePrivacyString(_ string: String) {
            guard let data = string.data(using: .utf8),
                  let privacyObject = try? JSONSerialization.jsonObject(with: data) as? [Any],
                  let pricacyStrings = privacyObject.last as? [String: Any?] else {
                
                return
            }
            
            // in current implementation we have a single key with object where all other pairs are lieve
            pricacyStrings.forEach { pair in
                userDefaults.set(pair.value, forKey: pair.key)
            }
        }
    }
}

extension KetchUI.WebPresentationItem {
    public func showPreferences() {
        preloaded.evaluateJavaScript("ketch('showPreferences')")
    }
    
    public func showConsent() {
        preloaded.evaluateJavaScript("ketch('showConsent')")
    }
    
    public func getConfig() {
        preloaded.evaluateJavaScript("ketch('getFullConfig')")
    }
    
    public func getConsent() {
        preloaded.evaluateJavaScript("ketch('getConsent')")
    }
}

extension KetchUI.ExperienceOption {
    var queryParameter: (key: String, value: String) {
        switch self {
        case .forceExperience(let exp):
            return (key: "ketch_show", value: exp.rawValue)
            
        case .environement(let value):
            return (key: "ketch_env", value: value.rawValue)
            
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
            
        case .sdkEnvironmentURL(let url):
            return (key: "ketch_mobilesdk_url", value: url)
        }
    }
}

class WebHandler: NSObject, WKScriptMessageHandler {
    enum Event: String, CaseIterable {
        case updateCCPA = "usprivacy_updated"
        case updateTCF = "tcf_updated"
        case updateGPP = "gpp_updated"
        case hideExperience
        case environment
        case regionInfo
        case jurisdiction
        case identities
        case consent
        case hasShownExperience
        case hasChangedExperience = "hasChangedExperience"
        case onConfigLoaded
        case onFullConfigLoaded
        case error
        
        enum Message: String, Codable {
            case willNotShow
            case setConsent
            case close
        }
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
            guard let url = navigationAction.request.url else {return}
            webView.load(URLRequest(url: url))
        }
        
        decisionHandler(.allow)
    }
}
