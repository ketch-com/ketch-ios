//
//  VendorsView.swift
//  KetchSDK
//
//  Created by Anton Lyfar on 06.12.2022.
//

import SwiftUI

struct VendorsView: View {
    struct Props {
        let title: String
        let description: String
        let theme: Theme

        struct Theme {
            let textFontSize: CGFloat = 14
            let bodyBackgroundColor: Color
            let contentColor: Color
            let linkColor: Color
        }
    }

    enum Action {
        case close
        case openUrl(URL)
    }

    let props: Props

    @Binding var vendorConsents: [PurposesView.VendorConsent]

    let actionHandler: (Action) -> Void

    var body: some View {
        VStack {
            ScrollView(showsIndicators: true) {
                VStack(alignment: .leading, spacing: 16) {
                    Text(props.title)
                        .font(.system(size: 16, weight: .bold))

                    KetchUI.PresentationItem.descriptionText(with: props.description) { url in
                        actionHandler(.openUrl(url))
                    }
                    .font(.system(size: props.theme.textFontSize))
                    .foregroundColor(props.theme.contentColor)
                    .accentColor(props.theme.linkColor)
                }
                .padding(18)

                VStack {
                    HStack {
                        Spacer()

                        Button {
                            setAllVendorIsAccept(false)
                        } label: {
                            Text("Opt Out")
                                .padding(.horizontal)
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.black)
                                .frame(height: 28)
                        }
                        .background(Color(UIColor.systemGray6).cornerRadius(5))

                        Button {
                            setAllVendorIsAccept(true)
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

                    ForEach($vendorConsents) { index, vendorConsent in
                        let vendor = vendorConsent.wrappedValue.vendor

                        VendorCell(isAccepted: vendorConsent.isAccepted, vendor: vendor) { url in
                            actionHandler(.openUrl(url))
                        }
                    }
                }

            }
            .background(props.theme.bodyBackgroundColor)
        }
        .navigationTitle("Vendors")
        .animation(.easeInOut(duration: 0.15))
    }

    func setAllVendorIsAccept(_ value: Bool) {
        vendorConsents.enumerated().forEach { (index, _) in
            vendorConsents[index].isAccepted = value
        }
    }
}
