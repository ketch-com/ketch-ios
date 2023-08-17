//
//  LogoSection.swift
//  KetchSDK
//

import SwiftUI

struct LogoSection: View {
    let ketchUrl = URL(string: "http://ketch.com")!
    let textContent: String
    var body: some View {
        HStack {
            Text(textContent)
                .font(.system(size: 12))
            Image("Logo", bundle: .ketchUI)
        }
        .onTapGesture {
            UIApplication.shared.open(ketchUrl)
        }
    }
}
