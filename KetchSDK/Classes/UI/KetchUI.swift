//
//  KetchUI.swift
//  KetchSDK
//
//  Created by Anton Lyfar on 08.11.2022.
//

import SwiftUI
import Combine

public class KetchUI: ObservableObject {
    @Published public var presentationItem: PresentationItem?

    //
    private var modalManager = ModalManager()

    private var subscriptions = Set<AnyCancellable>()

    public init(ketch: Ketch) {
        ketch.configurationPublisher
            .replaceError(with: nil)
            .sink { configuration in

            }
            .store(in: &subscriptions)

        ketch.consentPublisher
            .replaceError(with: nil)
            .sink { consentStatus in

            }
            .store(in: &subscriptions)
    }

    public func showBanner() {
        presentationItem = PresentationItem(itemType: .banner)
    }

    public func showModal() {
        presentationItem = PresentationItem(itemType: .modal)
    }

    public func showJIT() {
        presentationItem = PresentationItem(itemType: .jit)
    }

    public func showPreference() {
        presentationItem = PresentationItem(itemType: .preference)
    }

}





















//
//struct CompoundView: View {
//    @State private var height: CGFloat = 0
//
//    var body: some View {
//        ZStack {
//            Color.white
//            content
//                .background(HeightReader(height: $height))
//        }
//        .frame(height: height)
//    }
//}

private struct CompoundViewModifier: ViewModifier {
    @Environment(\.safeAreaInsets) private var safeAreaInsets
    @State private var height: CGFloat = 0

    func body(content: Content) -> some View {
        ZStack {
            Color.clear
                .frame(height: height)
            content
                .background(HeightReader(height: $height))
        }
        .padding(.bottom, safeAreaInsets.bottom)
    }
}




public enum ModalState: CGFloat {
    case closed, partiallyRevealed, open
}

public struct Modal: Identifiable {
    public var id: String = UUID().uuidString

    var position: ModalState  = .closed
    var dragOffset: CGSize = .zero
    public var content: AnyView?
}

//struct ModalAnchorView: View {
//
//    @EnvironmentObject var modalManager: ModalManager
//
//    var body: some View {
//        ModalView2(modal: $modalManager.modal)
//    }
//}

public class ModalManager: ObservableObject {

    @Published public var modal: Modal? = Modal(position: .closed, content: nil)

    public func newModal<Content: View>(position: ModalState, @ViewBuilder content: () -> Content) {
        modal = Modal(position: position, content: AnyView(content()))
    }

    public func openModal() {
        modal?.position = .partiallyRevealed
    }

    func closeModal() {
        modal?.position = .closed
    }

    public init(modal: Modal? = nil) {
        self.modal = modal
    }
}

struct ModalView2: View {
    @Binding var modal: Modal

    private var animation: Animation {
        Animation
            .interpolatingSpring(mass: 0.7, stiffness: 300.0, damping: 30.0, initialVelocity: 10.0)
            .delay(0)
    }

    public var body: some View {
        ZStack(alignment: .top) {
            Color.black
                .opacity(modal.position != .closed ? 0.1 : 0)
                .onTapGesture { modal.position = .closed }

            VStack {
                Spacer()
                modal.content
                    .mask(RoundedRectangle(cornerRadius: 8, style: .continuous))
            }
            .offset(y: modal.position == .partiallyRevealed ? 0 : UIScreen.main.bounds.height)
            .animation(animation)
        }
        .edgesIgnoringSafeArea([.top, .bottom])
    }
}

struct HeightReader: View {
    @Binding var height: CGFloat
    var body: some View {
        GeometryReader { proxy -> Color in
            update(with: proxy.size.height)
            return Color.clear
        }
    }
    private func update(with value: CGFloat) {
        guard value != height else { return }
        DispatchQueue.main.async {
            height = value
        }
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
