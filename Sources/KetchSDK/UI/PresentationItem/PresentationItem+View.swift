//
//  PresentationItem+View.swift
//  KetchSDK
//

import SwiftUI

struct PreferencesWebView: UIViewRepresentable {
    let config: ConsentConfig
    @Environment(\.presentationMode) private var presentationMode

    func makeUIView(context: Context) -> some UIView {
        config.configWebApp ??
        config.preferencesWebView(
            onClose: {
                presentationMode.wrappedValue.dismiss()
            }
        )
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) { }
}
