//
//  Ketch.swift
//  Ketch
//
//  Created by Aleksey Bodnya on 3/25/20.
//  Copyright © 2020 Switchbit. All rights reserved.
//

import UIKit

/// The base class that is reponsible of handling the `response` and provide the result in `SuccessHandler` or error in `ErrorHandler`
class ResponseHandler<ResponseType: Codable, ResultType> {

    typealias SuccessHandler = (_ result: ResultType) -> ()
    typealias ErrorHandler = (_ error: Error) -> ()

    /// This method must be overriden in subclasses
    func handle(response: ResponseType, onSuccess: @escaping SuccessHandler, onError: @escaping ErrorHandler) {
        fatalError("not implemented")
    }
}

/// The class passes the input response in the `SuccessHandler` immediately
final class ResponseHandlerCopyObject<T: Codable>: ResponseHandler<T, T> {

    /// This method passes the input response in the `SuccessHandler` immediately
    override func handle(response: T, onSuccess: @escaping SuccessHandler, onError: @escaping ErrorHandler) {
        onSuccess(response)
    }
}
