//
//  CategoriesView.swift
//  KetchSDK
//
//  Created by Anton Lyfar on 06.12.2022.
//

import SwiftUI

struct CategoriesView: View {
    struct Props {
        let title: String
        let description: String
        let theme: Theme
        let categories: [Category]

        struct Category: Hashable, Identifiable {
            var id: String { name }

            let name: String
            let retentionPeriod: String
            let externalTransfers: String
            let description: String
        }

        struct Theme {
            let textFontSize: CGFloat = 14
            let bodyBackgroundColor: Color
            let contentColor: Color
            let linkColor: Color
        }
    }

    enum Action {
        case openUrl(URL)
    }

    let props: Props
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
