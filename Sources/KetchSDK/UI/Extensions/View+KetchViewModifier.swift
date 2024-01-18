import SwiftUI

extension View {
    public func ketchView(model: Binding<KetchUI.WebPresentationItem?>) -> some View {
        modifier(KetchViewModifier(model: model))
    }
}

struct KetchViewModifier: ViewModifier {
    @Binding var model: KetchUI.WebPresentationItem?
    
    private var transitionEdge: Edge {
        guard let presentationConfig = model?.presentationConfig else { return .bottom }
        
        switch (presentationConfig.hpos, presentationConfig.vpos) {
        case (.center, .top): return .top
        case (.center, .bottom): return .bottom
        case (.left, _): return .leading
        case (.right, _): return .trailing
        case (.center, .center): return .bottom
        }
    }
    
    private var paddingEdge: Edge.Set {
        guard let presentationConfig = model?.presentationConfig else { return .bottom }
        
        switch presentationConfig.vpos {
        case .top: return .bottom
        case .bottom: return .top
        case .center: return [.top, .bottom]
        }
    }
    
    private var paddingValue: CGFloat? {
        guard let bannerConfig = model?.presentationConfig else { return nil }
        
        switch bannerConfig.vpos {
        case .center: return 100
        default: return 200
        }
    }
    
    private var transition: AnyTransition {
        let isCenterAnimation = model?.presentationConfig?.hpos == .center && model?.presentationConfig?.vpos == .center
        
        return isCenterAnimation
        ? AnyTransition.scale(scale: 1).combined(with: .opacity)
        : AnyTransition.move(edge: transitionEdge).combined(with: .opacity)
    }
    
    @ViewBuilder
    var bannerView: some View {
        if let presentationItem = model {
            presentationItem.content
                .cornerRadius(10)
                .shadow(radius: 10)
                .padding()
                .padding(paddingEdge, paddingValue)
                .transition(transition)
                .animation(.easeInOut)
        }
        
    }
    
    func body(content: Content) -> some View {
        ZStack {
            content
            GeometryReader { _ in }
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
