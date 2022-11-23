//
//  ModalView.swift
//  KetchSDK
//
//  Created by Anton Lyfar on 10.11.2022.
//

import SwiftUI

struct ModalView: View {
    struct Props {
        let title: String
        let bodyTitle: String
        let bodyDescription: String
        let purposes: [Purpose]
        let vendors: [Vendor]

        let primaryButton: Button?

        let theme: Theme
        let actionHandler: (Action) -> KetchUI.PresentationItem?

        struct Purpose {

        }

        struct Vendor {

        }

        struct Button {
            let fontSize: CGFloat = 14
            let height: CGFloat = 44
            let borderWidth: CGFloat = 1

            let text: String
            let textColor: Color
            let borderColor: Color
            let backgroundColor: Color
            let action: Action
        }

        struct Theme {
            let titleFontSize: CGFloat = 20
            let textFontSize: CGFloat = 14

            let contentColor: Color
            let backgroundColor: Color
            let linkColor: Color
            let borderRadius: Int
        }

        enum Action {
            case primary
            case secondary
            case close
            case openUrl(URL)
        }
    }

    let props: Props

    @State var presentationItem: KetchUI.PresentationItem?
    @Environment(\.openURL) var openURL
    @Environment(\.presentationMode) private var presentationMode: Binding<PresentationMode>

    var body: some View {
        ZStack {
            VStack(alignment: .leading, spacing: 0) {
                    HStack {
                        Text(props.title)
                            .font(.system(size: props.theme.titleFontSize, weight: .heavy))
                            .foregroundColor(props.theme.contentColor)
                        Spacer()
                        Button(action: {
                            handle(action: .close)
                            presentationMode.wrappedValue.dismiss()
                        }) {
                            Text("X")
                        }
                        .foregroundColor(props.theme.contentColor)
                    }
                    .padding(.horizontal, 18)
                    .padding(.vertical, 20)
                    .background(Color(.systemGray6))

                VStack(alignment: .leading, spacing: 16) {
                    Text(props.bodyTitle)
                        .font(.system(size: 16, weight: .bold))

                    KetchUI.PresentationItem.descriptionText(with: props.bodyDescription)
                    { url in
                        handle(action: .openUrl(url))
                    }
                        .font(.system(size: props.theme.textFontSize))
                        .padding(.bottom, 12)
                        .foregroundColor(props.theme.contentColor)
                        .accentColor(props.theme.linkColor)

                    ScrollView(showsIndicators: true) {

                    }
                }
                .padding(18)

                VStack(spacing: 24) {
                    Button(action: { presentationMode.wrappedValue.dismiss() }) {
                        Text("Close")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(height: 44)
                            .frame(maxWidth: .infinity)
                    }
                    .background(Color.blue.cornerRadius(5))

                    HStack {
                        Text("Powered by")
                        Spacer()
                    }
                }
                .padding(24)
                .background(Color(.systemGray6))
            }
        }
        
    }

    private func handle(action: Props.Action) {
        presentationItem = props.actionHandler(action)
    }
}

struct ModalView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.gray
            ModalView(
                props: ModalView.Props(
                    title: "Privacy Center",
                    bodyTitle: "About Your Privacy",
                    bodyDescription:
                        """
                        Axonic, Inc. determines the use of personal data collected on our media properties and across \
                        the internet. We may collect data that you submit to us directly or data that we collect \
                        automatically including from cookies (such as device information or IP address).
                        """
                        ,

                    purposes: [],
                    vendors: [],

                    primaryButton: ModalView.Props.Button(
                        text: "I understand",
                        textColor: .white,
                        borderColor: .blue,
                        backgroundColor: .blue,
                        action: .primary
                    ),

                    theme: ModalView.Props.Theme(
                        contentColor: .black,
                        backgroundColor: .white,
                        linkColor: .red,
                        borderRadius: 5
                    ),
                    actionHandler: { action in
                        nil
                    }
                )
            )
        }
    }
}
