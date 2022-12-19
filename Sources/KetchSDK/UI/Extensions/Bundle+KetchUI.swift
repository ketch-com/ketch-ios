//
//  Bundle+KetchUI.swift
//  KetchSDK
//
//  Created by Anton Lyfar on 13.12.2022.
//

import Foundation

extension Bundle {
    static var ketchUI: Bundle? {
        #if SWIFT_PACKAGE
            return .module
        #else
            guard let bundleURL = Bundle(for: KetchUI.self)
                .resourceURL?
                .appendingPathComponent("KetchUI.bundle")
            else { return nil }

            return Bundle(url: bundleURL)
        #endif
    }
}
