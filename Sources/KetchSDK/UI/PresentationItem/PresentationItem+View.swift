//
//  PresentationItem+View.swift
//  KetchSDK
//

import SwiftUI
import WebKit

struct PreferencesWebView: UIViewRepresentable {
    let config: WebConfig

    func makeUIView(context: Context) -> some UIView {
        config.configWebApp ?? WKWebView(frame: .zero)
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) { }
}
