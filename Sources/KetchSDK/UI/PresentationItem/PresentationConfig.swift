//
//  PresentationConfig.swift
//  KetchSDK
//
//  Created by Roman Simenok on 23.01.2024.
//

import SwiftUI

extension KetchUI {
    
    public struct PresentationConfig {
        public enum Style { case modal, banner, fullScreen }
        public enum VPosition { case top, center, bottom }
        public enum HPosition { case left, center, right }
        
        public let vpos: VPosition
        public let hpos: HPosition
        public let style: Style
        public let size: CGSize?
        
        private let defaultPadding: CGFloat = 8
        
        public init(vpos: VPosition, hpos: HPosition, style: Style, size: CGSize = .zero) {
            self.vpos = vpos
            self.hpos = hpos
            self.style = style
            self.size = size
        }
        
        public var isCenterPresentation: Bool {
            vpos == .center && hpos == .center
        }
        
        public func padding(screenSize: CGSize) -> EdgeInsets {
            switch style {
            case .modal:
                guard let size else {
                    return EdgeInsets()
                }
                
                return calculateModalEdgeInsets(screenSize: screenSize, modalSize: size)
            case .banner:
                guard let size else {
                    return EdgeInsets()
                }
                
                return calculateBannerEdgeInsets(screenSize: screenSize, bannerSize: size)
            case .fullScreen:
                return EdgeInsets()
            }
        }
        
        public var transitionEdge: Edge {
            switch (hpos, vpos) {
            case (.center, .top): return .top
            case (.center, .bottom): return .bottom
            case (.left, _): return .leading
            case (.right, _): return .trailing
            case (.center, .center): return .bottom
            }
        }
        
        // TODO: remove top/bottom default paddings is save area insets bigger than 0
        private func calculateModalEdgeInsets(screenSize: CGSize, modalSize: CGSize) -> EdgeInsets {
            let isPhone = UIDevice.current.userInterfaceIdiom == .phone
            let topPadding: CGFloat
            let bottomPadding: CGFloat
            let leadingPadding: CGFloat
            let trailingPadding: CGFloat
            
            switch (hpos, vpos) {
            case (.left, .center):
                if isPhone {
                    topPadding = screenSize.height - modalSize.height - defaultPadding
                    bottomPadding = defaultPadding
                } else {
                    let verticalPadding = (screenSize.height - modalSize.height) / 2
                    topPadding = verticalPadding
                    bottomPadding = verticalPadding
                }
                leadingPadding = defaultPadding
                trailingPadding = screenSize.width - modalSize.width + defaultPadding
            case (.right, .center):
                if isPhone {
                    topPadding = screenSize.height - modalSize.height + defaultPadding
                    bottomPadding = defaultPadding
                } else {
                    let verticalPadding = (screenSize.height - modalSize.height) / 2
                    topPadding = verticalPadding
                    bottomPadding = verticalPadding
                }
                leadingPadding = screenSize.width - modalSize.width + defaultPadding
                trailingPadding = defaultPadding
            default: // center
                let verticalPadding = ((screenSize.height - modalSize.height) / 2)
                let horizontalPadding = ((screenSize.width - modalSize.width) / 2)
                
                topPadding = verticalPadding
                bottomPadding = verticalPadding
                leadingPadding = horizontalPadding
                trailingPadding = horizontalPadding
            }
            
            return EdgeInsets(
                top: topPadding,
                leading: leadingPadding,
                bottom: bottomPadding,
                trailing: trailingPadding
            )
        }
        
        // TODO: remove top/bottom default paddings is save area insets bigger than 0
        private func calculateBannerEdgeInsets(screenSize: CGSize, bannerSize: CGSize) -> EdgeInsets {
            let topPadding: CGFloat
            let bottomPadding: CGFloat
            let leadingPadding: CGFloat
            let trailingPadding: CGFloat
            
            switch (hpos, vpos) {
            case (.center, .bottom):
                topPadding = screenSize.height - bannerSize.height + defaultPadding
                bottomPadding = defaultPadding
                leadingPadding = defaultPadding
                trailingPadding = defaultPadding
            case (.center, .top):
                topPadding = defaultPadding
                bottomPadding = screenSize.height - bannerSize.height + defaultPadding
                leadingPadding = defaultPadding
                trailingPadding = defaultPadding
            case (.right, .bottom):
                topPadding = screenSize.height - bannerSize.height + defaultPadding
                bottomPadding = defaultPadding
                leadingPadding = screenSize.width - bannerSize.width + defaultPadding
                trailingPadding = defaultPadding
            case (.left, .bottom):
                topPadding = screenSize.height - bannerSize.height + defaultPadding
                bottomPadding = defaultPadding
                leadingPadding = defaultPadding
                trailingPadding = screenSize.width - bannerSize.width + defaultPadding
            default: // center
                let verticalPadding = ((screenSize.height - bannerSize.height) / 2)
                let horizontalPadding = ((screenSize.width - bannerSize.width) / 2)
                
                topPadding = verticalPadding
                bottomPadding = verticalPadding
                leadingPadding = horizontalPadding + defaultPadding
                trailingPadding = horizontalPadding + defaultPadding
            }
            
            return EdgeInsets(
                top: topPadding,
                leading: leadingPadding,
                bottom: bottomPadding,
                trailing: trailingPadding
            )
        }
    }
}

