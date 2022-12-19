//
//  VendorCell.swift
//  KetchSDK
//

import SwiftUI

struct VendorCell: View {
    var isAccepted: Binding<Bool>
    let vendor: Props.Vendor
    let actionHandler: (URL) -> Void

    @State private var isExpanded: Bool = false

    var body: some View {
        content
            .padding(.horizontal)
            .frame(maxWidth: .infinity)
            .onTapGesture { isExpanded.toggle() }
            .background(
                Color.white
                    .onTapGesture { isExpanded.toggle() }
            )
    }

    private var content: some View {
        VStack {
            VStack(alignment: .leading, spacing: 20) {
                ConsentCellHeader(
                    isExpanded: isExpanded,
                    isRequired: false,
                    title: vendor.name,
                    subTitle: nil,
                    isOn: isAccepted
                )

                if isExpanded {
                    VStack(alignment: .leading, spacing: 20) {
                        vendorPurposeList(title: "Purposes", with: vendor.purposes)
                        vendorPurposeList(title: "Special Purposes", with: vendor.specialPurposes)
                        vendorPurposeList(title: "Features", with: vendor.features)
                        vendorPurposeList(title: "Special Features", with: vendor.specialFeatures)

                        if let policyUrl = vendor.policyUrl {
                            Button {
                                actionHandler(policyUrl)
                            } label: {
                                Text("Privacy Policy")
                                    .padding(.horizontal)
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(.black)
                                    .frame(height: 40)
                            }
                            .background(Color(UIColor.systemGray6).cornerRadius(5))
                        }
                    }
                    .padding(.leading, 30)
                }
            }
            Divider()
        }
    }

    @ViewBuilder
    private func vendorPurposeList(title: String, with purposes: [Props.VendorPurpose]?) -> some View {
        if let purposes = purposes, purposes.isEmpty == false {
            VStack(alignment: .leading) {
                Text(title)
                    .font(.system(size: 14, weight: .bold))
                ForEach(purposes) { purpose in
                    if let legalBasis = purpose.legalBasis {
                        Text("- " + purpose.name)
                            .font(.system(size: 14, weight: .bold))
                        + Text(" (Legal Basis: \(legalBasis))")
                            .font(.system(size: 14))
                    } else {
                        Text(purpose.name)
                            .font(.system(size: 14, weight: .bold))
                    }
                }
            }
        }
    }
}
