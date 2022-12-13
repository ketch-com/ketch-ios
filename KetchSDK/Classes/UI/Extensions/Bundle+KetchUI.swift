//
//  Bundle+KetchUI.swift
//  KetchSDK
//
//  Created by Anton Lyfar on 13.12.2022.
//

import Foundation

extension Bundle {
    static var ketchUI: Bundle? {
        guard let bundleURL = Bundle(for: KetchUI.self)
            .resourceURL?
            .appendingPathComponent("KetchUI.bundle")
        else { return nil }

        return Bundle(url: bundleURL)
    }
}
