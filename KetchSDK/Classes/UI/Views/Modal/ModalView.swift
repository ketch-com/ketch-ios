//
//  ModalView.swift
//  KetchSDK
//
//  Created by Anton Lyfar on 10.11.2022.
//

import SwiftUI

struct ModalView: View {
    enum Action {
        case save(purposeCodeConsents: [String: Bool], vendors: [String])
        case close
        case openUrl(URL)
    }

    let props: Props.Modal
    let actionHandler: (Action) -> KetchUI.PresentationItem?

    @State var presentationItem: KetchUI.PresentationItem?
    @ObservedObject private var consentsList = UserConsentsList()

    @Environment(\.openURL) var openURL
    @Environment(\.presentationMode) private var presentationMode: Binding<PresentationMode>

    init(props: Props.Modal, actionHandler: @escaping (Action) -> KetchUI.PresentationItem?) {
        self.props = props
        self.actionHandler = actionHandler
        consentsList = props.purposes.generateConsentsList()
    }

    var body: some View {
        ZStack {
            VStack(alignment: .leading, spacing: 0) {
                HStack {
                    Text(props.title)
                        .font(.system(size: props.theme.titleFontSize, weight: .heavy))
                        .foregroundColor(props.theme.headerTextColor)
                    if props.showCloseIcon {
                        Spacer()
                        Button {
                            handle(action: .close)
                            presentationMode.wrappedValue.dismiss()
                        } label: {
                            Image(systemName: "xmark")
                        }
                        .foregroundColor(props.theme.headerTextColor)
                    }
                }
                .padding(.horizontal, 18)
                .padding(.vertical, 20)
                .background(props.theme.headerBackgroundColor)

                NavigationView {
                    VStack {
                        PurposesView(
                            props: props.purposes,
                            purposeConsents: $consentsList.purposeConsents,
                            vendorConsents: $consentsList.vendorConsents
                        ) {

                        } actionHandler: { action in
                            switch action {
                            case .close: handle(action: .close)
                            case .openUrl(let url): handle(action: .openUrl(url))
                            }
                        }

                        VStack(spacing: 24) {
                            if let saveButton = props.saveButton {
                                CustomButton(props: saveButton) {
                                    handle(
                                        action: .save(
                                            purposeCodeConsents: consentsList.purposeConsents.reduce(
                                                into: [String: Bool]()
                                            ) { result, purposeConsent in
                                                result[purposeConsent.purpose.code] = purposeConsent.consent
                                            },
                                            vendors: consentsList.vendorConsents
                                                .filter(\.isAccepted)
                                                .map(\.id)
                                        )
                                    )
                                    presentationMode.wrappedValue.dismiss()
                                }
                            }

                            HStack {
                                Text("Powered by")
                                    .foregroundColor(props.theme.headerTextColor)
                                Spacer()
                            }
                        }
                        .padding(24)
                        .background(props.theme.headerBackgroundColor)
                    }
                }
                .accentColor(props.theme.contentColor)
            }
        }
    }

    private func handle(action: Action) {
        presentationItem = actionHandler(action)
    }
}

//struct ModalView_Previews: PreviewProvider {
//    static var previews: some View {
//        ZStack {
//            Color.gray
//            ModalView(
//                props: ModalView.Props(
//                    title: "Privacy Center",
//                    showCloseIcon: true,
//                    bodyTitle: "About Your Privacy",
//                    bodyDescription: "Welcome! We’re glad you\'re here and want you to know that we respect your privacy and your right to control how we collect, use, and share your personal data. Listed below are the purposes for which we process your data--please indicate whether you consent to such processing.[Privacy Policy](privacyPolicy)",
//                    consentTitle: "PURPOSES",
//
//                    purposes: [
//                        .init(
//                            code: "1001",
//                            consent: true,
//                            required: true,
//                            title: "Store and/or access information on a device",
//                            legalBasisName: "Legal Basic: Consent - Opt In",
//                            purposeDescription: "Cookies, device identifiers, or other information can be stored or accessed on your device for the purposes presented to you.",
//                            legalBasisDescription: "Data subject has affirmatively and unambiguously consented to the processing for one or more specific purposes",
//                            categories: [.init(
//                                name: "User Identifiers",
//                                retentionPeriod: "180 days",
//                                externalTransfers: "None",
//                                description: "Identifiers such as name, address, unique personal identifier, email, or phone number."
//                            )]
//                        ),
//                        .init(
//                            code: "1002",
//                            consent: false,
//                            required: true,
//                            title: "Store and/or access information on a device",
//                            legalBasisName: nil,
//                            purposeDescription: "Cookies, device identifiers, or other information can be stored or accessed on your device for the purposes presented to you.",
//                            legalBasisDescription: "Data subject has affirmatively and unambiguously consented to the processing for one or more specific purposes",
//                            categories: [.init(
//                                name: "User Identifiers",
//                                retentionPeriod: "180 days",
//                                externalTransfers: "None",
//                                description: "Identifiers such as name, address, unique personal identifier, email, or phone number."
//                            )]
//                        ),
//                        .init(
//                            code: "1003",
//                            consent: false,
//                            required: false,
//                            title: "Store and/or access information on a device",
//                            legalBasisName: "Legal Basic: Consent - Opt In",
//                            purposeDescription: "Cookies, device identifiers, or other information can be stored or accessed on your device for the purposes presented to you.",
//                            legalBasisDescription: "Data subject has affirmatively and unambiguously consented to the processing for one or more specific purposes",
//                            categories: []
//                        )
//                    ],
//                    vendors: [.init(
//                        id: "101", name: "Vendor", isAccepted: true,
//                        purposes: [.init(name: "name", legalBasis: "basis")], specialPurposes: [.init(name: "name", legalBasis: "basis")], features: [.init(name: "name", legalBasis: "basis")], specialFeatures: [.init(name: "name", legalBasis: "basis")],
//                        policyUrl: URL(string: "www.google.com")
//                    )],
//
//                    saveButton: ModalView.Props.Button(
//                        text: "I understand",
//                        textColor: .white,
//                        borderColor: .blue,
//                        backgroundColor: .blue
//                    ),
//
//                    theme: ModalView.Props.Theme(
//                        headerBackgroundColor: .gray,
//                        headerTextColor: .black,
//                        bodyBackgroundColor: .white,
//                        contentColor: .black,
//                        linkColor: .red,
//                        switchOffColor: .gray,
//                        switchOnColor: .blue,
//                        borderRadius: 5
//                    ),
//                    actionHandler: { action in nil }
//                )
//            )
//        }
//    }
//}
