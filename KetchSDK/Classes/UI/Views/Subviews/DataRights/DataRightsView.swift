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
    @Environment(\.presentationMode) private var presentationMode: Binding<PresentationMode>

    @ObservedObject private var keyboard = KeyboardResponder()

    private enum ViewState {
        case userDataForm
        case submitted
    }

    @State private var viewState: ViewState = .userDataForm

    @State private var selectedId: Int = 0
    @State private var selectedRight: Props.DataRightsView.Right?
    @State private var requestDetails = String()
    @State private var firstName = String()
    @State private var lastName = String()
    @State private var email = String()
    @State private var phone = String()
    @State private var postalCode = String()
    @State private var addressLine1 = String()
    @State private var addressLine2 = String()
    @State private var selectedCountryCode: String?


    var body: some View {
        switch viewState {
        case .userDataForm: userDataForm
        case .submitted: submittedView
        }
    }

    @ViewBuilder
    var userDataForm: some View {
        ScrollView(showsIndicators: true) {
            ScrollViewReader { proxy in
                VStack(spacing: 24) {
                    VStack(spacing: 24) {
                        TitleDescriptionSection(
                            props: props.titleDescriptionSectionProps
                        ) { action in
                            switch action {
                            case .openUrl(let url): actionHandler(.openUrl(url))
                            }
                        }

                        radioButtonsSelectorSection(title: "Request", value: $selectedRight)
                    }

                    VStack(alignment: .leading, spacing: 24) {
                        TextEditorSection(title: "Request details", accentColor: props.theme.contentColor, validations: [.notEmpty], value: $requestDetails)
                            .onTapGesture {
                                selectedId = 1
                            }
                            .id(1)
                            .padding(.bottom, 24)

                        Text("Personal Details")
                            .font(.system(size: props.theme.titleFontSize, weight: .bold))
                            .foregroundColor(props.theme.contentColor)

                        TextFieldSection(title: "First Name", hint: nil, accentColor: props.theme.contentColor, validations: [.notEmpty], value: $firstName)
                            .onTapGesture { selectedId = 2 }
                            .id(2)

                        TextFieldSection(title: "Last Name", hint: nil, accentColor: props.theme.contentColor, validations: [.notEmpty], value: $lastName)
                            .onTapGesture { selectedId = 3 }
                            .id(3)

                        TextFieldSection(title: "Email", hint: nil, accentColor: props.theme.contentColor, validations: [.notEmpty, .email], value: $email)
                            .onTapGesture { selectedId = 4 }
                            .id(4)

                        TextFieldSection(title: "Phone", hint: nil, accentColor: props.theme.contentColor, value: $phone)
                            .onTapGesture { selectedId = 5 }
                            .id(5)

                        CountrySelectionSection(title: "Country", contentColor: props.theme.contentColor, value: $selectedCountryCode)

                        TextFieldSection(title: "Postal Code", hint: nil, accentColor: props.theme.contentColor, value: $postalCode)
                            .onTapGesture { selectedId = 6 }
                            .id(6)

                        TextFieldSection(title: "Address Line 1", hint: nil, accentColor: props.theme.contentColor, value: $addressLine1)
                            .onTapGesture { selectedId = 7 }
                            .id(7)

                        TextFieldSection(title: "Address Line 2", hint: nil, accentColor: props.theme.contentColor, value: $addressLine2)
                            .onTapGesture { selectedId = 8 }
                            .id(8)
                    }
                    .onChange(of: selectedId) { newValue in
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                            withAnimation(.easeInOut(duration: 0.15)) {
                                proxy.scrollTo(selectedId, anchor: .center)
                            }
                        }
                    }
                    .padding(.bottom, 18)

                    VStack(spacing: 24) {
                        bottomButtonsSection()
                    }
                }
                .padding(18)
                .padding(.bottom, 40)
            }
        }
        .padding(.bottom, keyboard.currentHeight)
        .background(props.theme.bodyBackgroundColor)
        .ignoresSafeArea()
        .onTapGesture(perform: hideKeyboard)
    }

    @ViewBuilder
    var submittedView: some View {
        SubmittedDataRightsView(
            props: props.submittedViewProps
        ) { action in
            switch action {
            case .close: actionHandler(.close)
            case .openUrl(let url): actionHandler(.openUrl(url))
            case .submitNew: viewState = .userDataForm
            }
        }
    }

    @ViewBuilder
    private func radioButtonsSelectorSection(title: String?, value: Binding<Props.DataRightsView.Right?>) -> some View {
        VStack {
            if let title = title {
                HStack {
                    Text(title)
                        .font(.system(size: 14, weight: .bold))
                    Spacer()
                }

                RadioButtonsGroup(
                    options: props.rights,
                    selected: value
                )
                .foregroundColor(props.theme.contentColor)
            }
        }
    }

    @ViewBuilder
    private func bottomButtonsSection() -> some View {
        VStack(spacing: 24) {
            CustomButton(
                props: .init(text: "Submit", theme: props.theme.firstButtonTheme)
            ) {
                viewState = .submitted
            }

            CustomButton(
                props: .init(text: "Cancel", theme: props.theme.secondaryButtonTheme)
            ) {
                actionHandler(.close)
                presentationMode.wrappedValue.dismiss()
            }
        }
    }
}

extension Props {
    struct DataRightsView {
        let bodyTitle: String?
        let bodyDescription: String?
        let theme: Theme
        let rights: [Right]

        struct Right: Hashable, RightDescription {
            let code: String
            let name: String
            let description: String
        }

        struct Theme {
            let titleFontSize: CGFloat = 16

            let bodyBackgroundColor: Color
            let contentColor: Color
            let linkColor: Color

            let borderRadius: Int

            let firstButtonBackgroundColor: Color
            let firstButtonBorderColor: Color
            let firstButtonTextColor: Color

            let secondButtonBackgroundColor: Color
            let secondButtonBorderColor: Color
            let secondButtonTextColor: Color
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
                    linkColor: .blue,
                    borderRadius: 5,
                    firstButtonBackgroundColor: .blue,
                    firstButtonBorderColor: .blue,
                    firstButtonTextColor: .white,
                    secondButtonBackgroundColor: .white,
                    secondButtonBorderColor: .blue,
                    secondButtonTextColor: .blue
                ),
                rights: [
                    .init(code: "f", name: "First", description: "First"),
                    .init(code: "s", name: "Second", description: "First")
                ]
            )
        ) { _ in }
    }
}
