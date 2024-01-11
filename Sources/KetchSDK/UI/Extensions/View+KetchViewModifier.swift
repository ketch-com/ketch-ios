import SwiftUI

extension View {
    public func ketchView(model: Binding<KetchUI.WebPresentationItem?>) -> some View {
        modifier(KetchViewModifier(model: model))
    }
}

struct KetchViewModifier: ViewModifier {
    @Binding var model: KetchUI.WebPresentationItem?
    
    @State private var screenSize = CGSize.zero
    
    private var transition: AnyTransition {
        let isCenterAnimation = model?.presentationConfig?.isCenterPresentation ?? false
        
        return isCenterAnimation
        ? AnyTransition.scale(scale: 1).combined(with: .opacity)
        : AnyTransition.move(edge: model?.presentationConfig?.transitionEdge ?? .bottom).combined(with: .opacity)
    }
    
    @ViewBuilder
    var bannerView: some View {
        if let presentationItem = model,
           let config = model?.presentationConfig {
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
                    }
                    .onChange(of: geometry.size) { screenSize in
                        self.screenSize = screenSize
                    }
            }
            .overlay {
                if model != nil {
                    Color.white.opacity(0.001)
                        .onTapGesture {
                            withAnimation { model = nil }
                        }
                    bannerView
                }
            }
        }
    }
}
