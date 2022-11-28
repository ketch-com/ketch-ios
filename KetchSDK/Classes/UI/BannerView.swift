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
        let actionHandler: (Action) -> KetchUI.PresentationItem?

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
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(props.title)
                    .font(.system(size: props.theme.titleFontSize, weight: .heavy))
                    .foregroundColor(props.theme.contentColor)
                Spacer()
                Button(action: {
                    handle(action: .close)
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Image(systemName: "xmark")
                }
                .foregroundColor(props.theme.contentColor)
            }

            KetchUI.PresentationItem.descriptionText(with: props.text) { url in
                handle(action: .openUrl(url))
            }
            .font(.system(size: props.theme.textFontSize))
            .padding(.bottom, 12)
            .foregroundColor(props.theme.contentColor)
            .accentColor(props.theme.linkColor)

            if let primaryButton = props.primaryButton {
                button(props: primaryButton, cornerRadius: props.theme.borderRadius) {
                    self.handle(action: .primary)
                }
            }

            if let secondaryButton = props.secondaryButton {
                button(props: secondaryButton, cornerRadius: props.theme.borderRadius) {
                    self.handle(action: .secondary)
                }
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
    private func button(
        props: Props.Button,
        cornerRadius: Int,
        actionHandler: @escaping () -> Void
    ) -> some View {
        Button {
            actionHandler()
            presentationMode.wrappedValue.dismiss()
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

    private func handle(action: Props.Action) {
        presentationItem = props.actionHandler(action)
    }
}

struct BannerView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.gray
            BannerView(
                props: BannerView.Props(
                    title: "Your Privacy",
                    text: "Welcome! We’re glad you’re here and want you to know that we respect your privacy and your right to control how we collect, use, and share your personal data.\n\nGoogle site: http://google.com.  fjjjjjjjjj\nMy phone: +380671111111.\n\n[Trigger Modal](triggerModal)\n\n[Privacy Policy](privacyPolicy)\n[Terms & Conditions](termsOfService)\n\n[Custom Link](http://google.com)",
                    primaryButton: BannerView.Props.Button(
                        text: "I understand",
                        textColor: .white,
                        borderColor: .blue,
                        backgroundColor: .blue,
                        action: .primary
                    ),
                    secondaryButton: BannerView.Props.Button(
                        text: "Cancel",
                        textColor: .blue,
                        borderColor: .blue,
                        backgroundColor: .white,
                        action: .secondary
                    ),
                    theme: BannerView.Props.Theme(
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
