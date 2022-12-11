//
//  PreferenceView.swift
//  KetchSDK
//
//  Created by Anton Lyfar on 10.11.2022.
//

import SwiftUI

struct PreferenceView: View {
    enum Action {
        case save(purposeCodeConsents: [String: Bool], vendors: [String])
        case close
        case openUrl(URL)
    }

    let props: Props.Preference
    let actionHandler: (Action) -> KetchUI.PresentationItem?

    @State var presentationItem: KetchUI.PresentationItem?
    @State private var selectedTab: Props.Preference.Tab = .overview
    @ObservedObject private var consentsList = UserConsentsList()

    @Environment(\.openURL) var openURL
    @Environment(\.presentationMode) private var presentationMode: Binding<PresentationMode>

    init(props: Props.Preference, actionHandler: @escaping (Action) -> KetchUI.PresentationItem?) {
        self.props = props
        self.actionHandler = actionHandler
        consentsList = props.consents.purposes.generateConsentsList()
    }

    var body: some View {
        VStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Spacer()
                    Text("Powered by")
                        .foregroundColor(props.theme.headerTextColor)
                }

                HStack {
                    Text(props.title)
                        .font(.system(size: props.theme.titleFontSize, weight: .heavy))
                        .foregroundColor(props.theme.headerTextColor)
                    Spacer()

                }

            }
            .padding(24)
            .background(props.theme.headerBackgroundColor)

            tabBar
                .background(props.theme.headerBackgroundColor)

            VStack {
                switch selectedTab {
                case .overview: overview
                case .consents: consents
                case .rights: rights
                }
            }
        }
        .background(props.theme.bodyBackgroundColor)
    }

    @ViewBuilder
    var tabBar: some View {
        HStack(alignment: .top, spacing: 0) {
            ForEach(Props.Preference.Tab.allCases) { tab in
                let isSelectedTab = selectedTab == tab
                VStack {
                    Text(props.tabName(with: tab))
                        .foregroundColor(props.theme.headerTextColor)
                        .frame(maxWidth: .infinity)
                        .opacity(isSelectedTab ? 1 : 0.5)

                    if isSelectedTab {
                        RoundedRectangle(cornerRadius: 2)
                            .frame(height: 4)
                            .foregroundColor(props.theme.headerTextColor)
                    }
                }
                .onTapGesture {
                    selectedTab = tab
                }
            }
        }
    }

    @ViewBuilder
    var overview: some View {
        ScrollView {
            VStack {
                VStack {
                    TitleDescriptionSection(
                        props: props.titleDescriptionSectionProps
                    ) { action in
                        switch action {
                        case .openUrl(let url): handle(action: .openUrl(url))
                        }
                    }
                    .fullScreenCover(item: $presentationItem) { item in
                        item.content
                    }

                    Spacer()

                    CustomButton(
                        props: Props.Button(
                            text: "Exit Settings",
                            theme: props.theme.firstButtonTheme
                        )
                    ) {
                        handle(action: .close)
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                .padding(18)
            }
            .background(
                props.theme.bodyBackgroundColor
                    .cornerRadius(8)
            )
            .padding(12)
            .padding(.bottom, 12)
        }
        .background(Color(UIColor.systemGray6))
    }

    @ViewBuilder
    var consents: some View {
        NavigationView {
            PurposesView(
                props: props.consents.purposes,
                purposeConsents: $consentsList.purposeConsents,
                vendorConsents: $consentsList.vendorConsents
            ) {
                VStack(spacing: 24) {
                    CustomButton(
                        props: .init(
                            text: "Save",
                            theme: props.theme.firstButtonTheme
                        )
                    ) {
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

                    CustomButton(
                        props: .init(
                            text: "Cancel",
                            theme: props.theme.secondaryButtonTheme
                        )
                    ) {

                        presentationMode.wrappedValue.dismiss()
                    }
                }
                .padding(24)
            } actionHandler: { action in
                switch action {
                case .openUrl(let url): handle(action: .openUrl(url))
                case .close: handle(action: .close)
                }
            }
        }
        .accentColor(props.theme.contentColor)
    }

    @ViewBuilder
    var rights: some View {
        DataRightsView(
            props: .init(
                bodyTitle: props.rights.title,
                bodyDescription: props.rights.text,
                theme: props.theme.dataRightsTheme,
                rights: props.rights.rights
            )
        ) { action in
            switch action {
            case .openUrl(let url): handle(action: .openUrl(url))
            case .close: handle(action: .close)
            case .submit(let request):
                break
            }
        }
    }

    private func handle(action: Action) {
        presentationItem = actionHandler(action)
    }
}

//struct PreferenceView_Previews: PreviewProvider {
//    static var previews: some View {
//        PreferenceView(
//            props: PreferenceView.Props(
//                title: "Your Privacy",
//                privacyPolicy: .init(tabName: "Overview", title: "Privacy Policy", text: "Welcome! We're glad you're here and want you to know that we respect your privacy and your right to control how we collect, use, and store your personal data."),
//                preferences: .init(
//                    tabName: "Preferences",
//                    purposes: PurposesView.Props(
//                        bodyTitle: "Purposes",
//                        bodyDescription: "Purposes bodyDescription",
//                        consentTitle: "Consent Title",
//                        purposes: [],
//                        vendors: [],
//                        theme: PurposesView.Props.Theme(
//                            bodyBackgroundColor: .white,
//                            contentColor: .black,
//                            linkColor: .red
//                        )
//                    )
//                ),
//                dataRights: .init(tabName: "Data Rights", title: "Data Rights", text: ""),
//
//                theme: PreferenceView.Props.Theme(
//                    contentColor: .white,
//                    backgroundColor: .black,
//                    linkColor: .red,
//                    borderRadius: 5,
//                    firstButtonTextColor: .white,
//                    firstButtonBorderColor: .blue,
//                    firstButtonBackgroundColor: .blue,
//                    secondButtonTextColor: .blue,
//                    secondButtonBorderColor: .blue,
//                    secondButtonBackgroundColor: .white
//                )
//            ) { _ in nil}
//        )
//    }
//}
