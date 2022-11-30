//
//  PurposeCell.swift
//  KetchSDK
//
//  Created by Anton Lyfar on 30.11.2022.
//

import SwiftUI

struct PurposeCell<VendorsContent: View, CategoriesContent: View>: View {
    var consent: Binding<Bool>
    let purpose: ModalView.Props.Purpose
    let vendorsDestination: (() -> VendorsContent)?
    let categoriesDestination: (() -> CategoriesContent)?

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
                    title: purpose.title,
                    subTitle: purpose.legalBasisName,
                    isOn: consent
                )

                if isExpanded {
                    VStack(alignment: .leading, spacing: 20) {
                        Text("Purpose: ")
                            .font(.system(size: 14, weight: .bold))
                        + Text(purpose.purposeDescription)
                            .font(.system(size: 14))

                        if let legalBasisDescription = purpose.legalBasisDescription {
                            Text("Legal Basic: ")
                                .font(.system(size: 14, weight: .bold))
                            + Text(legalBasisDescription)
                                .font(.system(size: 14))
                        }

                        if let vendorsDestination = vendorsDestination {
                            NavigationLink(destination: vendorsDestination) {
                                Text("Vendors")
                                    .font(.system(size: 14, weight: .bold))
                                Image(systemName: "arrow.up.forward.app")
                            }
                            .foregroundColor(.black)
                        }

                        if let categoriesDestination = categoriesDestination {
                            NavigationLink(destination: categoriesDestination) {
                                Text("Categories")
                                    .font(.system(size: 14, weight: .bold))
                                Image(systemName: "arrow.up.forward.app")
                            }
                            .foregroundColor(.black)
                        }
                    }
                    .padding(.leading, 30)
                }
            }
            Divider()
        }
    }
}
