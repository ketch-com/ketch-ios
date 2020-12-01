//
//  Ketch.swift
//  Ketch
//
//  Created by Aleksey Bodnya on 3/25/20.
//  Copyright © 2020 Switchbit. All rights reserved.
//

import UIKit

/// Protocol that describes any validation error
public protocol ValidationError: Error {

    /// The convenient method to get the reason why validation failed
    var description: String { get }
}

/// Describes any possible error that my occur with the network task
public enum NetworkTaskError: Error {

    /// The status code belongs to 3XX or 4XX
    case invalidStatusCode(_ code: Int)

    /// The status code belongs to 5XX
    case serverNotReachable

    /// The request failed with some error
    case requestError(Error?)

    /// The provided data cannot be decoded
    case decodeError(Error?)

    /// The error occured during handling the response
    case handleError(Error?)

    /// The error occured during validating input parameters
    case validationError(error: ValidationError)

    /// Unknown error
    case unknown

    public var description: String {
        switch self {
        case .invalidStatusCode(let code):
            return "Invalid status code \(code)."
        case .decodeError:
            return "Unexpected response format."
        case .requestError:
            return "Please check network connection."
        case .handleError:
            return "Cannot handle the response."
        case .validationError(let error):
            return error.description
        default:
            return "Unknown error. Please try again."
        }
    }
}
