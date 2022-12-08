//
//  DataRightsView.swift
//  KetchSDK
//
//  Created by Anton Lyfar on 07.12.2022.
//

import SwiftUI

struct DataRightsView: View {
    enum Action {
        case close
        case openUrl(URL)
    }

    let props: Props.DataRightsView
    let actionHandler: (Action) -> Void
//    @ObservedObject private var keyboard = KeyboardResponder()
    @State private var keyboardHeight: CGFloat = 0
    private let showPublisher = NotificationCenter.Publisher.init(
        center: .default,
        name: UIResponder.keyboardWillShowNotification
    ).map { (notification) -> CGFloat in
        if let rect = notification.userInfo?["UIKeyboardFrameEndUserInfoKey"] as? CGRect {
            return rect.size.height
        } else {
            return 0
        }
    }

    private let hidePublisher = NotificationCenter.Publisher.init(
        center: .default,
        name: UIResponder.keyboardWillHideNotification
    ).map {_ -> CGFloat in 0}

    @State var selectedId: Int = 0
    @State var selectedOption: String?

    var body: some View {
        ScrollView(showsIndicators: true) {
            ScrollViewReader { proxy in
                VStack(spacing: 24) {
                    TitleDescriptionSection(
                        props: props.titleDescriptionSectionProps
                    ) { action in
                        switch action {
                        case .openUrl(let url): actionHandler(.openUrl(url))
                        }
                    }

                    VStack(spacing: 24) {
                        radioButtonsSelectorSection(title: "Name", value: $selectedOption)

                        textEditorSection(title: "Name", hint: nil, value: $requestDetails)
                            .onTapGesture {
                                selectedId = 1
                            }
                            .id(1)

                        textFieldSection(title: "Name", hint: nil, value: $requestDetails)
                            .onTapGesture {
                                selectedId = 2
                            }
                            .id(2)

                        countrySelectionSection(title: "Name", hint: nil, value: $requestDetails)
                    }
                }
                .padding(18)
                .onChange(of: selectedId) { newValue in
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        withAnimation(.easeInOut(duration: 0.15)) {
                            proxy.scrollTo(selectedId, anchor: .center)
                        }
                    }
                }


                
            }
        }
        .padding(.bottom, keyboardHeight)
        .background(props.theme.bodyBackgroundColor)
        .ignoresSafeArea()
        .onTapGesture {
            UIApplication.shared
                .sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }
        .onReceive(showPublisher.merge(with: hidePublisher)) { (height) in
            self.keyboardHeight = height
        }
    }

    @State private var selectedStrength = "Select state"
    let strengths = {
        var countries: [String] = []

        for code in NSLocale.isoCountryCodes  {
            let id = NSLocale.localeIdentifier(fromComponents: [NSLocale.Key.countryCode.rawValue: code])
            let name = NSLocale(localeIdentifier: "en_UK").displayName(forKey: NSLocale.Key.identifier, value: id) ?? "Country not found for code: \(code)"
            countries.append(name)
        }

        return countries.sorted()
    }()

    @State var requestDetails = String()

    @ViewBuilder
    private func radioButtonsSelectorSection(title: String?, value: Binding<String?>) -> some View {
        VStack {
            if let title = title {
                HStack {
                    Text(title)
                        .font(.system(size: 14, weight: .bold))
                    Spacer()
                }

                RadioButtonsGroup(
                    options: ["First", "Second", "Third"],
                    selected: value
                )
                .foregroundColor(props.theme.contentColor)
            }
        }
    }

    @ViewBuilder
    private func textFieldSection(title: String?, hint: String?, value: Binding<String>) -> some View {
        VStack {
            if let title = title {
                HStack {
                    Text(title)
                        .font(.system(size: 14, weight: .bold))
                    Spacer()
                }
            }

            TextField(hint ?? "", text: value)
                .font(.system(size: 14))
                .frame(height: 44)
                .padding(.horizontal, 10)
                .overlay(
                    RoundedRectangle(cornerRadius: 5)
                        .stroke(
                            props.theme.contentColor,
                            lineWidth: 1
                        )
                )
        }
    }

    @ViewBuilder
    private func textEditorSection(title: String?, hint: String?, value: Binding<String>) -> some View {
        VStack {
            if let title = title {
                HStack {
                    Text(title)
                        .font(.system(size: 14, weight: .bold))
                    Spacer()
                }
            }

            TextEditor(text: value)
                .font(.system(size: 14))
                .frame(minHeight:80)
                .padding(6)
                .overlay(
                    RoundedRectangle(cornerRadius: 5)
                        .stroke(
                            props.theme.contentColor,
                            lineWidth: 1
                        )
                )
        }
    }

    @ViewBuilder
    private func countrySelectionSection(title: String?, hint: String?, value: Binding<String>) -> some View {
        VStack {
            if let title = title {
                HStack {
                    Text(title)
                        .font(.system(size: 14, weight: .bold))
                    Spacer()
                }
            }

            Menu {
                Picker(
                    selection: $selectedStrength,
                    label: Text(selectedStrength),
                    content: {
                        ForEach(strengths, id: \.self) {
                            Text($0)
                        }
                    }
                )
                .pickerStyle(.automatic)
                .accentColor(.white)
            } label: {
                HStack {
                    Text(selectedStrength)
                        .font(.system(size: 14))
                        .foregroundColor(props.theme.contentColor)
                    Spacer()
                    Image(systemName: "chevron.down")
                        .foregroundColor(props.theme.contentColor)
                }
                .frame(height: 44)
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 16)
                .overlay(
                    RoundedRectangle(cornerRadius: 5)
                        .stroke(
                            props.theme.contentColor,
                            lineWidth: 1
                        )
                )
            }
        }
    }

    @ViewBuilder
    private func userForm() -> some View {
        VStack(spacing: 24) {
            textEditorSection(title: "Name", hint: nil, value: $requestDetails)
            textFieldSection(title: "Name", hint: nil, value: $requestDetails)
                .onTapGesture {

                }
            countrySelectionSection(title: "Name", hint: nil, value: $requestDetails)
        }
    }
}

extension Props {
    struct DataRightsView {
        let bodyTitle: String?
        let bodyDescription: String?
        let theme: Theme

        struct Theme {
            let bodyBackgroundColor: Color
            let contentColor: Color
            let linkColor: Color
        }
    }
}

struct DataRightsView_Previews: PreviewProvider {
    static var previews: some View {
        DataRightsView(
            props: Props.DataRightsView(
                bodyTitle: "Choose how we use your data",
                bodyDescription:
                """
                We collect and use data--including, where applicable,
                your personal data--for the purposes listed below.
                Please indicate whether or not that's ok with you by
                toggling the switches below.
                """,
                theme: Props.DataRightsView.Theme(
                    bodyBackgroundColor: .white,
                    contentColor: .black,
                    linkColor: .blue
                )
            )
        ) { _ in }
    }
}


//
//final class KeyboardResponder: ObservableObject {
//    private var notificationCenter: NotificationCenter
//    @Published private(set) var currentHeight: CGFloat = 0
//
//    init(center: NotificationCenter = .default) {
//        notificationCenter = center
//        notificationCenter.addObserver(self, selector: #selector(keyBoardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
//        notificationCenter.addObserver(self, selector: #selector(keyBoardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
//    }
//
//    deinit {
//        notificationCenter.removeObserver(self)
//    }
//
//    @objc func keyBoardWillShow(notification: Notification) {
//        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
//            currentHeight = keyboardSize.height
//        }
//    }
//
//    @objc func keyBoardWillHide(notification: Notification) {
//        currentHeight = 0
//    }
//}
