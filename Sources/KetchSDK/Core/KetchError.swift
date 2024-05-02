//
//  KetchError.swift
//  KetchSDK
//

#if !os(macOS)

import Foundation

extension KetchSDK {
    public enum KetchError: Error {
        case responseError(message: String)
        case requestError
        case decodingError(message: String)
    }
}

#endif
