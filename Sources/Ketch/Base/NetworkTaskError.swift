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
    case invalidStatusCode(_ code: Int) // TODO: drop

    /// The status code belongs to 5XX
    case serverNotReachable             // TODO: drop

    /// The request failed with some error
    case requestError(Error?)           // TODO: drop

    /// The provided data cannot be decoded
    case decodeError(Error?)            // TODO: drop

    /// The error occured during handling the response
    case handleError(Error?)            // TODO: drop

    /// The error occured during validating input parameters
    case validationError(error: ValidationError)

    /// Other error
    case other(Error)

    /// gRPC error with statuc code and message
    case grpc(statusCode: Int, message: String?)

    /// Unknown error
    case unknown                        // TODO: drop

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
        case .grpc(let code, let message):
            return "gRPC error. Status code: \(code), message: \(message ?? "nil")."
        case .other(let error):
            return error.localizedDescription
        default:
            return "Unknown error. Please try again."
        }
    }
}
