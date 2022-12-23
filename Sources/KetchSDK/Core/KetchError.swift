//
//  KetchError.swift
//  KetchSDK
//

import Foundation

extension KetchSDK {
    public enum KetchError: Error {
        case responseError(message: String)
        case requestError
        case decodingError(message: String)
    }
}
