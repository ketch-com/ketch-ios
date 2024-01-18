//
//  PresentationItem.swift
//  KetchSDK
//

import SwiftUI
import WebKit

extension KetchUI {
    public struct WebPresentationItem: Identifiable, Equatable {
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
        let onClose: (() -> Void)?
        var preloaded: WKWebView
        let config: ConsentConfig
        public var presentationConfig: PresentationConfig?
        
        init(item: WebExperienceItem, onClose: (() -> Void)?) {
            self.item = item
            config = ConsentConfig(
                orgCode: item.orgCode,
                propertyName: item.propertyName,
                advertisingIdentifier: item.advertisingIdentifier
            )
            self.onClose = onClose
            preloaded = config.preferencesWebView(onClose: onClose)
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
            preloaded = config.preferencesWebView(onClose: onClose)
        }
        
        private func webExperience(orgCode: String,
                                   propertyName: String,
                                   advertisingIdentifier: UUID) -> some View {
            var config = config
            config.configWebApp = preloaded
            
            return PreferencesWebView(config: config)
                .asResponsiveSheet(style: .custom)
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
