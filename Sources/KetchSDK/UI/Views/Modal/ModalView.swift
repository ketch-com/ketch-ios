//
//  ModalView.swift
//  KetchSDK
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
    @ObservedObject private var consents = UserConsents()

    @Environment(\.openURL) var openURL
    @Environment(\.presentationMode) private var presentationMode: Binding<PresentationMode>

    init(props: Props.Modal, actionHandler: @escaping (Action) -> KetchUI.PresentationItem?) {
        self.props = props
        self.actionHandler = actionHandler
        consents = props.purposes.generateConsents()
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
                            purposeConsents: $consents.purposeConsents,
                            vendorConsents: $consents.vendorConsents
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
                                            purposeCodeConsents: consents.purposeConsents.reduce(
                                                into: [String: Bool]()
                                            ) { result, purposeConsent in
                                                result[purposeConsent.purpose.code] = purposeConsent.consent
                                            },
                                            vendors: consents.vendorConsents
                                                .filter(\.isAccepted)
                                                .map(\.id)
                                        )
                                    )
                                    presentationMode.wrappedValue.dismiss()
                                }
                            }

                            HStack {
                                LogoSection()
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

struct ModalView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.gray
            ModalView(
                props: Props.Modal(
                    title: "Privacy Center",
                    showCloseIcon: true,
                    purposes: Props.PurposesList(
                        bodyTitle: "About Your Privacy",
                        bodyDescription: "Welcome! We’re glad you\'re here and want you to know that we respect your privacy and your right to control how we collect, use, and share your personal data. Listed below are the purposes for which we process your data--please indicate whether you consent to such processing.[Privacy Policy](privacyPolicy)",
                        consentTitle: "PURPOSES",
                        hideConsentTitle: false,
                        hideLegalBases: false,
                        purposes: [
                            .init(code: "tcf.purpose_1",
                                  name: "Store and/or access information on a device",
                                  description: "Cookies, device identifiers, or other information can be stored or accessed on your device for the purposes presented to you.",
                                  legalBasisCode: "consent_optin",
                                  requiresPrivacyPolicy: true,
                                  requiresOptIn: true,
                                  allowsOptOut: true,
                                  requiresDisplay: true,
                                  categories: [],
                                  tcfType: "purpose",
                                  tcfID: "1",
                                  canonicalPurposeCode: "analytics",
                                  legalBasisName: "Consent - Opt In",
                                  legalBasisDescription: "Data subject has affirmatively and unambiguously consented to the processing for one or more specific purposes"
                            ),
                            .init(code: "essential_services",
                                  name: "Essential Services",
                                  description: "Collection and processing of personal data to enable functionality that is essential to providing our services, including security activities, debugging, authentication, and fraud prevention, as well as contacting you with information related to products/services you have used or purchased; we may set essential cookies or other trackers for these purposes.",
                                  legalBasisCode: "legitimateinterest",
                                  requiresPrivacyPolicy: true,
                                  requiresOptIn: nil,
                                  allowsOptOut: nil,
                                  requiresDisplay: true,
                                  categories: [],
                                  tcfType: nil,
                                  tcfID: nil,
                                  canonicalPurposeCode: "essential_services",
                                  legalBasisName: "Legitimate Interest - Non-Objectable",
                                  legalBasisDescription: "Necessary for the purposes of the legitimate interests pursued by the controller or by a third party, except where such interests are overridden by the interests or fundamental rights and freedoms of the data subject"
                            ),
                            .init(code: "analytics",
                                  name: "Analytics",
                                  description: "Collection and analysis of personal data to further our business goals; for example, analysis of behavior of website visitors, creation of target lists for marketing and sales, and measurement of advertising performance.",
                                  legalBasisCode: "consent_optin",
                                  requiresPrivacyPolicy: true,
                                  requiresOptIn: true,
                                  allowsOptOut: true,
                                  requiresDisplay: true,
                                  categories: [],
                                  tcfType: nil,
                                  tcfID: nil,
                                  canonicalPurposeCode: "analytics",
                                  legalBasisName: "Consent - Opt In",
                                  legalBasisDescription: "Data subject has affirmatively and unambiguously consented to the processing for one or more specific purposes"
                            )
                        ],
                        vendors: [],
                        purposesConsent: ["1001": true, "1002": true, "1003": false],
                        vendorsConsent: [],
                        theme: .init(
                            bodyBackgroundColor: .white,
                            contentColor: .black,
                            linkColor: .blue
                        )
                    ),
                    saveButton: .init(
                        text: "Save",
                        theme: Props.Button.Theme(
                            borderRadius: 5,
                            textColor: .white,
                            borderColor: .blue,
                            backgroundColor: .blue
                        )
                    ),
                    theme: Props.Modal.Theme(
                        headerBackgroundColor: .black,
                        headerTextColor: .white,
                        bodyBackgroundColor: .white,
                        contentColor: .black,
                        linkColor: .blue,
                        switchOffColor: .gray,
                        switchOnColor: .black,
                        borderRadius: 5,
                        firstButtonBackgroundColor: .white,
                        firstButtonBorderColor: .blue,
                        firstButtonTextColor: .blue
                    )
                )
            ) { _ in nil }
        }
    }
}
