//
//  Bundle+KetchUI.swift
//  KetchSDK
//

import Foundation

extension Bundle {
    static var ketchUI: Bundle? {
        #if SWIFT_PACKAGE
            .module
        #else
            guard let bundleURL = Bundle(for: KetchUI.self)
                .resourceURL?
                .appendingPathComponent("KetchUI.bundle")
            else { return nil }

            return Bundle(url: bundleURL)
        #endif
    }
    
    static var ketchUIfiles: Bundle? {
        #if SWIFT_PACKAGE
            .module
        #else
            guard let bundleURL = Bundle(for: KetchUI.self).resourceURL
            else { return nil }

            return Bundle(url: bundleURL)
        #endif
    }
}
