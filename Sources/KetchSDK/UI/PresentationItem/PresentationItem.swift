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
                case consent, preference
            }
        }
        
        public static func == (lhs: Self, rhs: Self) -> Bool { lhs.id == rhs.id }
        
        let item: WebExperienceItem
        let config: WebConfig
        let onEvent: ((Event) -> Void)?
        private let userDefaults: UserDefaults = .standard
        private var consent: [String: Any]?
        private var configuration: KetchSDK.Configuration?
        
        var preloaded: WKWebView
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
            print("webView onEvent: ", event.rawValue)
            
            switch event {
            case .showConsentExperience:
                onEvent?(.show(.consent))
                
            case .showPreferenceExperience:
                onEvent?(.show(.preference))

            case .hideExperience:
                guard
                    let status = body as? String,
                    WebHandler.Event.Message(rawValue: status) == .willNotShow
                else {
                    print("onClose")
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
                print("CCPA Updated: ", (body as? String) ?? "")
                let value = body as? String
                onEvent?(.onCCPAUpdated(value))

                save(value: value, for: .valueUSPrivacy)
                save(value: 0, for: .valueGDPRApplies)
                
            case .updateTCF:
                print("TCF Updated: ", (body as? String) ?? "")
                let value = body as? String
                onEvent?(.onTCFUpdated(value))

                save(value: value, for: .valueTC)
                save(value: value != nil ? 1 : 0, for: .valueGDPRApplies)
                
            case .updateGPP:
                print("GPP Updated: ", (body as? String) ?? "")
                let value = body as? String
                onEvent?(.onGPPUpdated(value))

                save(value: value, for: .valueGPP)
                save(value: 0, for: .valueGDPRApplies)
                
            case .consent:
                guard let consentStatus: KetchSDK.ConsentStatus = payload(with: body) else {
                    print(event.rawValue, "ConsentStatus decoding failed")
                    return
                }
                
                print("consentStatus: ", (body as? String) ?? "")
                onEvent?(.onConsentUpdated(consent: consentStatus))
                
                
            case .onConfigLoaded:
                guard let configuration: KetchSDK.Configuration = payload(with: body) else {
                    print("Unable to parse Config")
                    return
                }
                
                onEvent?(.configurationLoaded(configuration))
                
            case .error:
                print("error: ", (body as? String) ?? "")

                guard let description = body as? String else {
                    print("Unable to parse Error")
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
        
        private func save(value: String?, for key: ConsentModel.CodingKeys) {
            let keyValue = key.rawValue
            if value?.isEmpty == false {
                userDefaults.set(value, forKey: keyValue)
            } else {
                userDefaults.removeObject(forKey: keyValue)
            }
        }
        
        private func save(value: Int?, for key: ConsentModel.CodingKeys) {
            let keyValue = key.rawValue
            if let value = value {
                userDefaults.set(value, forKey: keyValue)
            } else {
                userDefaults.removeObject(forKey: keyValue)
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
        case showConsentExperience
        case showPreferenceExperience
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
            print("Ketch Preference Center: Unable to handle unknown event \"\(message.name)\"")
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
