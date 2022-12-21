//
//  DataRightsView.swift
//  KetchSDK
//

import SwiftUI

struct DataRightsView: View {
    typealias ViewProps = Props.DataRightsView

    enum Action {
        case close
        case openUrl(URL)
        case submit(DataRightCoding, UserDataCoding)

        struct Right: Hashable {
            let code: String
            let name: String
            let description: String
        }
    }

    private enum ViewState {
        case userDataForm
        case submitted
    }

    private struct ErrorAlert: Identifiable {
        let id = UUID()
        let title: String
        let message: String
    }

    let props: ViewProps
    let actionHandler: (Action) -> Void

    @State private var validationErrorAlert: ErrorAlert?
    @State private var viewState: ViewState = .userDataForm
    @State private var selectedId: Int = 0
    @StateObject private var entry = DataRightsEntry()
    @ObservedObject private var keyboard = KeyboardResponder()
    @Environment(\.presentationMode) private var presentationMode: Binding<PresentationMode>

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

                        radioButtonsSelectorSection(title: "Request", value: $entry.selectedRight)
                    }

                    VStack(alignment: .leading, spacing: 24) {
                        textEditorSection(field: entry.requestDetails, id: 1)
                        .padding(.bottom, 24)

                        Text("Personal Details")
                            .font(.system(size: props.theme.titleFontSize, weight: .bold))
                            .foregroundColor(props.theme.contentColor)

                        textFieldSection(field: entry.firstName, id: 2)
                        textFieldSection(field: entry.lastName, id: 3)
                        textFieldSection(field: entry.email, id: 4)
                        textFieldSection(field: entry.phone, id: 5)
                        pickerListSection(field: entry.country)
                        textFieldSection(field: entry.postalCode, id: 6)
                        textFieldSection(field: entry.addressLine1, id: 7)
                        textFieldSection(field: entry.addressLine2, id: 8)
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
        .onAppear { entry.selectedRight = props.rights.first }
        .onTapGesture(perform: hideKeyboard)
        .alert(item: $validationErrorAlert) { alert in
            Alert(title: Text(alert.title), message: Text(alert.message))
        }
    }

    @ViewBuilder
    func textFieldSection(field: FieldEntry, id: Int) -> some View {
        TextFieldSection(
            title: field.title,
            hint: nil,
            accentColor: props.theme.contentColor,
            error: Binding<String?>(get: { field.error }, set: { _, _ in }),
            value: Binding<String>(get: { field.value }, set: {field.value = $0; field.error = field.validationErrorText(for: $0) })
        )
        .onTapGesture { selectedId = id }
        .id(id)
    }

    @ViewBuilder
    func textEditorSection(field: FieldEntry, id: Int) -> some View {
        TextEditorSection(
            title: field.title,
            accentColor: props.theme.contentColor,
            error: Binding<String?>(get: { field.error }, set: { _, _ in }),
            value: Binding<String>(
                get: { field.value },
                set: { field.value = $0; field.error = field.validationErrorText(for: $0) }
            )
        )
        .onTapGesture { selectedId = id }
        .id(id)
    }

    @ViewBuilder
    func pickerListSection(field: FieldEntry) -> some View {
        CountrySelectionSection(
            title: field.title,
            contentColor: props.theme.contentColor,
            value: Binding<String>(
                get: { field.value },
                set: { field.value = $0; field.error = field.validationErrorText(for: $0) }
            )
        )
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
    private func radioButtonsSelectorSection(title: String?, value: Binding<ViewProps.Right?>) -> some View {
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
                if let firstNotValid = entry.firstNotValid {
                    hideKeyboard()
                    firstNotValid.setError()
                    return validationErrorAlert = ErrorAlert(
                        title: firstNotValid.title,
                        message: "Please, enter valid value"
                    )
                }

                guard let selected = entry.selectedRight else { return }

                let actionRight = ViewProps.Right(code: selected.code, name: selected.name, description: selected.description)

                actionHandler(.submit(actionRight, entry.request))
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
