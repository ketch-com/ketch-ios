//
//  NetworkTaskResult.swift
//  Ketch
//
//  Created by Aleksey Bodnya on 3/31/20.
//  Copyright © 2020 Switchbit. All rights reserved.
//

import Foundation

// MARK: -

/// The result of the network task
public enum NetworkTaskResult<ResultType> {

    /// The task succeeded with the result object
    case success(ResultType?)

    /// The task is failed because of network reason, but the object was retrieved from the cache
    case cache(ResultType?)

    /// The task is failed with some reason
    case failure(NetworkTaskError)
}

public extension NetworkTaskResult where ResultType == Void {
    static var success: NetworkTaskResult {
        return .success(())
    }
}

// MARK: -

extension NetworkTaskResult {

    /// - Returns: `true` if the task succeded or cache is used
    public var isSuccess: Bool {
        if case .failure = self {
            return false
        }
        return true
    }

    /// - Returns: the object if the task succeded or cache is used
    public var object: ResultType? {
        switch self {
        case .success(let object): return object
        case .cache(let object): return object
        case .failure: return nil
        }
    }

    /// - Returns: error if the task failed
    public var error: NetworkTaskError? {
        if case .failure(let error) = self {
            return error
        }
        return nil
    }
}

// MARK: -

extension NetworkTaskResult where ResultType == Void {

    /// Convenient method to convert `NetworkTaskResult<Void>` into `NetworkTaskVoidResult`
    func toVoidResult() -> NetworkTaskVoidResult {
        switch self {
        case .success, .cache: return .success
        case .failure(let error): return .failure(error)
        }
    }
}

// MARK: -

/// The result of the network task which does not contain any data
public enum NetworkTaskVoidResult {

    /// The task succeeded
    case success

    /// The task is failed with some reason
    case failure(NetworkTaskError)

    /// - Returns: `true` if the task succeded
    public var isSuccess: Bool {
        if case .success = self {
            return true
        }
        return false
    }

    /// - Returns: error if the task failed
    public var error: NetworkTaskError? {
        if case .failure(let error) = self {
            return error
        }
        return nil
    }
}
