//
//  CategoriesView.swift
//  KetchSDK
//
//  Created by Anton Lyfar on 06.12.2022.
//

import SwiftUI

struct CategoriesView: View {
    enum Action {
        case openUrl(URL)
    }

    let props: Props.CategoryList
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
                        Text("Data Category")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(props.theme.contentColor)

                        Spacer()
                    }
                    .padding(.horizontal)

                    ForEach(props.categories) { category in
                        CategoryCell(
                            name: category.name,
                            retentionPeriod: category.retentionPeriod,
                            externalTransfers: category.externalTransfers,
                            description: category.description
                        )
                    }
                }

            }
            .background(props.theme.bodyBackgroundColor)
        }
        .navigationTitle("Data Categories")
    }
}
