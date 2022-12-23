//
//  PreferenceView.swift
//  KetchSDK
//

import SwiftUI

struct PreferenceView: View {
    enum Action {
        case onShow
        case close
        case openUrl(URL)
        case save(purposeCodeConsents: [String: Bool], vendors: [String])
        case request(right: DataRightCoding, user: UserDataCoding)
    }

    let props: Props.Preference
    let actionHandler: (Action) -> KetchUI.PresentationItem?

    @State var presentationItem: KetchUI.PresentationItem?
    @State private var selectedTab: Props.Preference.Tab = .overview
    @ObservedObject private var userConsents = UserConsents()

    @Environment(\.openURL) var openURL
    @Environment(\.presentationMode) private var presentationMode: Binding<PresentationMode>

    init(props: Props.Preference, actionHandler: @escaping (Action) -> KetchUI.PresentationItem?) {
        self.props = props
        self.actionHandler = actionHandler
        userConsents = props.consents.purposes.generateConsents()
    }

    var body: some View {
        VStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Spacer()
                    LogoSection()
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
        .onAppear { handle(action: .onShow) }
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
                purposeConsents: $userConsents.purposeConsents,
                vendorConsents: $userConsents.vendorConsents
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
                                purposeCodeConsents: userConsents.purposeConsents.reduce(
                                    into: [String: Bool]()
                                ) { result, purposeConsent in
                                    result[purposeConsent.purpose.code] = purposeConsent.consent
                                },
                                vendors: userConsents.vendorConsents
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
            case .submit(let right, let user): handle(action: .request(right: right, user: user))
            }
        }
    }

    private func handle(action: Action) {
        presentationItem = actionHandler(action)
    }
}
