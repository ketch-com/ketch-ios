//
//  PreferenceView.swift
//  KetchSDK
//
//  Created by Anton Lyfar on 10.11.2022.
//

import SwiftUI

struct PreferenceView: View {
    enum Action {
        case close
        case openUrl(URL)
    }

    let props: Props.Preference
    let actionHandler: (Action) -> KetchUI.PresentationItem?

    @State var presentationItem: KetchUI.PresentationItem?
    @State private var selectedTab = Props.Preference.TabType.privacyPolicy
    @ObservedObject private var consentsList = PurposesView.UserConsentsList()

    @Environment(\.openURL) var openURL
    @Environment(\.presentationMode) private var presentationMode: Binding<PresentationMode>

    init(props: Props.Preference, actionHandler: @escaping (Action) -> KetchUI.PresentationItem?) {
        self.props = props
        self.actionHandler = actionHandler
        consentsList = props.preferences.purposes.consentsList
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
                case .privacyPolicy: privacyPolicy
                case .preferences: preferences
                case .dataRights: dataRights
                }
            }
        }
        .background(props.theme.bodyBackgroundColor)
    }

    @ViewBuilder
    var tabBar: some View {
        HStack(alignment: .top, spacing: 0) {
            ForEach(Props.Preference.TabType.allCases) { tab in
                let isSelectedTab = selectedTab == tab
                VStack {
                    Text(props.tabTitle(with: tab))
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
    var privacyPolicy: some View {
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

                    button(
                        text: "Exit Settings",
                        theme: props.theme.firstButtonTheme
                    ) {
                        handle(action: .close)
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
        .ignoresSafeArea()
    }

    @ViewBuilder
    var preferences: some View {
        PurposesView(
            props: props.preferences.purposes,
            purposeConsents: $consentsList.purposeConsents,
            vendorConsents: $consentsList.vendorConsents
        ) { action in

        }
    }

    @ViewBuilder
    var dataRights: some View {
        Spacer()
    }

    @ViewBuilder
    private func button(
        text: String,
        theme: Props.Button.Theme,
        actionHandler: @escaping () -> Void
    ) -> some View {
        Button {
            actionHandler()
            presentationMode.wrappedValue.dismiss()
        } label: {
            Text(text)
                .font(.system(size: theme.fontSize, weight: .semibold))
                .foregroundColor(theme.textColor)
                .frame(height: theme.height)
                .frame(maxWidth: .infinity)
                .overlay(
                    RoundedRectangle(cornerRadius: CGFloat(props.theme.borderRadius))
                        .stroke(
                            theme.borderColor,
                            lineWidth: theme.borderWidth
                        )
                )
        }
        .background(
            theme.backgroundColor
                .cornerRadius(CGFloat(props.theme.borderRadius))
        )
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
