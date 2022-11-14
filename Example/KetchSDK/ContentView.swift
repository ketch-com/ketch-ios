//
//  ContentView.swift
//  KetchSDK
//
//  Created by Anton Lyfar on 08.11.2022.
//

import SwiftUI
import KetchSDK

struct ContentView: View {
    let ketch: Ketch
    let ketchUI: KetchUI

    @ObservedObject var modalManager: ModalManager

    enum Constants {
        enum Jurisdiction {
            static let GDPR = "gdpr"
            static let CCPA = "ccpa"
        }
    }

    init() {
        ketch = KetchSDK.create(
            organizationCode: "transcenda",
            propertyCode: "website_smart_tag",
            environmentCode: "production",
            controllerCode: "my_controller",
            identities: ["idfa" : "00000000-0000-0000-0000-000000000000"]
        )

        ketch.add(plugins: [
            TCF(),
            CCPA()
        ])

        ketchUI = KetchUI(ketch: ketch)
        modalManager = ketchUI.modalManager
    }

    var body: some View {
        ZStack {
            VStack(spacing: 40) {
                Button("Configuration") {
                    ketch.loadConfiguration()
                }
                
                Button("Configuration GDPR") {
                    ketch.loadConfiguration(jurisdiction: Constants.Jurisdiction.GDPR)
                }
                
                Button("Configuration CCPA") {
                    ketch.loadConfiguration(jurisdiction: Constants.Jurisdiction.CCPA)
                }
                
                Button("Invoke Rights") {
                    ketch.invokeRights(
                        user: KetchSDK.InvokeRightConfig.User(
                            email: "user@email.com",
                            first: "FirstName",
                            last: "LastName",
                            country: nil,
                            stateRegion: nil,
                            description: nil,
                            phone: nil,
                            postalCode: nil,
                            addressLine1: nil,
                            addressLine2: nil
                        )
                    )
                }
                
                Button("Get Consent") {
                    ketch.loadConsent()
                }
                
                Button("Update Consent") {
                    ketch.updateConsent()
                }
                
                Button("Show Banner") {
                    ketchUI.showBanner()
                }
                
                Button("Show Modal") {
                    modalManager.openModal()
                }
                
                Button("Show JIT") {
                    
                }
                
                Button("Show Preference") {
                    
                }
            }

            ketchUI.item

//            ModalAnchorView()
        }
//        .fullScreenCover(item: $modalManager.modal) { item in
        .sheet(item: $modalManager.modal) { item in
            item.content.asResponsiveSheet()
        }
//        .onAppear {
//            modalManager.newModal(position: .closed) {}
//        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
//            .environmentObject(ModalManager())
    }
}



fileprivate struct ResponsiveSheetWrapper: ViewModifier {

    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>

    func body(content: Content) -> some View {
        /// check device type (ipad sheet are centred / iPhone sheet pinned to bottom )
        if UIDevice.current.userInterfaceIdiom == .phone {
            ZStack (alignment: .bottom){
                Color(UIColor.systemBackground.withAlphaComponent(0.01))
                    .onTapGesture {
                        // tap outside the view to dismiss
//                        presentationMode.wrappedValue.dismiss()
                    }
                    .edgesIgnoringSafeArea(.all)
                VStack {
                    /// the small thumb for bottom sheet native like
//                    thumb
                    content
                }
                /// redesign the content
                .asResponsiveSheetContent()
            }
            /// remove system background
            .clearSheetSystemBackground()
            .edgesIgnoringSafeArea(.bottom)
        } else {
            ZStack {
                Color(UIColor.systemBackground.withAlphaComponent(0.01))
                    .onTapGesture {
                        // tap outside the view to dismiss
                        presentationMode.wrappedValue.dismiss()
                    }
                content
                /// redesign the content
                .asResponsiveSheetContent()
            }
            /// remove system background
            .clearSheetSystemBackground()
            .edgesIgnoringSafeArea(.all)
        }
    }

    var thumb: some View {
        HStack{
            Spacer()
            Capsule()
                .frame(width: 40, height: 4)
                .foregroundColor(Color(UIColor.systemFill))
            Spacer()
        }
        .padding(.top, 8)
        .padding(.bottom, 8)
    }
}

fileprivate struct ResponsiveSheetContent: ViewModifier {
    /// ResponsiveSheetContent will create the form of a bottom sheet (apply corners radius for both iPad an iPhone sheet)
    @Environment(\.safeAreaInsets) private var safeAreaInsets

    func body(content: Content) -> some View {
        if UIDevice.current.userInterfaceIdiom == .phone {
            content
                .padding(.bottom, safeAreaInsets.bottom)
                .background(Color(UIColor.systemBackground))
                .cornerRadius(10, corners: [.topLeft, .topRight])
        } else {
            content
                .padding()
                .background(Color(UIColor.systemBackground))
                .cornerRadius(10, corners: [.allCorners])
        }
    }
}

fileprivate struct ClearBackgroundViewModifier: ViewModifier {

    func body(content: Content) -> some View {
        content
            .background(ClearBackgroundView())
    }
}

fileprivate struct CornerRadiusStyle: ViewModifier {
    var radius: CGFloat
    var corners: UIRectCorner

    struct CornerRadiusShape: Shape {

        var radius = CGFloat.infinity
        var corners = UIRectCorner.allCorners

        func path(in rect: CGRect) -> Path {
            let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
            return Path(path.cgPath)
        }
    }

    func body(content: Content) -> some View {
        content
            .clipShape(CornerRadiusShape(radius: radius, corners: corners))
    }
}

//MARK: - UIViewRepresentable
fileprivate struct ClearBackgroundView: UIViewRepresentable {
    /// The Key
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        DispatchQueue.main.async {
            /// GOD BLESS UI KIT
            /// Target sheet system background view
            /// Apply clear Color
            view.superview?.superview?.backgroundColor = .clear
//            view.superview?.superview?.superview?.superview?.superview?.removeGestureRecognizer(view.superview!.superview!.superview!.superview!.superview!.gestureRecognizers!.first!)
        }
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {}
}

//MARK: - View Extension
extension View {
    /// Return a formatted View Based on Device Type
    /// if iPad => Centered Alert-Like View
    /// if iPhone => Bottom Sheet View
    /// That's all folks
    func asResponsiveSheet() -> some View {
        modifier(ResponsiveSheetWrapper())
    }

    fileprivate func asResponsiveSheetContent() -> some View {
        modifier(ResponsiveSheetContent())
    }

    fileprivate func clearSheetSystemBackground() -> some View {
        modifier(ClearBackgroundViewModifier())
    }

    fileprivate func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        modifier(CornerRadiusStyle(radius: radius, corners: corners))
    }
}

//MARK: - EnvironmentKey & Values
fileprivate struct SafeAreaInsetsKey: EnvironmentKey {
    static var defaultValue: EdgeInsets {
        (UIApplication.shared.windows.first(where: { $0.isKeyWindow })?.safeAreaInsets ?? .zero).insets
    }
}

fileprivate extension EnvironmentValues {
    var safeAreaInsets: EdgeInsets {
        self[SafeAreaInsetsKey.self]
    }
}

//MARK: - UIEdgeInsets Extension
fileprivate extension UIEdgeInsets {
    var insets: EdgeInsets {
        EdgeInsets(top: top, leading: left, bottom: bottom, trailing: right)
    }
}
