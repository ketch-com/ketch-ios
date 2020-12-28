//
//  InvokeRightsValidationError.swift
//  Ketch
//
//  Created by Aleksey Bodnya on 3/27/20.
//  Copyright © 2020 Switchbit. All rights reserved.
//

import Foundation

/// Possible errors may occur during creating `InvokeRights` request
public enum InvokeRightsValidationError: ValidationError {

    /// `Environment code` is not specified in the provided config
    case environmentCodeNotSpecified

    /// Policy Scope code is missed in the provided config
    case policyScopeCodeNotSpecified

    /// Provided empty identities map.
    case noIdentities

    /// Right is not found in provided config.
    case rightIsNotFoundInConfig(_ code: String)

    /// Organization code is missing in the provided config
    case organizationCodeNotSpecified

    /// Application code is missing in the provided config
    case applicationCodeNotSpecified

    /// The convenient method to get the reason why validation failed
    public var description: String {
        switch self {
        case .environmentCodeNotSpecified:
            return "Environment code is missed in the provided config."
        case .policyScopeCodeNotSpecified:
            return "Policy Scope code is missed in the provided config."
        case .noIdentities:
            return "You must provide non-empty identities map."
        case .rightIsNotFoundInConfig(let code):
            return "Right \"\(code)\" is not found in provided config."
        case .organizationCodeNotSpecified:
            return "Organization code is missing in the provided config."
        case .applicationCodeNotSpecified:
            return "Application code is missing in the provided config"
        }
    }
}
