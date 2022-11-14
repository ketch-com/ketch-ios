//
//  ContentView2.swift
//  KetchSDK
//
//  Created by Anton Lyfar on 08.11.2022.
//

import SwiftUI
import KetchSDK

struct ContentView2: View {
    let ketch: Ketch
    @ObservedObject var ketchUI: KetchUI

    init() {
        ketch = KetchSDK.create(
            organizationCode: "transcenda",
            propertyCode: "website_smart_tag",
            environmentCode: "production",
            controllerCode: "my_controller",
            identities: ["idfa" : "00000000-0000-0000-0000-000000000000"]
        )

        ketch.add(plugins: [TCF(), CCPA()])
        ketchUI = KetchUI(ketch: ketch)
    }

    var body: some View {
        ZStack {
            Color(.systemGray6).ignoresSafeArea()
            VStack(spacing: 40) {
                Button("Configuration")         { ketch.loadConfiguration() }
                Button("Configuration GDPR")    { ketch.loadConfiguration(jurisdiction: Jurisdiction.GDPR) }
                Button("Configuration CCPA")    { ketch.loadConfiguration(jurisdiction: Jurisdiction.CCPA) }
                Button("Invoke Rights")         { ketch.invokeRights(user: user) }
                Button("Get Consent")           { ketch.loadConsent() }
                Button("Update Consent")        { ketch.updateConsent() }
                    .padding(.bottom, 40)
                Button("Show Banner")           { ketchUI.showBanner() }
                Button("Show Modal")            { ketchUI.showModal() }
                Button("Show JIT")              { ketchUI.showJIT() }
                Button("Show Preference")       { ketchUI.showPreference() }
            }
        }
        .fullScreenCover(item: $ketchUI.presentationItem, content: \.content)
    }
}

extension ContentView2 {
    var user: KetchSDK.InvokeRightConfig.User {
        .init(
            email: "user@email.com",
            first: "FirstName",
            last: "LastName",
            country: nil,
            stateRegion: nil,
            description: nil,
            phone: nil,
            postalCode: nil,
            addressLine1: nil,
            addressLine2: nil
        )
    }

    enum Jurisdiction {
        static let GDPR = "gdpr"
        static let CCPA = "ccpa"
    }
}

struct ContentView2_Previews: PreviewProvider {
    static var previews: some View {
        ContentView2()
    }
}
