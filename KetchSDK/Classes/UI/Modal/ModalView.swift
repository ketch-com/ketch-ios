//
//  ModalView.swift
//  KetchSDK
//
//  Created by Anton Lyfar on 10.11.2022.
//

import SwiftUI

struct ModalView: View {
    let props: Props

    @State var presentationItem: KetchUI.PresentationItem?
    @ObservedObject private var consents: UserConsentsList

    @Environment(\.openURL) var openURL
    @Environment(\.presentationMode) private var presentationMode: Binding<PresentationMode>

    init(props: Props) {
        self.props = props
        consents = UserConsentsList(
            userConsents: props.purposes.map { purpose in
                UserConsent(
                    consent: purpose.consent || purpose.required,
                    required: purpose.required,
                    purpose: purpose
                )
            }
        )
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
                        ScrollView(showsIndicators: true) {
                            VStack(alignment: .leading, spacing: 16) {
                                Text(props.bodyTitle)
                                    .font(.system(size: 16, weight: .bold))

                                KetchUI.PresentationItem.descriptionText(with: props.bodyDescription) { url in
                                    handle(action: .openUrl(url))
                                }
                                .font(.system(size: props.theme.textFontSize))
                                .foregroundColor(props.theme.contentColor)
                                .accentColor(props.theme.linkColor)
                            }
                            .padding(18)

                            purposesView()
                        }
                        .background(props.theme.bodyBackgroundColor)

                        VStack(spacing: 24) {
                            if let saveButton = props.saveButton {
                                button(
                                    props: saveButton,
                                    cornerRadius: props.theme.borderRadius
                                ) {
                                    handle(
                                        action: .save(
                                            purposeCodeConsents: consents.userConsents.reduce(
                                                into: [String: Bool]()
                                            ) { result, userConsent in
                                                result[userConsent.purpose.code] = userConsent.consent
                                            }
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
            }
        }
    }

    @ViewBuilder
    private func button(
        props: Props.Button,
        cornerRadius: Int,
        actionHandler: @escaping () -> Void
    ) -> some View {
        Button {
            actionHandler()
            presentationMode.wrappedValue.dismiss()
        } label: {
            Text(props.text)
                .font(.system(size: props.fontSize, weight: .semibold))
                .foregroundColor(props.textColor)
                .frame(height: props.height)
                .frame(maxWidth: .infinity)
                .overlay(
                    RoundedRectangle(cornerRadius: CGFloat(cornerRadius))
                        .stroke(
                            props.borderColor,
                            lineWidth: props.borderWidth
                        )
                )
        }
        .background(
            props.backgroundColor
                .cornerRadius(CGFloat(cornerRadius))
        )
    }

    private func handle(action: Props.Action) {
        presentationItem = props.actionHandler(action)
    }

    @ViewBuilder
    func purposesView() -> some View {
        VStack {
            HStack {
                if let consentTitle = props.consentTitle {
                    Text(consentTitle)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(props.theme.contentColor)
                }
                Spacer()

                Button {
                    consents.setAll(false)
                } label: {
                    Text("Opt Out")
                        .padding(.horizontal)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.black)
                        .frame(height: 28)
                }
                .background(Color(UIColor.systemGray6).cornerRadius(5))

                Button {
                    consents.setAll(true)
                } label: {
                    Text("Opt In")
                        .padding(.horizontal)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.black)
                        .frame(height: 28)
                }
                .background(Color(UIColor.systemGray6).cornerRadius(5))
            }
            .padding(.horizontal)

            ForEach($consents.userConsents) { index, userConsent in
                PurposeCell(
                    consent: userConsent.consent,
                    purpose: userConsent.wrappedValue.purpose,
                    vendorsDestination: props.vendors.isEmpty ? nil : { vendorsView },
                    categoriesDestination: props.categories.isEmpty ? nil : { categoriesView }
                )
            }
        }
        .animation(.easeInOut(duration: 0.15))
    }

    @ViewBuilder
    var vendorsView: some View {
        VStack {
            Text("Vendors")
        }
    }

    @ViewBuilder
    var categoriesView: some View {
        VStack {
            Text("Categories")
        }
    }
}

extension ModalView.UserConsentsList {
    func setAll(_ value: Bool) {
        userConsents.enumerated().forEach { (index, _) in
            if userConsents[index].required { return }

            userConsents[index].consent = value
        }
    }
}

struct ModalView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.gray
            ModalView(
                props: ModalView.Props(
                    title: "Privacy Center",
                    showCloseIcon: true,
                    bodyTitle: "About Your Privacy",
                    bodyDescription: "Welcome! We’re glad you\'re here and want you to know that we respect your privacy and your right to control how we collect, use, and share your personal data. Listed below are the purposes for which we process your data--please indicate whether you consent to such processing.[Privacy Policy](privacyPolicy)",
                    consentTitle: "PURPOSES",

                    purposes: [
                        .init(
                            code: "1001",
                            consent: true,
                            required: true,
                            title: "Store and/or access information on a device",
                            legalBasisName: "Legal Basic: Consent - Opt In",
                            purposeDescription: "Cookies, device identifiers, or other information can be stored or accessed on your device for the purposes presented to you.",
                            legalBasisDescription: "Data subject has affirmatively and unambiguously consented to the processing for one or more specific purposes"
                        ),
                        .init(
                            code: "1002",
                            consent: false,
                            required: true,
                            title: "Store and/or access information on a device",
                            legalBasisName: "Legal Basic: Consent - Opt In",
                            purposeDescription: "Cookies, device identifiers, or other information can be stored or accessed on your device for the purposes presented to you.",
                            legalBasisDescription: "Data subject has affirmatively and unambiguously consented to the processing for one or more specific purposes"
                        ),
                        .init(
                            code: "1003",
                            consent: false,
                            required: false,
                            title: "Store and/or access information on a device",
                            legalBasisName: "Legal Basic: Consent - Opt In",
                            purposeDescription: "Cookies, device identifiers, or other information can be stored or accessed on your device for the purposes presented to you.",
                            legalBasisDescription: "Data subject has affirmatively and unambiguously consented to the processing for one or more specific purposes"
                        )
                    ],
                    vendors: [.init()],
                    categories: [.init()],

                    saveButton: ModalView.Props.Button(
                        text: "I understand",
                        textColor: .white,
                        borderColor: .blue,
                        backgroundColor: .blue
                    ),

                    theme: ModalView.Props.Theme(
                        headerBackgroundColor: .gray,
                        headerTextColor: .black,
                        bodyBackgroundColor: .white,
                        contentColor: .black,
                        linkColor: .red,
                        switchOffColor: .gray,
                        switchOnColor: .blue,
                        borderRadius: 5
                    ),
                    actionHandler: { action in nil }
                )
            )
        }
    }
}
