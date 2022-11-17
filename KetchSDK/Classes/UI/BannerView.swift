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
        let openUrlAction: (URL) -> Void

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
    @Environment(\.openURL) private var openURL

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

            descriptionText(with: props.text)

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

    @ViewBuilder
    private func descriptionText(with description: String) -> some View {
        if #available(iOS 15.0, *) {
            formattedText(with: description)
                .environment(\.openURL, OpenURLAction { url in
                    props.openUrlAction(url)
                    return .handled
                })
        } else {
            formattedText(with: description)
                .onOpenURL(perform: props.openUrlAction)
        }
    }

    @ViewBuilder
    private func formattedText(with description: String) -> some View {
        props.text.markupFragments().convertToLinks().reduce(Text("")) { result, fragment in
            let text = Text(LocalizedStringKey(String(fragment.substring)))
            switch fragment.type {
            case .markupLink: return result + text.underline()
            default: return result + text
            }
        }
        .font(.system(size: props.theme.textFontSize))
        .padding(.bottom, 12)
        .foregroundColor(props.theme.contentColor)
        .accentColor(props.theme.linkColor)
    }
}

extension String {
    func markupFragments() -> [MarkupFragment] {
        self[self.startIndex..<self.endIndex]
            .markupFragments(type: .markupLink)
            .markupFragments(type: .url)
            .markupFragments(type: .phone)
    }
}

extension Array where Element == MarkupFragment {
    func markupFragments(type: MarkupFragmentType) -> [MarkupFragment] {
        reduce(into: []) { result, fragment in
            if case .text = fragment.type {
                result.append(contentsOf: fragment.substring.markupFragments(type: type))
            } else {
                result.append(fragment)
            }
        }
    }

    func convertToLinks() -> [MarkupFragment] {
        map { fragment in
            switch fragment.type {
            case .url:
                let url = fragment.substring

                return MarkupFragment(type: .markupLink, substring: Substring("[\(url)](\(url))"))

            case .phone:
                let phone = fragment.substring

                return MarkupFragment(type: .markupLink, substring: Substring("[\(phone)](tel:\(phone))"))

            default: return fragment
            }
        }
    }
}

extension Substring {
    func markupFragments(type: MarkupFragmentType) -> [MarkupFragment] {
        guard let regex = type.regex else { return [MarkupFragment(type: .text, substring: self)] }

        var results = [MarkupFragment]()
        var lastIndex = startIndex

        regex.enumerateMatches(
            in: String(self),
            range: NSMakeRange(0, utf16.count)
        ) { result, flags, stop in
            if let result = result, let inputRange = Range(result.range, in: self) {
                if inputRange.lowerBound > lastIndex {
                    let substring = self[lastIndex..<inputRange.lowerBound]
                    results.append(MarkupFragment(type: .text, substring: substring))
                }

                results.append(MarkupFragment(type: type, substring: self[inputRange]))
                lastIndex = inputRange.upperBound
            }
        }

        if endIndex > lastIndex {
            let substring = self[lastIndex..<endIndex]
            results.append(MarkupFragment(type: .text, substring: substring))
        }

        return results
    }
}

struct MarkupFragment {
    let type: MarkupFragmentType
    let substring: Substring
}

enum MarkupFragmentType {
    case text
    case url
    case phone
    case markupLink

    var regex: NSRegularExpression? {
        switch self {
        case .text: return nil
        case .url: return try? NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
        case .phone: return try? NSDataDetector(types: NSTextCheckingResult.CheckingType.phoneNumber.rawValue)
        case .markupLink: return try? NSRegularExpression(pattern: "\\[(.*?)\\)", options: [])
        }
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
                    cancelAction: {},
                    openUrlAction: { _ in }
                )
            )
        }
    }
}
