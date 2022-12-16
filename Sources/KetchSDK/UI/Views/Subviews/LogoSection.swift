//
//  LogoSection.swift
//  KetchSDK
//
//  Created by Anton Lyfar on 13.12.2022.
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
