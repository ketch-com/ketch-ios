//
//  GetLocationValidationError.swift
//  Ketch
//
//  Created by Aleksey Bodnya on 3/27/20.
//  Copyright © 2020 Switchbit. All rights reserved.
//

import UIKit

/// Possible errors may occur during creating `GetLocation` request
public enum GetLocationValidationError: ValidationError {

    /// astrolabe host missed in configuration or equal to nil
    case astrolabeHostNotSpecified

    /// astrolabe host value cannot be used to create an URL
    case astrolabeHostInvalid(_ host: String)

    /// The convenient method to get the reason why validation failed
    public var description: String {
        switch self {
        case .astrolabeHostNotSpecified:
            return "Astrolabe host is not specified."
        case .astrolabeHostInvalid(let host):
            return "Astrolabe host is invalid: \"\(host)\"."
        }
    }
}
