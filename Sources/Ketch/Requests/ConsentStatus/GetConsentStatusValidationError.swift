//
//  GetConsentStatusValidationError.swift
//  Ketch
//
//  Created by Aleksey Bodnya on 3/27/20.
//  Copyright © 2020 Switchbit. All rights reserved.
//

import Foundation

/// Possible errors may occur during creating `GetConsentStatus` request
public enum GetConsentStatusValidationError: ValidationError {

    /// wheelhouse host missed in configuration or equal to nil
    case wheelhouseHostNotSpecified                                         // TODO: drop?

    /// wheelhouse host value cannot be used to create an URL
    case wheelhouseHostInvalid(_ host: String)                              // TODO: drop?

    /// `Environment code` is not specified in the provided config
    case environmentCodeNotSpecified

    /// Provided empty identities map.
    case noIdentities

    /// Provided empty purposes map.
    case noPurposes

    /// Processing Activity is not found in provided config.
    case purposeIsNotFoundInConfig(_ code: String)

    /// The convenient method to get the reason why validation failed
    public var description: String {
        switch self {
        case .wheelhouseHostNotSpecified:
            return "Wheelhouse host is not specified."
        case .wheelhouseHostInvalid(let host):
            return "Wheelhouse host is invalid: \"\(host)\"."
        case .environmentCodeNotSpecified:
            return "Environment code is missed in the provided config."
        case .noIdentities:
            return "You must provide non-empty identities map."
        case .noPurposes:
            return "You must provide non-empty purposes map."
        case .purposeIsNotFoundInConfig(let code):
            return "Processing Activity \"\(code)\" is not found in provided config."
        }
    }
}
