//
//  PreferenceView.swift
//  KetchSDK
//
//  Created by Anton Lyfar on 10.11.2022.
//

import SwiftUI

struct PreferenceView: View {
    struct Props {
        let title: String
        let privacyPolicy: Tab
        let preferences: PreferencesTab
        let dataRights: Tab
        let theme: Theme
        let actionHandler: (Action) -> KetchUI.PresentationItem?

        struct Theme {
            let titleFontSize: CGFloat = 20
            let textFontSize: CGFloat = 14

            let contentColor: Color
            let backgroundColor: Color
            let linkColor: Color
            let borderRadius: Int

            let buttonHeight: CGFloat = 44
            let buttonBorderWidth: CGFloat = 1
            let firstButtonTextColor: Color
            let firstButtonBorderColor: Color
            let firstButtonBackgroundColor: Color
            let secondButtonTextColor: Color
            let secondButtonBorderColor: Color
            let secondButtonBackgroundColor: Color
        }

        enum TabType: String, Identifiable, Hashable, CaseIterable {
            case privacyPolicy
            case preferences
            case dataRights

            var id: String { rawValue }
        }

        struct Tab: Identifiable, Hashable {
            var id: String { tabName }

            let tabName: String
            let title: String?
            let text: String?
        }

        struct PreferencesTab: Identifiable {
            var id: String { tabName }

            let tabName: String
            let purposes: PurposesView.Props
        }

        enum Action {
            case close
            case openUrl(URL)
        }

        func tabTitle(with tab: TabType) -> String {
            switch tab {
            case .privacyPolicy: return privacyPolicy.tabName
            case .preferences: return preferences.tabName
            case .dataRights: return dataRights.tabName
            }
        }
    }

    let props: Props

    @State var presentationItem: KetchUI.PresentationItem?
    @State private var selectedTab = Props.TabType.privacyPolicy
    @ObservedObject private var consentsList = PurposesView.UserConsentsList()

    @Environment(\.openURL) var openURL
    @Environment(\.presentationMode) private var presentationMode: Binding<PresentationMode>

    init(props: Props) {
        self.props = props
        consentsList = props.preferences.purposes.consentsList
    }

    var body: some View {
        VStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Spacer()
                    Text("Powered by")
                        .foregroundColor(props.theme.contentColor)
                }

                HStack {
                    Text(props.title)
                        .font(.system(size: props.theme.titleFontSize, weight: .heavy))
                        .foregroundColor(props.theme.contentColor)
                    Spacer()

                }

            }
            .padding(24)
            .background(Color.black)

            tabBar
                .background(Color.black)

            VStack {
                switch selectedTab {
                case .privacyPolicy: privacyPolicy
                case .preferences: preferences
                case .dataRights: dataRights
                }
            }
        }
        .background(Color.white)
    }

    @ViewBuilder
    var tabBar: some View {
        HStack(alignment: .top, spacing: 0) {
            ForEach(Props.TabType.allCases) { tab in
                let isSelectedTab = selectedTab == tab
                VStack {
                    Text(props.tabTitle(with: tab))
                        .foregroundColor(props.theme.contentColor)
                        .frame(maxWidth: .infinity)
                        .opacity(isSelectedTab ? 1 : 0.5)

                    if isSelectedTab {
                        RoundedRectangle(cornerRadius: 2)
                            .frame(height: 4)
                            .foregroundColor(props.theme.contentColor)
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
                    VStack(alignment: .leading, spacing: 12) {
                        if let title = props.privacyPolicy.title {
                            HStack {
                                Text(title)
                                    .font(.system(size: props.theme.titleFontSize, weight: .heavy))
                                    .foregroundColor(props.theme.contentColor)
                                Spacer()
                            }
                        }

                        KetchUI.PresentationItem.descriptionText(
                            with: props.privacyPolicy.text ?? ""
                        ) { url in
                            handle(action: .openUrl(url))
                        }
                        .font(.system(size: props.theme.textFontSize))
                        .padding(.bottom, 12)
                        .foregroundColor(props.theme.contentColor)
                        .accentColor(props.theme.linkColor)

                        Spacer()
                    }
                    .fullScreenCover(item: $presentationItem) { item in
                        item.content
                    }

                    button(
                        text: "Exit Settings",
                        theme: props.theme
                    ) {
                        handle(action: .close)
                    }
                }
                .padding(18)
            }
            .background(
                props.theme.backgroundColor
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
        Spacer()
    }

    @ViewBuilder
    var dataRights: some View {
        Spacer()
    }

    @ViewBuilder
    private func button(
        text: String,
        theme: Props.Theme,
        actionHandler: @escaping () -> Void
    ) -> some View {
        Button {
            actionHandler()
            presentationMode.wrappedValue.dismiss()
        } label: {
            Text(text)
                .font(.system(size: theme.textFontSize, weight: .semibold))
                .foregroundColor(theme.firstButtonTextColor)
                .frame(height: theme.buttonHeight)
                .frame(maxWidth: .infinity)
                .overlay(
                    RoundedRectangle(cornerRadius: CGFloat(props.theme.borderRadius))
                        .stroke(
                            theme.firstButtonBorderColor,
                            lineWidth: theme.buttonBorderWidth
                        )
                )
        }
        .background(
            theme.firstButtonBackgroundColor
                .cornerRadius(CGFloat(props.theme.borderRadius))
        )
    }

    private func handle(action: Props.Action) {
        presentationItem = props.actionHandler(action)
    }
}

struct PreferenceView_Previews: PreviewProvider {
    static var previews: some View {
        PreferenceView(
            props: PreferenceView.Props(
                title: "Your Privacy",
                privacyPolicy: .init(tabName: "Overview", title: "Privacy Policy", text: "Welcome! We're glad you're here and want you to know that we respect your privacy and your right to control how we collect, use, and store your personal data."),
                preferences: .init(
                    tabName: "Preferences",
                    purposes: PurposesView.Props(
                        bodyTitle: "Purposes",
                        bodyDescription: "Purposes bodyDescription",
                        consentTitle: "Consent Title",
                        purposes: [],
                        vendors: [],
                        theme: PurposesView.Props.Theme(
                            bodyBackgroundColor: .white,
                            contentColor: .black,
                            linkColor: .red
                        )
                    )
                ),
                dataRights: .init(tabName: "Data Rights", title: "Data Rights", text: ""),

                theme: PreferenceView.Props.Theme(
                    contentColor: .white,
                    backgroundColor: .black,
                    linkColor: .red,
                    borderRadius: 5,
                    firstButtonTextColor: .white,
                    firstButtonBorderColor: .blue,
                    firstButtonBackgroundColor: .blue,
                    secondButtonTextColor: .blue,
                    secondButtonBorderColor: .blue,
                    secondButtonBackgroundColor: .white
                )
            ) { _ in nil}
        )
    }
}
