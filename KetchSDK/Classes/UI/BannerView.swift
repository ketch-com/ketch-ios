//
//  BannerView.swift
//  KetchSDK
//
//  Created by Anton Lyfar on 10.11.2022.
//

import SwiftUI

struct BannerView: View {
    struct Props {
        let title: String
        let text: String
        let primaryButton: Button?
        let secondaryButton: Button?
        let theme: Theme
        let cancelAction: () -> Void

        struct Button {
            let fontSize: CGFloat = 14
            let height: CGFloat = 44
            let borderWidth: CGFloat = 1

            let text: String
            let textColor: Color
            let borderColor: Color
            let backgroundColor: Color
            let actionHandler: () -> Void
        }

        struct Theme {
            let titleFontSize: CGFloat = 20
            let textFontSize: CGFloat = 14

            let contentColor: Color
            let backgroundColor: Color
            let linkColor: Color
            let borderRadius: Int
        }
    }

    let props: Props

    @State var presentationItem: KetchUI.PresentationItem?
    @Environment(\.presentationMode) private var presentationMode: Binding<PresentationMode>

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(props.title)
                    .font(.system(size: props.theme.titleFontSize, weight: .heavy))
                    .foregroundColor(props.theme.contentColor)
                Spacer()
                Button(action: { presentationMode.wrappedValue.dismiss() }) {
                    Text("X")
                }
                .foregroundColor(props.theme.contentColor)
            }
            
            Text(props.text)
                .font(.system(size: props.theme.textFontSize))
                .padding(.bottom, 12)
                .foregroundColor(props.theme.contentColor)

            if let primaryButton = props.primaryButton {
                button(props: primaryButton, cornerRadius: props.theme.borderRadius)
            }

            if let secondaryButton = props.secondaryButton {
                button(props: secondaryButton, cornerRadius: props.theme.borderRadius)
            }
            
            HStack {
                Text("Powered by")
                Spacer()
            }
        }
        .padding(24)
        .background(props.theme.backgroundColor)
        .fullScreenCover(item: $presentationItem) { item in
            item.content
        }
    }

    @ViewBuilder
    private func button(props: Props.Button, cornerRadius: Int) -> some View {
        Button {
            presentationItem = .init(itemType: .modal) // presentationMode.wrappedValue.dismiss()
            props.actionHandler()
        } label: {
            Text(props.text)
                .font(.system(size: props.fontSize, weight: .semibold))
                .foregroundColor(props.textColor)
                .frame(height: props.height)
                .frame(maxWidth: .infinity)
                .overlay(
                    RoundedRectangle(cornerRadius: CGFloat(cornerRadius))
                        .stroke(
                            props.borderColor,
                            lineWidth: props.borderWidth
                        )
                )
        }
        .background(
            props.backgroundColor
                .cornerRadius(CGFloat(cornerRadius))
        )
    }
}

struct BannerView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.gray
            BannerView(props: BannerView.Props(
                title: "Your Privacy",
                text:
                    """
                    We and our partners are using technologies like Cookies or Targeting and process personal \
                    data like IP-address or browser information in order to personalize the advertisement that \
                    you see. You can always change/withdraw your consent. Our Privacy Policy.
                    """,
                primaryButton: BannerView.Props.Button(
                    text: "I understand",
                    textColor: .white,
                    borderColor: .blue,
                    backgroundColor: .blue,
                    actionHandler: {}
                ),
                secondaryButton: BannerView.Props.Button(
                    text: "Cancel",
                    textColor: .blue,
                    borderColor: .blue,
                    backgroundColor: .white,
                    actionHandler: {}
                ),
                theme: BannerView.Props.Theme(
                    contentColor: .black,
                    backgroundColor: .white,
                    linkColor: .red,
                    borderRadius: 5
                ),
                cancelAction: {})
            )
        }
    }
}
