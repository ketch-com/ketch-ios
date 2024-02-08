import SwiftUI

extension View {
    public func ketchView(model: KetchUI) -> some View {
        modifier(KetchViewModifier(model: model))
    }
}

struct KetchViewModifier: ViewModifier {
    @ObservedObject var model: KetchUI
    
    @State private var screenSize = CGSize.zero
    
    private var transition: AnyTransition {
        let isCenterAnimation = model.webPresentationItem?.presentationConfig?.isCenterPresentation ?? false
        
        return isCenterAnimation
        ? AnyTransition.scale(scale: 1).combined(with: .opacity)
        : AnyTransition.move(edge: model.webPresentationItem?.presentationConfig?.transitionEdge ?? .bottom).combined(with: .opacity)
    }
    
    @ViewBuilder
    var bannerView: some View {
        if let presentationItem = model.webPresentationItem,
           let config = presentationItem.presentationConfig {
            if config.style == .fullScreen {
                presentationItem.content
            } else {
                presentationItem.content
                    .padding(config.padding(screenSize: screenSize))
                    .transition(transition)
                    .animation(.easeInOut)
            }
        }
    }
    
    func body(content: Content) -> some View {
        ZStack {
            content
            GeometryReader { geometry in
                ZStack {}
                    .onAppear {
                        screenSize = geometry.size
                        model.updateKetchView(screenSize: geometry.size)
                    }
                    .onChange(of: geometry.size) { screenSize in
                        self.screenSize = screenSize
                        model.updateKetchView(screenSize: screenSize)
                    }
            }
            .overlay {
                if model.webPresentationItem != nil {
                    Color.white.opacity(0.001)
                        .ignoresSafeArea()
                    bannerView
                }
            }
        }
    }
}
