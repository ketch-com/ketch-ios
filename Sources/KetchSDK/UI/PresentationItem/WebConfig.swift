//
//  WebConfig.swift
//  iOS Ketch Pref Center using SwiftUI
//

import Foundation
import WebKit

struct WebConfig {
    let orgCode: String
    let propertyName: String
    let advertisingIdentifier: UUID
    let htmlFileName: String
    var params = [String: String]()
    var configWebApp: WKWebView?

    init(
        orgCode: String,
        propertyName: String,
        advertisingIdentifier: UUID,
        htmlFileName: String = "index"
    ) {
        self.propertyName = propertyName
        self.orgCode = orgCode
        self.advertisingIdentifier = advertisingIdentifier
        self.htmlFileName = htmlFileName
    }

    static func configure(
        orgCode: String,
        propertyName: String,
        advertisingIdentifier: UUID,
        htmlFileName: String = "index"
    ) -> Self {
        var config = WebConfig(
            orgCode: orgCode,
            propertyName: propertyName,
            advertisingIdentifier: advertisingIdentifier,
            htmlFileName: htmlFileName
        )

        DispatchQueue.main.async {
            config.configWebApp = config.preferencesWebView(with: WebHandler(onEvent: { _, _ in }), screenSize: .zero)
        }

        return config
    }

    private var fileUrl: URL? {
        let url = Bundle.ketchUI!.url(forResource: htmlFileName, withExtension: "html")!
        var urlComponents = URLComponents(string: url.absoluteString)
        urlComponents?.queryItems = queryItems

        return urlComponents?.url
    }

    private var queryItems: [URLQueryItem] {
        var defaultQuery = [
            "propertyName": URLQueryItem(name: "propertyName", value: propertyName),
            "orgCode": URLQueryItem(name: "orgCode", value: orgCode),
            "idfa": URLQueryItem(name: "idfa", value: advertisingIdentifier.uuidString),
            "ketch_lang": URLQueryItem(name: "ketch_lang", value: "en"),
            "mobile_os": URLQueryItem(name: "mobile_os", value: "ios"),
            "mobile_device": URLQueryItem(name: "mobile_device", value: UIDevice.current.userInterfaceIdiom == .phone ? "phone" : "tablet")
        ]
        
        params.forEach {
            defaultQuery[$0] = URLQueryItem(name: $0, value: $1)
        }
        
        return Array(defaultQuery.values)
    }

    func preferencesWebView(with webHandler: WebHandler, screenSize: CGSize) -> WKWebView {
        let preferences = WKWebpagePreferences()
        preferences.allowsContentJavaScript = true

        let configuration = WKWebViewConfiguration()
        configuration.defaultWebpagePreferences = preferences

        WebHandler.Event.allCases.forEach { event in
            configuration.userContentController.add(webHandler, name: event.rawValue)
        }

        KetchLogger.log.debug("screen size: \(screenSize.debugDescription)")
        let webView = FullScreenWebView(frame: CGRect(origin: .zero, size: screenSize), configuration: configuration)
        webView.backgroundColor = .clear
        webView.isOpaque = false
        webView.scrollView.backgroundColor = .clear
        webView.scrollView.bounces = false
        
        if #available(iOS 16.4, *) {
            webView.isInspectable = true
        }

        if let fileUrl = fileUrl {
            webView.load(URLRequest(url: fileUrl))
        }

        return webView
    }
}

extension WebConfig: Identifiable {
    var id: String {
        orgCode + propertyName + advertisingIdentifier.uuidString
    }
}

/// This WKWebView ignores bottom safe area inset
class FullScreenWebView: WKWebView {
    override var safeAreaInsets: UIEdgeInsets {
        let insets = super.safeAreaInsets
        
        return UIEdgeInsets(top: insets.top, left: insets.left, bottom: 0, right: insets.right)
    }
}
