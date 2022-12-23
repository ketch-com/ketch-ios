//
//  VendorsView.swift
//  KetchSDK
//

import SwiftUI

struct VendorsView: View {
    enum Action {
        case close
        case openUrl(URL)
    }

    let props: Props.VendorList

    @Binding var vendorConsents: [UserConsents.VendorConsent]

    let actionHandler: (Action) -> Void

    var body: some View {
        VStack {
            ScrollView(showsIndicators: true) {
                TitleDescriptionSection(
                    props: props.titleDescriptionSectionProps
                ) { action in
                    switch action {
                    case .openUrl(let url): actionHandler(.openUrl(url))
                    }
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
    }

    func setAllVendorIsAccept(_ value: Bool) {
        vendorConsents.enumerated().forEach { (index, _) in
            vendorConsents[index].isAccepted = value
        }
    }
}
