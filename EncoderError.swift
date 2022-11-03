//
//  EncoderError.swift
//  KetchSDK
//
//  Created by Anton Lyfar on 03.11.2022.
//

import Foundation

extension TCStringEncoderV2 {
    enum EncoderError: Error {
        case incompatibleVersion(Int)
        case invalidLanguageCode(String)
        case emptyValue(named: String)
        case noVendorsSelected
        case unsupportedSegment
    }
}
