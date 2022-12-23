//
//  EncoderError.swift
//  KetchSDK
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
