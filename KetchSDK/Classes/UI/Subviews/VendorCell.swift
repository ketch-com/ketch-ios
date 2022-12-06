//
//  VendorCell.swift
//  KetchSDK
//
//  Created by Anton Lyfar on 30.11.2022.
//

import SwiftUI


extension PurposesView.Props {
    struct Vendor: Hashable, Identifiable {
        let id: String
        let name: String
        let isAccepted: Bool
        let purposes: [VendorPurpose]?
        let specialPurposes: [VendorPurpose]?
        let features: [VendorPurpose]?
        let specialFeatures: [VendorPurpose]?
        let policyUrl: URL?

        struct VendorPurpose: Hashable, Identifiable {
            var id: String { name }

            let name: String
            let legalBasis: String?
        }
    }
}

struct VendorCell: View {
    typealias Vendor = PurposesView.Props.Vendor

    var isAccepted: Binding<Bool>
    let vendor: PurposesView.Props.Vendor
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
    private func vendorPurposeList(title: String, with purposes: [PurposesView.Props.Vendor.VendorPurpose]?) -> some View {
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
