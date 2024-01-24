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
        
        private let defaultPadding: CGFloat = 8
        
        public init(vpos: VPosition, hpos: HPosition, style: Style) {
            self.vpos = vpos
            self.hpos = hpos
            self.style = style
        }
        
        public var isCenterPresentation: Bool {
            vpos == .center && hpos == .center
        }
        
        public func padding(screenSize: CGSize) -> EdgeInsets {
            switch style {
            case .modal:
                return calculateModalEdgeInsets(screenSize: screenSize)
            case .banner:
                return calculateBannerEdgeInsets(screenSize: screenSize)
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
        
        private func calculateModalSize(screenSize: CGSize) -> CGSize {
            switch UIDevice.current.userInterfaceIdiom {
            case .pad:
                switch (hpos, vpos) {
                case (.left, .center), (.right, .center):
                    return CGSizeMake(screenSize.width * 0.40, screenSize.height)
                default: // center
                    return CGSizeMake(screenSize.width * 0.65, screenSize.height * 0.65)
                }
            case .phone:
                return CGSizeMake(screenSize.width, screenSize.height * 0.9)
            default: // other devices not supported for now
                return .zero
            }
        }
        
        private func calculateBannerSize(screenSize: CGSize) -> CGSize {
            switch UIDevice.current.userInterfaceIdiom {
            case .pad:
                switch (vpos, hpos) {
                case (.bottom, .center), (.top, .center):
                    return CGSizeMake(screenSize.width, screenSize.height * 0.3)
                // TODO: handle iPad mini size, now polished for bigger iPad
                case (.center, .center):
                    if UIDevice.current.orientation == .portrait || UIDevice.current.orientation == .portraitUpsideDown {
                        return CGSizeMake(screenSize.width * 0.54, screenSize.height * 0.18)
                    } else {
                        return CGSizeMake(screenSize.width * 0.4, screenSize.height * 0.24)
                    }
                case (_ , .left), (_, .right):
                    return CGSizeMake(328, 415)
                }
            case .phone:
                return CGSizeMake(screenSize.width, screenSize.height * 0.75)
            default: // other devices not supported for now
                return .zero
            }
        }
        
        // TODO: remove top/bottom default paddings is save area insets bigger than 0
        private func calculateModalEdgeInsets(screenSize: CGSize) -> EdgeInsets {
            let isPhone = UIDevice.current.userInterfaceIdiom == .phone
            let bannerSize = calculateModalSize(screenSize: screenSize)
            let topPadding: CGFloat
            let bottomPadding: CGFloat
            let leadingPadding: CGFloat
            let trailingPadding: CGFloat
            
            switch (hpos, vpos) {
            case (.left, .center):
                if isPhone {
                    topPadding = screenSize.height - bannerSize.height - defaultPadding
                    bottomPadding = defaultPadding
                } else {
                    let verticalPadding = (screenSize.height - bannerSize.height) / 2
                    topPadding = verticalPadding
                    bottomPadding = verticalPadding
                }
                leadingPadding = defaultPadding
                trailingPadding = screenSize.width - bannerSize.width + defaultPadding
            case (.right, .center):
                if isPhone {
                    topPadding = screenSize.height - bannerSize.height + defaultPadding
                    bottomPadding = defaultPadding
                } else {
                    let verticalPadding = (screenSize.height - bannerSize.height) / 2
                    topPadding = verticalPadding
                    bottomPadding = verticalPadding
                }
                leadingPadding = screenSize.width - bannerSize.width + defaultPadding
                trailingPadding = defaultPadding
            default: // center
                let verticalPadding = ((screenSize.height - bannerSize.height) / 2)
                let horizontalPadding = ((screenSize.width - bannerSize.width) / 2)
                
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
        private func calculateBannerEdgeInsets(screenSize: CGSize) -> EdgeInsets {
            let bannerSize = calculateBannerSize(screenSize: screenSize)
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
    }
}

