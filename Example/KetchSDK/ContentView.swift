//
//  ContentView.swift
//  KetchSDK_Tests
//
//  Created by Anton Lyfar on 08.11.2022.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import SwiftUI
import KetchSDK

struct ContentView: View {
    let ketch: Ketch

    enum Constants {
        enum Jurisdiction {
            static let GDPR = "gdpr"
            static let CCPA = "ccpa"
        }
    }

    init() {
        ketch = KetchSDK.create(
            organizationCode: "transcenda",
            propertyCode: "website_smart_tag",
            environmentCode: "production",
            controllerCode: "my_controller",
            identities: ["idfa" : "00000000-0000-0000-0000-000000000000"]
        )

        ketch.add(plugins: [
            TCF(),
            CCPA()
        ])
    }

    var body: some View {
        VStack(spacing: 40) {
            Button("Configuration") {
                ketch.loadConfiguration()
            }

            Button("Configuration GDPR") {
                ketch.loadConfiguration(jurisdiction: Constants.Jurisdiction.GDPR)
            }

            Button("Configuration CCPA") {
                ketch.loadConfiguration(jurisdiction: Constants.Jurisdiction.CCPA)
            }

            Button("Invoke Rights") {
                ketch.invokeRights(
                    user: KetchSDK.InvokeRightConfig.User(
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
                )
            }

            Button("Get Consent") {
                ketch.loadConsent()
            }

            Button("Update Consent") {
                ketch.updateConsent()
            }

            Button("Show Banner") {

            }

            Button("Show Modal") {

            }

            Button("Show JIT") {

            }

            Button("Show Preference") {

            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
