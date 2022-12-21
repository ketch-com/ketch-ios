//
//  CategoryCell.swift
//  KetchSDK
//

import SwiftUI

struct CategoryCell: View {
    let name: String
    let retentionPeriod: String
    let externalTransfers: String
    let description: String

    @State private var isExpanded: Bool = false

    var body: some View {
        VStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 0) {
                header(title: name)
                .frame(minHeight: 30)
                .padding(10)

                if isExpanded {
                    VStack(alignment: .leading, spacing: 3) {
                        dataRow(title: "Retention Period", value: retentionPeriod)
                        dataRow(title: "External Transfer", value: externalTransfers)
                        dataRow(title: "Description", value: description)
                    }
                    .padding(.vertical, 20)
                    .background(Color(UIColor.systemGray6))
                }
            }
            .onTapGesture {
                isExpanded.toggle()
            }

            Divider()
        }
    }

    @ViewBuilder
    private func header(title: String) -> some View {
        HStack(spacing: 10) {
            Image(systemName: isExpanded ? "chevron.down" : "chevron.right")
                .frame(width: 20, height: 20)
                .padding(4)

            VStack(alignment: .leading) {
                Text(name)
                    .font(.system(size: 16, weight: .bold))
            }

            Spacer()
        }
    }

    @ViewBuilder
    private func dataRow(title: String, value: String) -> some View {
        HStack(alignment: .top, spacing: 10) {
            HStack {
                Text(title).font(.system(size: 12, weight: .regular))

                Spacer()
            }

            HStack {
                Text(value).font(.system(size: 12, weight: .regular))

                Spacer()
            }
        }
        .padding(.horizontal, 32)
    }
}
