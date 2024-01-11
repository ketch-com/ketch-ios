//
//  ConsentConfig.swift
//  iOS Ketch Pref Center using SwiftUI
//

import Foundation
import WebKit

struct ConsentConfig {
    let orgCode: String
    let propertyName: String
    let advertisingIdentifier: UUID
    let htmlFileName: String
    let userDefaults: UserDefaults
    var configWebApp: WKWebView?

    init(
        orgCode: String,
        propertyName: String,
        advertisingIdentifier: UUID,
        htmlFileName: String = "index",
        userDefaults: UserDefaults = .standard
    ) {
        self.propertyName = propertyName
        self.orgCode = orgCode
        self.advertisingIdentifier = advertisingIdentifier
        self.htmlFileName = htmlFileName
        self.userDefaults = userDefaults
    }

    static func configure(
        orgCode: String,
        propertyName: String,
        advertisingIdentifier: UUID,
        htmlFileName: String = "index",
        userDefaults: UserDefaults = .standard
    ) -> Self {
        var config = ConsentConfig(
            orgCode: orgCode,
            propertyName: propertyName,
            advertisingIdentifier: advertisingIdentifier,
            htmlFileName: htmlFileName,
            userDefaults: userDefaults)

        DispatchQueue.main.async {
            config.configWebApp = config.preferencesWebView(onClose: nil)
        }

        return config
    }

    private var fileUrl: URL? {
        let url = Bundle.ketchUIfiles!.url(forResource: htmlFileName, withExtension: "html")!
        var urlComponents = URLComponents(string: url.absoluteString)
        urlComponents?.queryItems = queryItems

        return urlComponents?.url
    }

    private var queryItems: [URLQueryItem] {
        [
            URLQueryItem(name: "propertyName", value: propertyName),
            URLQueryItem(name: "orgCode", value: orgCode),
            URLQueryItem(name: "idfa", value: advertisingIdentifier.uuidString)
        ]
    }

    func preferencesWebView(onClose: (() -> Void)?) -> WKWebView {
        let preferences = WKWebpagePreferences()
        preferences.allowsContentJavaScript = true

        let configuration = WKWebViewConfiguration()
        configuration.defaultWebpagePreferences = preferences

        let consentHandler = ConsentHandler(userDefaults: userDefaults, onClose: onClose)

        ConsentHandler.Event.allCases.forEach { event in
            configuration.userContentController.add(consentHandler, name: event.rawValue)
        }

        let webView = WKWebView(frame: .zero, configuration: configuration)

        if let fileUrl = fileUrl {
            webView.load(URLRequest(url: fileUrl))
        }

        return webView
    }
}

extension ConsentConfig: Identifiable {
    var id: String {
        orgCode + propertyName + advertisingIdentifier.uuidString
    }
}

class ConsentHandler: NSObject, WKScriptMessageHandler {
    var onClose: (() -> Void)?
    private let userDefaults: UserDefaults
    private var consent: [String: Any]?

    init(userDefaults: UserDefaults, onClose: (() -> Void)?) {
        self.onClose = onClose
        self.userDefaults = userDefaults
    }

    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        guard let event = Event(rawValue: message.name) else {
            print("Ketch Preference Center: Unable to handle unknown event \"\(message.name)\"")
            return
        }

        print(message.name, message.body)

        switch event {
        case .hideExperience:
            guard
                let status = message.body as? String,
                Event.Message(rawValue: status) == .willNotShow
            else {
                onClose?()
                return
            }

        case .updateCCPA:
            print("CCPA Updated")
            let value = message.body as? String

            save(value: value, for: .valueUSPrivacy)
            save(value: 0, for: .valueGDPRApplies)

        case .updateTCF:
            print("TCF Updated")
            let value = message.body as? String

            save(value: value, for: .valueTC)
            save(value: value != nil ? 1 : 0, for: .valueGDPRApplies)

        case .consent:
            let consentStatus: ConsentStatus? = payload(with: message.body)
            print(message.name, consentStatus ?? "ConsentStatus decoding failed")

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

extension ConsentHandler {
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

        enum Message: String, Codable {
            case willNotShow
            case setConsent
            case close
        }
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

extension ConsentHandler {
    struct ConsentStatus: Codable {
        let purposes: [String: Bool]
        let vendors: [String]?
    }
}
