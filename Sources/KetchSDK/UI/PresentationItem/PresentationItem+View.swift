//
//  PresentationItem+View.swift
//  KetchSDK
//

#if !os(macOS)

import SwiftUI

struct PreferencesWebView: UIViewRepresentable {
    let config: WebConfig

    func makeUIView(context: Context) -> some UIView {
        config.configWebApp ??
        config.preferencesWebView(
            with: .init { event, body in
                
            }
        )
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) { }
}

#endif
