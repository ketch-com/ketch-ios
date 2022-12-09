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
    @State private var selectedOption: String?
    @State private var requestDetails = String()
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
                    TitleDescriptionSection(
                        props: props.titleDescriptionSectionProps
                    ) { action in
                        switch action {
                        case .openUrl(let url): actionHandler(.openUrl(url))
                        }
                    }

                    radioButtonsSelectorSection(title: "Name", value: $selectedOption)

                    TextEditorSection(title: "Name", accentColor: props.theme.contentColor, value: $requestDetails)
                        .onTapGesture {
                            selectedId = 1
                        }
                        .id(1)

                    TextFieldSection(
                        title: "Name",
                        hint: nil,
                        accentColor: props.theme.contentColor,
                        value: $requestDetails
                    )
                    .onTapGesture {
                        selectedId = 2
                    }
                    .id(2)

                    TextFieldSection(
                        title: "Name",
                        hint: nil,
                        accentColor: props.theme.contentColor,
                        value: $requestDetails
                    )
                    .onTapGesture {
                        selectedId = 3
                    }
                    .id(3)

                    CountrySelectionSection(
                        title: "Country",
                        contentColor: props.theme.contentColor,
                        value: $selectedCountryCode
                    )

                    bottomButtonsSection()
                }
                .padding(18)
                .padding(.bottom, 40)
                .onChange(of: selectedId) { newValue in
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        withAnimation(.easeInOut(duration: 0.15)) {
                            proxy.scrollTo(selectedId, anchor: .center)
                        }
                    }
                }
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

        }
    }

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

        struct Theme {
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
                )
            )
        ) { _ in }
    }
}
