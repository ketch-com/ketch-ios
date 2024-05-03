//
//  KetchLogger.swift
//  KetchSDK
//
//  Created by Roman Simenok on 31.01.2024.
//

#if !os(macOS)

import Foundation
import OSLog

struct KetchLogger {
    static let log = Logger()
}

#endif
