//
//  PresentationItem+View.swift
//  KetchSDK
//

import SwiftUI

struct PreferencesWebView: UIViewRepresentable {
    let config: WebConfig
    @Environment(\.presentationMode) private var presentationMode

    func makeUIView(context: Context) -> some UIView {
        config.configWebApp ??
        config.preferencesWebView(
            with: .init { event, body in
                
            }
        )
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) { }
}
