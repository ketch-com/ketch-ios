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
        let categories: [Category]

        let primaryButton: Button?

        let theme: Theme
        let actionHandler: (Action) -> KetchUI.PresentationItem?

        struct Purpose: Identifiable {
            let consent: Bool
            let id: String = UUID().uuidString
            let title: String
            let legalBasisName: String
            let purposeDescription: String
            let legalBasisDescription: String
        }

        struct Vendor {

        }

        struct Category {

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
            case save
            case close
            case openUrl(URL)
        }
    }

    let props: Props

    @State var presentationItem: KetchUI.PresentationItem?
    @State private var allOptOut: Bool = false
    @State private var allOptIn: Bool = false

    @Environment(\.openURL) var openURL
    @Environment(\.presentationMode) private var presentationMode: Binding<PresentationMode>

    init(props: Props) {
        self.props = props
    }

    var body: some View {
        ZStack {
            VStack(alignment: .leading, spacing: 0) {
                HStack {
                    Text(props.title)
                        .font(.system(size: props.theme.titleFontSize, weight: .heavy))
                        .foregroundColor(props.theme.contentColor)
                    Spacer()
                    Button {
                        handle(action: .close)
                        presentationMode.wrappedValue.dismiss()
                    } label: {
                        Image(systemName: "xmark")
                    }
                    .foregroundColor(props.theme.contentColor)
                }
                .padding(.horizontal, 18)
                .padding(.vertical, 20)
                .background(Color(.systemGray6))

                NavigationView {
                    VStack {
                        ScrollView(showsIndicators: true) {
                            VStack(alignment: .leading, spacing: 16) {
                                Text(props.bodyTitle)
                                    .font(.system(size: 16, weight: .bold))

                                KetchUI.PresentationItem.descriptionText(with: props.bodyDescription) { url in
                                    handle(action: .openUrl(url))
                                }
                                .font(.system(size: props.theme.textFontSize))
                                .foregroundColor(props.theme.contentColor)
                                .accentColor(props.theme.linkColor)
                            }
                            .padding(18)

                            purposesView()
                        }

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
        }
        
    }

    private func handle(action: Props.Action) {
        presentationItem = props.actionHandler(action)
    }

    @ViewBuilder
    func purposesView() -> some View {
        VStack {
            HStack {
                Text("Purposes")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(props.theme.contentColor)

                Spacer()

                Button {
                    allOptIn = false
                    allOptOut = true
                } label: {
                    Text("Opt Out")
                        .padding(.horizontal)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.black)
                        .frame(height: 28)
                }
                .background(Color(UIColor.systemGray6).cornerRadius(5))

                Button {
                    allOptIn = true
                    allOptOut = false
                } label: {
                    Text("Opt In")
                        .padding(.horizontal)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.black)
                        .frame(height: 28)
                }
                .background(Color(UIColor.systemGray6).cornerRadius(5))
            }
            .padding(.horizontal)

            ForEach(props.purposes) { purpose in
                PurposeCell(
                    purpose: purpose,
                    vendorsDestination: props.vendors.isEmpty ? nil : { vendorsView },
                    categoriesDestination: props.categories.isEmpty ? nil : { categoriesView }
                )
            }
        }
        .animation(.easeInOut(duration: 0.15))
    }

    @ViewBuilder
    var vendorsView: some View {
        VStack {
            Text("Vendors")
        }
    }

    @ViewBuilder
    var categoriesView: some View {
        VStack {
            Text("Categories")
        }
    }
}

struct Collapsible<Content: View>: View {
    @State var label: () -> Text
    @State var content: () -> Content

    @State private var collapsed: Bool = true

    var body: some View {
        VStack {
            Button(
                action: { self.collapsed.toggle() },
                label: {
                    HStack {
                        label()
                        Spacer()
                        Image(systemName: collapsed ? "chevron.down" : "chevron.up")
                    }
                    .padding(.bottom, 1)
                    .background(Color.white.opacity(0.01))
                }
            )
            .buttonStyle(PlainButtonStyle())

            VStack {
                content()
            }
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: collapsed ? 0 : .none)
            .clipped()
            .animation(.easeOut)
            .transition(.slide)
        }
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

                    purposes: [
                        .init(
                            consent: true,
                            title: "Store and/or access information on a device",
                            legalBasisName: "Legal Basic: Consent - Opt In",
                            purposeDescription: "Cookies, device identifiers, or other information can be stored or accessed on your device for the purposes presented to you.",
                            legalBasisDescription: "Data subject has affirmatively and unambiguously consented to the processing for one or more specific purposes"
                        ),
                        .init(
                            consent: false,
                            title: "Store and/or access information on a device",
                            legalBasisName: "Legal Basic: Consent - Opt In",
                            purposeDescription: "Cookies, device identifiers, or other information can be stored or accessed on your device for the purposes presented to you.",
                            legalBasisDescription: "Data subject has affirmatively and unambiguously consented to the processing for one or more specific purposes"
                        ),
                        .init(
                            consent: false,
                            title: "Store and/or access information on a device",
                            legalBasisName: "Legal Basic: Consent - Opt In",
                            purposeDescription: "Cookies, device identifiers, or other information can be stored or accessed on your device for the purposes presented to you.",
                            legalBasisDescription: "Data subject has affirmatively and unambiguously consented to the processing for one or more specific purposes"
                        ),
                        .init(
                            consent: false,
                            title: "Store and/or access information on a device",
                            legalBasisName: "Legal Basic: Consent - Opt In",
                            purposeDescription: "Cookies, device identifiers, or other information can be stored or accessed on your device for the purposes presented to you.",
                            legalBasisDescription: "Data subject has affirmatively and unambiguously consented to the processing for one or more specific purposes"
                        ),
                        .init(
                            consent: false,
                            title: "Store and/or access information on a device",
                            legalBasisName: "Legal Basic: Consent - Opt In",
                            purposeDescription: "Cookies, device identifiers, or other information can be stored or accessed on your device for the purposes presented to you.",
                            legalBasisDescription: "Data subject has affirmatively and unambiguously consented to the processing for one or more specific purposes"
                        )
                    ],
                    vendors: [.init()],
                    categories: [.init()],

                    primaryButton: ModalView.Props.Button(
                        text: "I understand",
                        textColor: .white,
                        borderColor: .blue,
                        backgroundColor: .blue,
                        action: .save
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

    @ViewBuilder
    static var testExpand: some View {
        List(0...10, id: \.self) { idx in
            DisclosureGroup {
                HStack {
                    Image(systemName: "person.circle.fill")
                    VStack(alignment: .leading) {
                        Text("ABC")
                        Text("Test Test")
                    }
                }
                HStack {
                    Image(systemName: "globe")
                    VStack(alignment: .leading) {
                        Text("ABC")
                        Text("X Y Z")
                    }
                }
                HStack {
                    Image(systemName: "water.waves")
                    VStack(alignment: .leading) {
                        Text("Bla Bla")
                        Text("123")
                    }
                }
                HStack{
                    Button("Cancel") {}
                    Spacer()
                    Button("Book") {}
                }
            } label: {
                HStack {
                    Text("Expand")
                    Spacer()
                }
            }
        }
    }
}

struct PurposeCell<VendorsContent: View, CategoriesContent: View>: View {
    let purpose: ModalView.Props.Purpose
    let vendorsDestination: (() -> VendorsContent)?
    let categoriesDestination: (() -> CategoriesContent)?

    @State private var isExpanded: Bool = false
    @State private var isAccepted: Bool = false

    init(
        purpose: ModalView.Props.Purpose,
        vendorsDestination: (() -> VendorsContent)?,
        categoriesDestination: (() -> CategoriesContent)?
    ) {
        self.purpose = purpose
        self.vendorsDestination = vendorsDestination
        self.categoriesDestination = categoriesDestination
    }

    var body: some View {
        content
            .padding(.horizontal)
            .frame(maxWidth: .infinity)
            .onTapGesture { isExpanded.toggle() }
            .background(
                Color.white
                    .onTapGesture { isExpanded.toggle() }
            )
    }

    private var content: some View {
        VStack {
            HStack(alignment: .top) {
                Image(systemName: isExpanded ? "chevron.down" : "chevron.right")
                    .frame(width: 20, height: 20)
                    .padding(4)

                VStack(alignment: .leading, spacing: 20) {
                    header
                    if isExpanded {
                        VStack(alignment: .leading, spacing: 20) {
                            Text("Purpose: ")
                                .font(.system(size: 14, weight: .bold))
                            + Text(purpose.purposeDescription)
                                .font(.system(size: 14))

                            Text("Legal Basic: ")
                                .font(.system(size: 14, weight: .bold))
                            + Text(purpose.legalBasisDescription)
                                .font(.system(size: 14))
                        }

                        if let vendorsDestination = vendorsDestination {
                            NavigationLink(destination: vendorsDestination) {
                                Text("Vendors")
                                    .font(.system(size: 14, weight: .bold))
                                Image(systemName: "arrow.up.forward.app")
                            }
                            .foregroundColor(.black)
                        }

                        if let categoriesDestination = categoriesDestination {
                            NavigationLink(destination: categoriesDestination) {
                                Text("Categories")
                                    .font(.system(size: 14, weight: .bold))
                                Image(systemName: "arrow.up.forward.app")
                            }
                            .foregroundColor(.black)
                        }
                    }
                }
            }
            Divider()
        }
    }

    private var header: some View {
        HStack(spacing: 0) {
            VStack(alignment: .leading) {
                Text(purpose.title)
                    .font(.system(size: 16, weight: .bold))
                Text(purpose.legalBasisName)
                    .font(.system(size: 14))
            }

            Spacer()

            Toggle("Accept", isOn: $isAccepted)
                .labelsHidden()
                .toggleStyle(SwitchToggleStyle(tint: .black))
                .onTapGesture { }
        }
        .padding(.vertical, 4)
    }
}

//    .toolbar {
//        ToolbarItem(placement: .navigationBarLeading) {
//            Button {
//
//            } label: {
//                Image(systemName: "chevron.left")
//                Text("Vendors")
//            }
//
//        }
//    }
//    .navigationBarBackButtonHidden(true)
