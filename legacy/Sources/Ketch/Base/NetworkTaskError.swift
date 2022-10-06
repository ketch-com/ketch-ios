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

    /// The error occured during validating input parameters
    case validationError(error: ValidationError)

    /// Other error
    case other(Error)

    /// gRPC error with statuc code and message
    case grpc(statusCode: Int, message: String?)

    public var description: String {
        switch self {
        case .validationError(let error):
            return error.description
        case .grpc(let code, let message):
            return "gRPC error. Status code: \(code), message: \(message ?? "nil")."
        case .other(let error):
            return error.localizedDescription
        }
    }
}
