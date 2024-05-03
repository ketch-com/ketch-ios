#if !os(macOS)

import SwiftUI

extension View {
    public func ketchView(model: Binding<KetchUI.WebPresentationItem?>) -> some View {
        modifier(KetchViewModifier(model: model))
    }
}

struct KetchViewModifier: ViewModifier {
    @Binding var model: KetchUI.WebPresentationItem?
    
    @State private var screenSize = CGSize.zero
    
    @ViewBuilder
    var bannerView: some View {
        if let presentationItem = model {
            presentationItem.content
        }
    }
    
    func body(content: Content) -> some View {
        ZStack {
            content
            GeometryReader { geometry in
                ZStack {}
                    .onAppear {
                        screenSize = geometry.size
                    }
                    .onChange(of: geometry.size) { screenSize in
                        self.screenSize = screenSize
                    }
            }
            .overlay {
                if model != nil {
                    bannerView
                }
            }
        }
    }
}

#endif
