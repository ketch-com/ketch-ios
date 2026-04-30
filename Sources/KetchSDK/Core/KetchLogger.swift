//
//  KetchLogger.swift
//  KetchSDK
//
//  Created by Roman Simenok on 31.01.2024.
//

import Foundation
import OSLog

struct KetchLogger {
    /// Fixed subsystem so host apps can filter simulator unified logs
    static let log = Logger(subsystem: "com.ketch.sdk", category: "KetchSDK")
}
