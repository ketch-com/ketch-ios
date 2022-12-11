//
//  JitView.swift
//  KetchSDK
//
//  Created by Anton Lyfar on 10.11.2022.
//

import SwiftUI

struct JitView: View {
    enum Action {
        case close
        case openUrl(URL)
    }

    let props: Props.Jit
    let actionHandler: (Action) -> KetchUI.PresentationItem?

    @State var presentationItem: KetchUI.PresentationItem?
    @ObservedObject private var consentsList = UserConsentsList()

    @Environment(\.openURL) var openURL
    @Environment(\.presentationMode) private var presentationMode: Binding<PresentationMode>

    init(props: Props.Jit, actionHandler: @escaping (Action) -> KetchUI.PresentationItem?) {
        self.props = props
        self.actionHandler = actionHandler
//        consentsList = props.generateConsentsList()
    }

    var body: some View {
        ZStack {
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
                            TitleDescriptionSection(
                                props: props.titleDescriptionSectionProps
                            ) { action in
                                switch action {
                                case .openUrl(let url): handle(action: .openUrl(url))
                                }
                            }
                            .padding(18)

                            purposeView()
                        }
                        .background(props.theme.backgroundColor)

                        VStack(spacing: 24) {
                            CustomButton(
                                props: .init(
                                    text: props.acceptButtonText,
                                    theme: props.theme.primaryButtonTheme
                                )
                            ) {

                                presentationMode.wrappedValue.dismiss()
                            }

                            CustomButton(
                                props: .init(
                                    text: props.declineButtonText,
                                    theme: props.theme.primaryButtonTheme
                                )
                            ) {

                                presentationMode.wrappedValue.dismiss()
                            }

                            if let moreInfoText = props.moreInfoText,
                               let moreInfoDestination = props.moreInfoDestination {
                                CustomButton(
                                    props: .init(
                                        text: moreInfoText,
                                        theme: props.theme.secondaryButtonTheme
                                    )
                                ) {
                                    //destination
                                    moreInfoDestination
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

    @ViewBuilder
    private func purposeView() -> some View {
        Spacer()

//        if props.vendors.isEmpty == false {
//            NavigationLink {
//                VendorsView(
//                    props: Props.VendorList(
//                        title: purpose.title,
//                        description: purpose.purposeDescription,
//                        theme: props.theme.vendorListTheme
//                    ),
//                    vendorConsents: $vendorConsents
//                ) { action in
//                    switch action {
//                    case .close: actionHandler(.close)
//                    case .openUrl(let url): actionHandler(.openUrl(url))
//                    }
//                }
//            } label: {
//                Text("Vendors")
//                    .font(.system(size: 14, weight: .bold))
//                Image(systemName: "arrow.up.forward.app")
//            }
//            .foregroundColor(.black)
//        }
//
//        if let purpose = purposeConsent.wrappedValue.first.purpose {
//
//        }
//
//
//        if props.purpose.categories.isEmpty == false {
//            NavigationLink {
//                CategoriesView(
//                    props: Props.CategoryList(
//                        title: purpose.title,
//                        description: purpose.purposeDescription,
//                        theme: props.theme.categoryListTheme,
//                        categories: purpose.categories
//                    )
//                ) { action in
//                    switch action {
//                    case .openUrl(let url): actionHandler(.openUrl(url))
//                    }
//                }
//            } label: {
//                Text("Categories")
//                    .font(.system(size: 14, weight: .bold))
//                Image(systemName: "arrow.up.forward.app")
//            }
//            .foregroundColor(.black)
//        }
    }

    private func handle(action: Action) {
        presentationItem = actionHandler(action)
    }
}
