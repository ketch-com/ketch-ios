//
//  ContentView.swift
//  KetchSDK
//

import SwiftUI
import KetchSDK
import AdSupport
import AppTrackingTransparency

class ContentViewModel: ObservableObject {
    @Published var ketch: Ketch?
    @Published var ketchUI: KetchUI?
    @Published var authorizationDenied = false

    init() { }

    func requestTrackingAuthorization() {
        ATTrackingManager.requestTrackingAuthorization { authorizationStatus in
            if case .authorized = authorizationStatus {
                let advertisingId = ASIdentifierManager.shared().advertisingIdentifier

                DispatchQueue.main.async {
                    self.setupKetch(advertisingIdentifier: advertisingId)
                }
            } else if case .denied = authorizationStatus {
                self.authorizationDenied = true
            }
        }
    }

    private func setupKetch(advertisingIdentifier: UUID) {
        let ketch = KetchSDK.create(
            organizationCode: "transcenda",
            propertyCode: "website_smart_tag",
            environmentCode: "production",
            controllerCode: "my_controller",
            identities: [.idfa(advertisingIdentifier.uuidString)]
        )

        ketch.add(plugins: [TCF(), CCPA()])

        self.ketch = ketch
        ketchUI = KetchUI(ketch: ketch)
    }
}

struct ContentView: View {
    @StateObject private var viewModel = ContentViewModel()
    @State var showDialogsAutomatically = false

    var body: some View {
        VStack(spacing: 40) {
            HStack {
                Text("Show Dialogs Automatically")
                Toggle("", isOn: $showDialogsAutomatically)
                    .labelsHidden()
            }

            if let ketch = viewModel.ketch {
                KetchTestView(ketch: ketch)
            }

            if let ketchUI = viewModel.ketchUI {
                KetchUITestView(ketchUI: ketchUI)
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                //  Delay after SwiftUI view appearing is required for alert presenting, otherwise it will not be shown
                viewModel.requestTrackingAuthorization()
            }
        }
        .onChange(of: showDialogsAutomatically) { value in
            viewModel.ketchUI?.showDialogsIfNeeded = value
        }
        .alert(isPresented: $viewModel.authorizationDenied) {
            Alert(
                title: Text("Tracking Authorization Denied by app settings"),
                message: Text("Please allow tracking in Settings -> Privacy -> Tracking"),
                primaryButton: .cancel(Text("Cancel")),
                secondaryButton: .default(
                    Text("Edit preferences"),
                    action: {
                        if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                            UIApplication.shared.open(settingsURL)
                        }
                    }
                )
            )
        }
    }
}

struct KetchTestView: View {
    enum Jurisdiction {
        static let GDPR = "gdpr"
        static let CCPA = "ccpa"
    }

    @StateObject var ketch: Ketch

    var body: some View {
        VStack(spacing: 40) {
            Button("Configuration")      { ketch.loadConfiguration() }
            Button("Configuration GDPR") { ketch.loadConfiguration(jurisdiction: Jurisdiction.GDPR) }
            Button("Configuration CCPA") { ketch.loadConfiguration(jurisdiction: Jurisdiction.CCPA) }

            if let config = ketch.configuration {
                Button("Invoke Rights")  { ketch.invokeRights(right: config.rights?.first, user: user) }
                Button("Get Consent")    { ketch.loadConsent() }
                Button("Update Consent") {
                    let purposes = config.purposes?
                        .reduce(into: [String: KetchSDK.ConsentUpdate.PurposeAllowedLegalBasis]()) { result, purpose in
                            result[purpose.code] = .init(allowed: true, legalBasisCode: purpose.legalBasisCode)
                        }

                    let vendors = config.vendors?.map(\.id)

                    ketch.updateConsent(purposes: purposes, vendors: vendors)
                }
            }
        }
    }

    private var user: KetchSDK.InvokeRightConfig.User {
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
}

struct KetchUITestView: View {
    @StateObject var ketchUI: KetchUI

    var body: some View {
        VStack(spacing: 40) {
            if let config = ketchUI.configuration, ketchUI.consentStatus != nil {
                Button("Show Banner")     { ketchUI.showBanner() }
                Button("Show Modal")      { ketchUI.showModal() }
                Button("Show Preference") { ketchUI.showPreference() }
                Button("Show JIT")        {
                    if let purpose = config.purposes?.first {
                        ketchUI.showJIT(purpose: purpose)
                    }
                }
            }
        }
        .fullScreenCover(item: $ketchUI.presentationItem, content: \.content)
    }
}
