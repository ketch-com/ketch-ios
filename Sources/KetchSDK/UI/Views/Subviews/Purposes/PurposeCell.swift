//
//  PurposeCell.swift
//  KetchSDK
//

import SwiftUI

struct PurposeCell<VendorsContent: View, CategoriesContent: View>: View {
    var consent: Binding<Bool>
    let purpose: Props.Purpose
    let localizedStrings: KetchSDK.LocalizedStrings
    let vendorsDestination: (() -> VendorsContent)?
    let categoriesDestination: (() -> CategoriesContent)?

    @State private var isExpanded: Bool = false

    var body: some View {
        content
            .padding(.horizontal)
            .frame(maxWidth: .infinity)
            .onTapGesture {
                withAnimation(.easeInOut(duration: 0.15)) {
                    isExpanded.toggle()
                }
            }
            .background(
                Color.white
                    .onTapGesture {
                        withAnimation(.easeInOut(duration: 0.15)) {
                            isExpanded.toggle()
                        }
                    }
            )
    }

    private var content: some View {
        VStack {
            VStack(alignment: .leading, spacing: 20) {
                ConsentCellHeader(
                    isExpanded: isExpanded,
                    isRequired: purpose.required,
                    title: purpose.title,
                    subTitle: purpose.legalBasisName,
                    isOn: consent
                )

                if isExpanded {
                    VStack(alignment: .leading, spacing: 20) {
                        Text(localizedStrings.purpose + ": ")
                            .font(.system(size: 14, weight: .bold))
                        + Text(purpose.purposeDescription)
                            .font(.system(size: 14))

                        if let legalBasisDescription = purpose.legalBasisDescription {
                            Text(localizedStrings.legalBasis + ": ")
                                .font(.system(size: 14, weight: .bold))
                            + Text(legalBasisDescription)
                                .font(.system(size: 14))
                        }

                        if let vendorsDestination = vendorsDestination {
                            NavigationLink(destination: vendorsDestination) {
                                Text(localizedStrings.vendor)
                                    .font(.system(size: 14, weight: .bold))
                                Image(systemName: "arrow.up.forward.app")
                            }
                            .foregroundColor(.black)
                        }

                        if let categoriesDestination = categoriesDestination {
                            NavigationLink(destination: categoriesDestination) {
                                Text(localizedStrings.dataCategories)
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