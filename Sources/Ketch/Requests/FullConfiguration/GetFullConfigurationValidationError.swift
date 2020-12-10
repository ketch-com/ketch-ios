//
//  GetFullConfigurationValidationError.swift
//  Ketch
//
//  Created by Aleksey Bodnya on 3/26/20.
//  Copyright © 2020 Switchbit. All rights reserved.
//

import UIKit

/// Possible errors may occur during creating `GetFullConfiguration` request
public enum GetFullConfigurationValidationError: ValidationError {

    /// Retrieving location via `GetLocation` request or iOS API failed with error
    case cannotRetrieveLocation(_ underlineError: Error?)

    /// Environment with provided code is missed and the production environment is missed as well
    case cannotFindEnvironment(_ environemntCode: String)

    /// The selected `Environment` does not contain hash code
    case environmentMissedHash(_ environemntCode: String)

    /// supercargo host missed in configuration or equal to nil
    case supercargoHostInvalid(_ host: String)

    /// supercargo host value cannot be used to create an URL
    case supercargoHostNotSpecified

    /// The convenient method to get the reason why validation failed
    public var description: String {
        switch self {
        case .cannotRetrieveLocation(let error):
            if let error = error {
                return "Cannot retrieve location. Error: \(error)"
            } else {
                return "Cannot retrieve location"
            }
        case .supercargoHostInvalid(let host):
            return "Supercargo host is invalid: \"\(host)\"."
        case .supercargoHostNotSpecified:
            return "Supercargo host is not specified."
        case .cannotFindEnvironment(let environemntCode):
            return "Neither \"\(environemntCode)\" nor production environment is found in config."
        case .environmentMissedHash(let environemntCode):
            return "Environment \"\(environemntCode)\" does not have a hash code in config."
        }
    }
}
