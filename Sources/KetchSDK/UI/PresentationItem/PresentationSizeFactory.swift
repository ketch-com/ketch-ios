//
//  PresentationSizeFactory.swift
//  KetchSDK
//
//  Created by Roman Simenok on 26.01.2024.
//

import UIKit

extension KetchUI {
    
    open class PresentationSizeFactory {
        var prefferedBannerSize: CGSize?
        
        public init() { }
        
        open func calculateModalSize(
            horizontalPosition: KetchUI.PresentationConfig.HPosition,
            verticalPosititon: KetchUI.PresentationConfig.VPosition,
            screenSize: CGSize
        ) -> CGSize {
            switch UIDevice.current.userInterfaceIdiom {
            case .pad:
                switch (horizontalPosition, verticalPosititon) {
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
        
        func calculateBannerSize(
            horizontalPosition: KetchUI.PresentationConfig.HPosition,
            verticalPosititon: KetchUI.PresentationConfig.VPosition,
            screenSize: CGSize
        ) -> CGSize {
            switch UIDevice.current.userInterfaceIdiom {
            case .pad:
                switch (verticalPosititon, horizontalPosition) {
                case (.bottom, .center), (.top, .center):
                    return CGSizeMake(screenSize.width, screenSize.height * 0.3)
                case (.center, .center):
                        return CGSizeMake(screenSize.width * 0.6, screenSize.height * 0.6)
                case (_ , .left), (_, .right):
                    return CGSizeMake(328, 415)
                }
            case .phone:
                return CGSizeMake(screenSize.width, screenSize.height * 0.75)
            default: // other devices not supported for now
                return .zero
            }
        }
    }
}
