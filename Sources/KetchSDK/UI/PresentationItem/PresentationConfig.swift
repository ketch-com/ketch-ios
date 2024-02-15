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
    }
}

