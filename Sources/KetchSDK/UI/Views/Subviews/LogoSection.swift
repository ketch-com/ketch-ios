//
//  LogoSection.swift
//  KetchSDK
//

import SwiftUI

struct LogoSection: View {
    let ketchUrl = URL(string: "http://ketch.com")!

    var body: some View {
        HStack {
            Text("Powered by")
                .font(.system(size: 12))
            Image("Logo", bundle: .ketchUI)
        }
        .onTapGesture {
            UIApplication.shared.open(ketchUrl)
        }
    }
}
