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
                VStack(alignment: .leading, spacing: 16) {
                    Text(props.title)
                        .font(.system(size: 16, weight: .bold))

                    DescriptionMarkupText(description: props.description) { url in
                        actionHandler(.openUrl(url))
                    }
                    .font(.system(size: props.theme.textFontSize))
                    .foregroundColor(props.theme.contentColor)
                    .accentColor(props.theme.linkColor)
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
        .animation(.easeInOut(duration: 0.15))
    }
}
