//
//  BannerView.swift
//  KetchSDK
//
//  Created by Anton Lyfar on 10.11.2022.
//

import SwiftUI

struct BannerView: View {
    enum Action {
        case primary
        case secondary
        case close
        case openUrl(URL)
    }

    let props: Props.Banner
    let actionHandler: (Action) -> KetchUI.PresentationItem?

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

            TitleDescriptionSection(
                props: props.titleDescriptionSectionProps
            ) { action in
                switch action {
                case .openUrl(let url): handle(action: .openUrl(url))
                }
            }
            .padding(.bottom, 12)


            if let primaryButton = props.primaryButton {
                CustomButton(props: primaryButton) {
                    self.handle(action: .primary)
                    presentationMode.wrappedValue.dismiss()
                }
            }

            if let secondaryButton = props.secondaryButton {
                CustomButton(props: secondaryButton) {
                    self.handle(action: .secondary)
                    presentationMode.wrappedValue.dismiss()
                }
            }
            
            HStack {
                LogoSection()
                    .foregroundColor(props.theme.contentColor)
                Spacer()
            }
        }
        .padding(24)
        .background(props.theme.backgroundColor)
        .fullScreenCover(item: $presentationItem) { item in
            item.content
        }
    }

    private func handle(action: Action) {
        presentationItem = actionHandler(action)
    }
}

//struct BannerView_Previews: PreviewProvider {
//    static var previews: some View {
//        ZStack {
//            Color.gray
//            BannerView(
//                props: BannerView.Props(
//                    title: "Your Privacy",
//                    text: "Welcome! We’re glad you’re here and want you to know that we respect your privacy and your right to control how we collect, use, and share your personal data.\n\nGoogle site: http://google.com.  fjjjjjjjjj\nMy phone: +380671111111.\n\n[Trigger Modal](triggerModal)\n\n[Privacy Policy](privacyPolicy)\n[Terms & Conditions](termsOfService)\n\n[Custom Link](http://google.com)",
//                    primaryButton: BannerView.Props.Button(
//                        text: "I understand",
//                        textColor: .white,
//                        borderColor: .blue,
//                        backgroundColor: .blue,
//                        action: .primary
//                    ),
//                    secondaryButton: BannerView.Props.Button(
//                        text: "Cancel",
//                        textColor: .blue,
//                        borderColor: .blue,
//                        backgroundColor: .white,
//                        action: .secondary
//                    ),
//                    theme: BannerView.Props.Theme(
//                        contentColor: .black,
//                        backgroundColor: .white,
//                        linkColor: .red,
//                        borderRadius: 5
//                    ),
//                    actionHandler: { action in
//                        nil
//                    }
//                )
//            )
//        }
//    }
//}
