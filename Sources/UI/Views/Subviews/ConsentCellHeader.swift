//
//  ConsentCellHeader.swift
//  KetchSDK
//
//  Created by Anton Lyfar on 30.11.2022.
//

import SwiftUI

struct ConsentCellHeader: View {
    var isExpanded: Bool
    var isRequired: Bool
    let title: String
    let subTitle: String?
    var isOn: Binding<Bool>

    var body: some View {
        HStack(spacing: 0) {
            Image(systemName: isExpanded ? "chevron.down" : "chevron.right")
                .frame(width: 20, height: 20)
                .padding(4)

            VStack(alignment: .leading) {
                Text(title)
                    .font(.system(size: 12, weight: .bold))
                if let subTitle = subTitle {
                    Text(subTitle)
                        .font(.system(size: 11))
                }
            }

            Spacer()

            Toggle("Accept", isOn: isOn)
                .labelsHidden()
                .disabled(isRequired)
                .toggleStyle(SwitchToggleStyle(tint: .black))
                .onTapGesture { }
        }
        .frame(minHeight: 30)
        .padding(.vertical, 4)
    }
}
