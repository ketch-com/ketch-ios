//
//  PurposesView.swift
//  KetchSDK
//

import SwiftUI

struct PurposesView<ContentView: View>: View {
    enum Action {
        case close
        case openUrl(URL)
    }

    let props: Props.PurposesList
    let localizedStrings: KetchSDK.Configuration.Translations?
    @Binding var purposeConsents: [UserConsents.PurposeConsent]
    @Binding var vendorConsents: [UserConsents.VendorConsent]
    @ViewBuilder let content: ContentView?
    let actionHandler: (Action) -> Void

    var body: some View {
        ScrollView(showsIndicators: true) {
            TitleDescriptionSection(
                props: props.titleDescriptionSectionProps
            ) { action in
                switch action {
                case .openUrl(let url): actionHandler(.openUrl(url))
                }
            }
            .padding(18)

            purposesView()

            content
        }
        .background(props.theme.bodyBackgroundColor)
    }

    @ViewBuilder
    private func purposesView() -> some View {
        VStack {
            HStack {
                if (props.consentTitle != nil && props.consentTitle != "") {
                    Text(props.consentTitle ?? (localizedStrings?.purposes ?? "Purposes"))
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(props.theme.contentColor)
                    
                    Spacer()
                }

                Button {
                    setAllPurposeConsents(false)
                } label: {
                    //Text("Reject All")
                    Text(localizedStrings?.rejectAll ?? "Reject All")
                        .frame(maxWidth: 105, minHeight: 28)
                        .padding(.horizontal)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.black)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .background(Color(UIColor.systemGray6).cornerRadius(5))
                
                if (props.purposeButtonsLookIdentical) {
                    Button {
                        setAllPurposeConsents(true)
                    } label: {
                        //Text("Accept All")
                        Text(localizedStrings?.acceptAll ?? "Accept All")
                            .frame(maxWidth: 110, minHeight: 28)
                            .padding(.horizontal)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.black)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .background(Color(UIColor.systemGray6).cornerRadius(5))
                } else {
                    Button {
                        setAllPurposeConsents(true)
                    } label: {
                        //Text("Accept All")
                        Text(localizedStrings?.acceptAll ?? "Accept All")
                            .frame(maxWidth: 110, minHeight: 28)
                            .padding(.horizontal)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.black)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .background(
                        RoundedRectangle(cornerRadius: 5, style: .continuous)
                            .stroke(Color.black, lineWidth: 1)
                    )
                }
            }
            .padding(.horizontal)

            ForEach($purposeConsents) { index, purposeConsent in
                let purpose = purposeConsent.wrappedValue.purpose

                if purpose.requiresDisplay {
                    PurposeCell(
                        consent: purposeConsent.consent,
                        purpose: purpose,
                        localizedStrings: localizedStrings,
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
        }
    }

    func setAllPurposeConsents(_ value: Bool) {
        purposeConsents.enumerated().forEach { (index, _) in
            if purposeConsents[index].isRequired { return }

            purposeConsents[index].consent = value
        }
    }
}
