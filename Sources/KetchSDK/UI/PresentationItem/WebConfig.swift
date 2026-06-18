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
        let config = WebConfig(
            orgCode: orgCode,
            propertyName: propertyName,
            environmentCode: environmentCode,
            advertisingIdentifiers: advertisingIdentifiers,
            htmlFileName: htmlFileName
        )
        
        return config
    }

    private var bundleHTMLURL: URL? {
        // Handle bundling differences with swift packages vs cocoa pods when fetching static assests (index.html)
        #if SWIFT_PACKAGE
            // SWIFT_PACKAGE is a variable we define in Package.swift
            return Bundle.ketchUI!.url(forResource: htmlFileName, withExtension: "html")
        #else
            return Bundle(for: KetchUI.self).url(forResource: htmlFileName, withExtension: "html")
        #endif
    }
    /// Document base URL for `loadHTMLString`. Includes query params read by `index.html` via `document.location`.
    private var documentBaseURL: URL? {
        guard let bundleHTMLURL else { return nil }
        var urlComponents = URLComponents(string: bundleHTMLURL.absoluteString)
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
            } else if $0 == "ketch_css_inject" {
                // ignore this parameter
            } else if $0 == "ketch_web_resource_overrides" {
                // ignore this parameter
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

        if let bundleHTMLURL, let documentBaseURL, var htmlString = try? String(contentsOf: bundleHTMLURL) {
            // inject css if needed
            if let css = params["ketch_css_inject"] {
                let wrappedCSS = "<style>\n\(css)\n</style>"
                htmlString = htmlString.replacingOccurrences(of: "</head>", with: "\(wrappedCSS)\n</head>")
            }

            if let overridesJson = params["ketch_web_resource_overrides"],
               let script = Self.webResourceOverridesInjectScript(overridesJson: overridesJson) {
                htmlString = htmlString.replacingOccurrences(of: "<head>", with: "<head>\n\(script)")
            }
            
            // Query params (e.g. ketch_att) must be on the document base URL — index.html reads `document.location.searchParams`.
            webView.loadHTMLString(htmlString, baseURL: documentBaseURL)
        }

        return webView
    }

    private static func webResourceOverridesInjectScript(overridesJson: String) -> String? {
        guard overridesJson != "{}", !overridesJson.isEmpty else { return nil }
        return """
        <script>
        (function () {
          var overrides = \(overridesJson);
          if (!overrides || !Object.keys(overrides).length) return;
          function resolveUrl(url) {
            if (!url) return url;
            if (overrides[url]) return overrides[url];
            var base = url.split('?')[0].split('#')[0];
            if (base !== url && overrides[base]) return overrides[base];
            for (var key in overrides) {
              if (!Object.prototype.hasOwnProperty.call(overrides, key)) continue;
              if (key === url || key === base) continue;
              if (key.charAt(0) === '/' && base.indexOf(key) !== -1) return overrides[key];
              if (key.indexOf('://') !== -1) continue;
              if (base.endsWith(key) || base.indexOf('/' + key) !== -1) return overrides[key];
            }
            return url;
          }
          var srcDesc = Object.getOwnPropertyDescriptor(HTMLScriptElement.prototype, 'src');
          if (srcDesc && srcDesc.set) {
            var nativeSrcSet = srcDesc.set;
            var nativeSrcGet = srcDesc.get;
            Object.defineProperty(HTMLScriptElement.prototype, 'src', {
              set: function (value) { nativeSrcSet.call(this, resolveUrl(value)); },
              get: nativeSrcGet,
              configurable: true,
            });
          }
          var origSetAttribute = Element.prototype.setAttribute;
          Element.prototype.setAttribute = function (name, value) {
            if (name === 'src' && this.tagName === 'SCRIPT') {
              return origSetAttribute.call(this, name, resolveUrl(value));
            }
            return origSetAttribute.call(this, name, value);
          };
          if (window.fetch) {
            var origFetch = window.fetch.bind(window);
            window.fetch = function (input, init) {
              if (typeof input === 'string') {
                var mapped = resolveUrl(input);
                if (mapped !== input) input = mapped;
              } else if (input && input.url) {
                var mappedUrl = resolveUrl(input.url);
                if (mappedUrl !== input.url) input = new Request(mappedUrl, input);
              }
              return origFetch(input, init);
            };
          }
        })();
        </script>
        """
    }
}

extension WebConfig: Identifiable {
    var id: String {
        orgCode + propertyName
    }
}
