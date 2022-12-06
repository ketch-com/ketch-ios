//
//  PurposesView.swift
//  KetchSDK
//
//  Created by Anton Lyfar on 06.12.2022.
//

import SwiftUI

struct PurposesView: View {
    enum Action {
        case close
        case openUrl(URL)
    }

    let props: Props.PurposesList
    @Binding var purposeConsents: [PurposesView.PurposeConsent]
    @Binding var vendorConsents: [PurposesView.VendorConsent]
    let actionHandler: (Action) -> Void

    @Environment(\.presentationMode) private var presentationMode: Binding<PresentationMode>

    var body: some View {
        ScrollView(showsIndicators: true) {
            VStack(alignment: .leading, spacing: 16) {
                Text(props.bodyTitle)
                    .font(.system(size: 16, weight: .bold))

                DescriptionMarkupText(description: props.bodyDescription) { url in
                    actionHandler(.openUrl(url))
                }
                .font(.system(size: props.theme.textFontSize))
                .foregroundColor(props.theme.contentColor)
                .accentColor(props.theme.linkColor)
            }
            .padding(18)

            purposesView()
        }
        .background(props.theme.bodyBackgroundColor)
    }

    @ViewBuilder
    private func purposesView() -> some View {
        VStack {
            HStack {
                Text(props.consentTitle ?? "Purposes")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(props.theme.contentColor)

                Spacer()

                Button {
                    setAllPurposeConsents(false)
                } label: {
                    Text("Opt Out")
                        .padding(.horizontal)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.black)
                        .frame(height: 28)
                }
                .background(Color(UIColor.systemGray6).cornerRadius(5))

                Button {
                    setAllPurposeConsents(true)
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

            ForEach($purposeConsents) { index, purposeConsent in
                let purpose = purposeConsent.wrappedValue.purpose

                PurposeCell(
                    consent: purposeConsent.consent,
                    purpose: purpose,
                    vendorsDestination: props.vendors.isEmpty ? nil : {
                        VendorsView(
                            props: Props.VendorList(
                                title: purpose.title,
                                description: purpose.purposeDescription,
                                theme: props.theme.vendorListTheme
                            ),
                            vendorConsents: $vendorConsents
                        ) { action in
                            switch action {
                            case .close: actionHandler(.close)
                            case .openUrl(let url): actionHandler(.openUrl(url))
                            }
                        }
                    },
                    categoriesDestination: purpose.categories.isEmpty ? nil : {
                        CategoriesView(
                            props: Props.CategoryList(
                                title: purpose.title,
                                description: purpose.purposeDescription,
                                theme: props.theme.categoryListTheme,
                                categories: purpose.categories
                            )
                        ) { action in
                            switch action {
                            case .openUrl(let url): actionHandler(.openUrl(url))
                            }
                        }
                    }
                )
            }
        }
        .animation(.easeInOut(duration: 0.15))
    }

    func setAllPurposeConsents(_ value: Bool) {
        purposeConsents.enumerated().forEach { (index, _) in
            if purposeConsents[index].required { return }

            purposeConsents[index].consent = value
        }
    }
}
