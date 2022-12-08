//
//  RadioButtonsGroup.swift
//  KetchSDK
//
//  Created by Anton Lyfar on 08.12.2022.
//

import SwiftUI

struct RadioButtonsGroup<Option: Equatable & Hashable & CustomStringConvertible>: View {
    let options: [Option]
    @Binding var selected: Option?

    var body: some View {
        VStack(spacing: 20) {
            ForEach(options, id: \.self) { option in
                RadioButtonField(
                    selectedId: $selected,
                    id: option,
                    title: option.description
                )
            }
        }
    }
}

struct RadioButtonField<ID: Equatable>: View {
    @Binding var selectedId: ID
    let id: ID
    let title: String

    var body: some View {
        Button {
            selectedId = id
        } label: {
            HStack(alignment: .center, spacing: 10) {
                ZStack {
                    Image(systemName: "circle")
                        .renderingMode(.original)
                        .resizable()
                        .aspectRatio(contentMode: .fit)

                    if selectedId == id {
                        Image(systemName: "circle.fill")
                            .renderingMode(.original)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 10, height: 10)
                    }
                }
                .frame(width: 20, height: 20)

                Text(title)
                    .font(Font.system(size: 14))

                Spacer()
            }
        }
    }
}



struct RadioButtonsGroup_Previews: PreviewProvider {
    static var previews: some View {
        Test_RadioButtonsGroup()
    }

    private struct Test_RadioButtonsGroup: View {
        @State var selected: String?
        var options = ["First", "Second", "Third"]

        var body: some View {
            RadioButtonsGroup(
                options: options,
                selected: $selected
            )
        }
    }
}
