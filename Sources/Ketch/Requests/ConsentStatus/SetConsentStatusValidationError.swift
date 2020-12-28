//
//  SetConsentStatusValidationError.swift
//  Ketch
//
//  Created by Aleksey Bodnya on 3/27/20.
//  Copyright © 2020 Switchbit. All rights reserved.
//

import Foundation

/// Possible errors may occur during creating `SetConsentStatus` request
public enum SetConsentStatusValidationError: ValidationError {

    /// wheelhouse host missed in configuration or equal to nil
    case wheelhouseHostNotSpecified

    /// wheelhouse host value cannot be used to create an URL
    case wheelhouseHostInvalid(_ host: String)

    /// `Environment code` is not specified in the provided config
    case environmentCodeNotSpecified

    /// Policy Scope code is missed in the provided config
    case policyScopeCodeNotSpecified

    /// Provided empty identities map.
    case noIdentities

    /// Provided empty consents map.
    case noConsents

    /// Processing Activity is not found in provided config.
    case purposeIsNotFoundInConfig(_ code: String)

    /// Organization code is missing in the provided config
    case organizationCodeNotSpecified

    /// The convenient method to get the reason why validation failed
    public var description: String {
        switch self {
        case .wheelhouseHostInvalid(let host):
            return "Wheelhouse host is invalid: \"\(host)\"."
        case .wheelhouseHostNotSpecified:
            return "Wheelhouse host is not specified."
        case .environmentCodeNotSpecified:
            return "Environment code is missed in the provided config."
        case .policyScopeCodeNotSpecified:
            return "Policy Scope code is missed in the provided config."
        case .noIdentities:
            return "You must provide non-empty identities map."
        case .noConsents:
            return "You must provide non-empty consents map."
        case .purposeIsNotFoundInConfig(let code):
            return "Processing Activity \"\(code)\" is not found in provided config."
        case .organizationCodeNotSpecified:
            return "Organization code is missing in the provided config."
        }
    }
}
