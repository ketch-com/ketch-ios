//
//  WebConfig.swift
//  iOS Ketch Pref Center using SwiftUI
//

import Foundation
import WebKit

struct WebConfig {
    let orgCode: String
    let propertyName: String
    let environmentCode: String
    let advertisingIdentifiers: [Ketch.Identity]
    let htmlFileName: String
    var params = [String: String]()
    var configWebApp: WKWebView?

    init(
        orgCode: String,
        propertyName: String,
        environmentCode: String,
        advertisingIdentifiers: [Ketch.Identity],
        htmlFileName: String = "index"
    ) {
        self.propertyName = propertyName
        self.orgCode = orgCode
        self.environmentCode = environmentCode
        self.advertisingIdentifiers = advertisingIdentifiers
        self.htmlFileName = htmlFileName
    }

    static func configure(
        orgCode: String,
        propertyName: String,
        environmentCode: String,
        advertisingIdentifiers: [Ketch.Identity],
        htmlFileName: String = "index"
    ) -> Self {
        var config = WebConfig(
            orgCode: orgCode,
            propertyName: propertyName,
            environmentCode: environmentCode,
            advertisingIdentifiers: advertisingIdentifiers,
            htmlFileName: htmlFileName
        )
        
        return config
    }

    private var fileUrl: URL? {
        // Handle bundling differences with swift packages vs cocoa pods when fetching static assests (index.html)
        #if SWIFT_PACKAGE
            // SWIFT_PACKAGE is a variable we define in Package.swift
            let url = Bundle.ketchUI!.url(forResource: htmlFileName, withExtension: "html")!
        #else
            let url = Bundle(for: KetchUI.self).url(forResource: htmlFileName, withExtension: "html")!
        #endif
        var urlComponents = URLComponents(string: url.absoluteString)
        urlComponents?.queryItems = queryItems
        return urlComponents?.url
    }

    private var queryItems: [URLQueryItem] {
        var defaultQuery = [
            "propertyName": URLQueryItem(name: "propertyName", value: propertyName),
            "orgCode": URLQueryItem(name: "orgCode", value: orgCode),
            "ketch_env": URLQueryItem(name: "ketch_env", value: environmentCode),
            "isMobileSdk": URLQueryItem(name: "isMobileSdk", value: "true")
        ]
        
        advertisingIdentifiers.forEach {
            defaultQuery[$0.key] = URLQueryItem(name: $0.key, value: $0.value)
        }
        
        params.forEach {
            // TODO: remove after web fix
            if $0 == "ketch_lang" {
                defaultQuery[$0] = URLQueryItem(name: $0, value: $1.lowercased())
            } else {
                defaultQuery[$0] = URLQueryItem(name: $0, value: $1)
            }
        }
        
        return Array(defaultQuery.values)
    }

    func preferencesWebView(with webHandler: WebHandler) -> WKWebView {
        let preferences = WKWebpagePreferences()
        preferences.allowsContentJavaScript = true
        
        let configuration = WKWebViewConfiguration()
        configuration.defaultWebpagePreferences = preferences

        WebHandler.Event.allCases.forEach { event in
            configuration.userContentController.add(webHandler, name: event.rawValue)
        }

        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.backgroundColor = .clear
        webView.isOpaque = false
        webView.scrollView.backgroundColor = .clear
        webView.scrollView.contentInsetAdjustmentBehavior = .never
        webView.scrollView.bounces = false
        if #available(iOS 16.4, *) { webView.isInspectable = true; }

        if let fileUrl = fileUrl {
            webView.load(URLRequest(url: fileUrl))
        }

        return webView
    }
}

extension WebConfig: Identifiable {
    var id: String {
        orgCode + propertyName
    }
}
