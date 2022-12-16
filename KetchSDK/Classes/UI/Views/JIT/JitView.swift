//
//  JitView.swift
//  KetchSDK
//
//  Created by Anton Lyfar on 10.11.2022.
//

import SwiftUI

struct JitView: View {
    enum Action {
        case save(purposeCodeConsent: Bool, vendors: [String])
        case close
        case moreInfo
        case openUrl(URL)
    }

    let props: Props.Jit
    let actionHandler: (Action) -> KetchUI.PresentationItem?

    @State var presentationItem: KetchUI.PresentationItem?
    @ObservedObject private var consent = UserConsents()

    @Environment(\.openURL) var openURL
    @Environment(\.presentationMode) private var presentationMode: Binding<PresentationMode>

    init(props: Props.Jit, actionHandler: @escaping (Action) -> KetchUI.PresentationItem?) {
        self.props = props
        self.actionHandler = actionHandler
        consent = props.generateConsents()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text(props.title ?? "")
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
                        VStack(alignment: .leading, spacing: 18) {
                            TitleDescriptionSection(
                                props: props.titleDescriptionSectionProps
                            ) { action in
                                switch action {
                                case .openUrl(let url): handle(action: .openUrl(url))
                                }
                            }

                            Divider()

                            purposeView()
                        }
                        .padding(18)
                    }
                    .background(props.theme.backgroundColor)

                    VStack(spacing: 24) {
                        CustomButton(
                            props: .init(
                                text: props.acceptButtonText,
                                theme: props.theme.primaryButtonTheme
                            )
                        ) {
                            handle(
                                action: .save(
                                    purposeCodeConsent: true,
                                    vendors: consent.vendorConsents
                                        .filter(\.isAccepted)
                                        .map(\.id)
                                )
                            )
                            presentationMode.wrappedValue.dismiss()
                        }

                        CustomButton(
                            props: .init(
                                text: props.declineButtonText,
                                theme: props.theme.secondaryButtonTheme
                            )
                        ) {
                            handle(
                                action: .save(
                                    purposeCodeConsent: false,
                                    vendors: consent.vendorConsents
                                        .filter(\.isAccepted)
                                        .map(\.id)
                                )
                            )
                            presentationMode.wrappedValue.dismiss()
                        }

                        if let moreInfoText = props.moreInfoText,
                           props.moreInfoDestinationEnabled {
                            CustomButton(
                                props: .init(
                                    text: moreInfoText,
                                    theme: props.theme.thirdButtonTheme
                                )
                            ) {
                                handle(action: .moreInfo)
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
        .background(props.theme.backgroundColor)
        .fullScreenCover(item: $presentationItem) { item in
            item.content
        }
    }

    @ViewBuilder
    private func purposeView() -> some View {
        VStack(alignment: .leading, spacing: 20) {
            let purpose = props.purpose

            TitleDescriptionSection(
                props: .init(
                    bodyTitle: purpose.title,
                    bodyDescription: purpose.purposeDescription,
                    theme: props.theme.titleDescriptionSectionTheme
                )
            ) { action in
                switch action {
                case .openUrl(let url): handle(action: .openUrl(url))
                }
            }

            if let legalBasisDescription = purpose.legalBasisDescription {
                TitleDescriptionSection(
                    props: .init(
                        bodyTitle: purpose.legalBasisName,
                        bodyDescription: legalBasisDescription,
                        theme: props.theme.titleDescriptionSectionTheme
                    )
                ) { action in
                    switch action {
                    case .openUrl(let url): handle(action: .openUrl(url))
                    }
                }
            }

            if props.vendors.isEmpty == false {
                NavigationLink {
                    VendorsView(
                        props: Props.VendorList(
                            title: props.purpose.title,
                            description: props.purpose.purposeDescription,
                            theme: props.theme.vendorListTheme
                        ),
                        vendorConsents: $consent.vendorConsents
                    ) { action in
                        switch action {
                        case .close: handle(action: .close)
                        case .openUrl(let url): handle(action: .openUrl(url))
                        }
                    }
                } label: {
                    Text("Vendors")
                        .font(.system(size: 14, weight: .bold))
                    Image(systemName: "arrow.up.forward.app")
                }
                .foregroundColor(.black)
            }

            if props.purpose.categories.isEmpty == false {
                NavigationLink {
                    CategoriesView(
                        props: Props.CategoryList(
                            title: purpose.title,
                            description: purpose.purposeDescription,
                            theme: props.theme.categoryListTheme,
                            categories: purpose.categories
                        )
                    ) { action in
                        switch action {
                        case .openUrl(let url): handle(action: .openUrl(url))
                        }
                    }
                } label: {
                    Text("Categories")
                        .font(.system(size: 14, weight: .bold))
                    Image(systemName: "arrow.up.forward.app")
                }
                .foregroundColor(.black)
            }
        }
    }

    private func handle(action: Action) {
        presentationItem = actionHandler(action)
    }
}
