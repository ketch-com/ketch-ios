//
//  PresentationItem+ViewController.swift
//  KetchSDK
//
//  Created by Anton Lyfar on 10.11.2022.
//

import UIKit
import SwiftUI

extension KetchUI.PresentationItem {
    public var viewController: UIViewController? {
        let vc = UIHostingController(rootView: content)
        vc.modalPresentationStyle = .overFullScreen

        return vc
    }
}
