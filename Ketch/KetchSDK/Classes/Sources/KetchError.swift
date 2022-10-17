//
//  KetchError.swift
//  KetchSDK
//
//  Created by Anton Lyfar on 17.10.2022.
//

import Foundation

extension KetchSDK {
    public enum KetchError: Error {
        case responseError(message: String)
        case requestError
        case decodingError(message: String)
    }
}
