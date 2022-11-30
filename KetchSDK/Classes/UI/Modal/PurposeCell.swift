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
            HStack(alignment: .top) {
                Image(systemName: isExpanded ? "chevron.down" : "chevron.right")
                    .frame(width: 20, height: 20)
                    .padding(4)

                VStack(alignment: .leading, spacing: 20) {
                    header
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
                }
            }
            Divider()
        }
    }

    private var header: some View {
        HStack(spacing: 0) {
            VStack(alignment: .leading) {
                Text(purpose.title)
                    .font(.system(size: 12, weight: .bold))
                if let legalBasisName = purpose.legalBasisName {
                    Text(legalBasisName)
                        .font(.system(size: 11))
                }
            }

            Spacer()

            Toggle("Accept", isOn: consent)
                .labelsHidden()
                .disabled(purpose.required)
                .toggleStyle(SwitchToggleStyle(tint: .black))
                .onTapGesture { }
        }
        .padding(.vertical, 4)
    }
}
