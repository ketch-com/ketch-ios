//
//  RadioButtonsGroup.swift
//  KetchSDK
//
//  Created by Anton Lyfar on 08.12.2022.
//

import SwiftUI

protocol RightDescription {
    var name: String { get }
    var description: String { get }
}

struct RadioButtonsGroup<Option: Equatable & Hashable & RightDescription>: View {
    let options: [Option]
    @Binding var selected: Option?

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            ForEach(options, id: \.self) { option in
                RadioButtonField(
                    selectedId: $selected,
                    id: option,
                    title: option.name,
                    subTitle: option.description
                )
            }
        }
    }
}

struct RadioButtonField<ID: Equatable>: View {
    @Binding var selectedId: ID
    let id: ID
    let title: String
    let subTitle: String

    var body: some View {
        HStack(spacing: 10) {
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

            VStack(alignment: .leading) {
                Text(title)
                    .font(Font.system(size: 14, weight: .bold))
                Text(subTitle)
                    .font(Font.system(size: 14))
            }

            Spacer(minLength: 0)
        }
        .onTapGesture {
            selectedId = id
        }
    }
}



struct RadioButtonsGroup_Previews: PreviewProvider {
    static var previews: some View {
        Test_RadioButtonsGroup()
    }

    private struct Test_RadioButtonsGroup: View {
        @State var selected: Right?

        struct Right: Hashable, RightDescription {
            let name: String
            let description: String
        }

        var options = [
            Right(name: "First", description: "FirstSubtitle"),
            Right(name: "Second", description: "SecondSubtitle SecondSubtitle SecondSubtitle SecondSubtitle SecondSubtitle SecondSubtitle SecondSubtitle SecondSubtitle SecondSubtitle SecondSubtitle SecondSubtitle SecondSubtitle SecondSubtitle SecondSubtitle SecondSubtitle SecondSubtitle SecondSubtitle SecondSubtitle SecondSubtitle SecondSubtitle SecondSubtitle SecondSubtitle SecondSubtitle"),
            Right(name: "Third", description: "ThirdSubtitle")
        ]

        var body: some View {
            RadioButtonsGroup(
                options: options,
                selected: $selected
            )
        }
    }
}
