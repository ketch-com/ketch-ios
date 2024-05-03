//
//  Bundle+KetchUI.swift
//  KetchSDK
//

#if !os(macOS)

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
}

#endif
