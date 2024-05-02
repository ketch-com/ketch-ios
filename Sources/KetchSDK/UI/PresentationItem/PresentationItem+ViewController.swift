//
//  PresentationItem+ViewController.swift
//  KetchSDK
//
//  Created by Anton Lyfar on 10.11.2022.
//

#if !os(macOS)

// Check if UIKit is importable - makes our SDK more robust when imported into other Swift packages
#if canImport(UIKit)
import UIKit
#endif
import SwiftUI

extension KetchUI.WebPresentationItem {
    public var viewController: UIViewController {
        let vc = UIHostingController(rootView: content)
        vc.modalPresentationStyle = .overFullScreen

        return vc
    }
}

#endif
