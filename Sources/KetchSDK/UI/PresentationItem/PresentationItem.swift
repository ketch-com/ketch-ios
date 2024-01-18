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
        }
        
        public static func == (lhs: Self, rhs: Self) -> Bool { lhs.id == rhs.id }
        
        public struct PresentationConfig {
            public enum VPosition { case top, center, bottom }
            public enum HPosition { case left, center, right }
            
            public let vpos: VPosition
            public let hpos: HPosition
            
            public init(vpos: VPosition, hpos: HPosition) {
                self.vpos = vpos
                self.hpos = hpos
            }
        }
        
        let item: WebExperienceItem
        let config: WebConfig
        let onEvent: ((Event) -> Void)?
        private let userDefaults: UserDefaults = .standard
        private var consent: [String: Any]?
        
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
        
        public var id: String { String(describing: item) }
        
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
        
        public mutating func reload() {
            let webHandler = WebHandler(onEvent: handle)
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
            switch event {
            case .hideExperience:
                guard
                    let status = body as? String,
                    WebHandler.Event.Message(rawValue: status) == .willNotShow
                else {
    //                onClose?()
                    return
                }
                
            case .updateCCPA:
                print("CCPA Updated")
                let value = body as? String
                
                save(value: value, for: .valueUSPrivacy)
                save(value: 0, for: .valueGDPRApplies)
                
            case .updateTCF:
                print("TCF Updated")
                let value = body as? String
                
                save(value: value, for: .valueTC)
                save(value: value != nil ? 1 : 0, for: .valueGDPRApplies)
                
            case .consent:
                let consentStatus: ConsentStatus? = payload(with: body)
                print(event.rawValue, consentStatus ?? "ConsentStatus decoding failed")
                
            case .onConfigLoaded:
                let config: KetchSDK.Configuration? = payload(with: body)
                
            case .onFullConfigLoaded:
                let config: KetchSDK.Configuration? = payload(with: body)
                print("onFullConfigLoaded")
                
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
        
        struct ConsentStatus: Codable {
            let purposes: [String: Bool]
            let vendors: [String]?
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
    
    public func getFullConfig() {
        preloaded.evaluateJavaScript("ketch('getFullConfig')") { val, err in }
    }
}

class WebHandler: NSObject, WKScriptMessageHandler {
    enum Event: String, CaseIterable {
        case updateCCPA = "usprivacy_updated"
        case updateTCF = "tcf_updated"
        case hideExperience
        case environment
        case regionInfo
        case jurisdiction
        case identities
        case consent
        case willShowExperience
        case onConfigLoaded
        case onFullConfigLoaded
        
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
    let valueGDPRApplies: Int?

    enum CodingKeys: String, CodingKey {
        case valueUSPrivacy = "IABUSPrivacy_String"
        case valueTC = "IABTCF_TCString"
        case valueGDPRApplies = "IABTCF_gdprApplies"
    }
}
