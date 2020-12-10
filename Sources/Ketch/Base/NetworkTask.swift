//
//  Ketch.swift
//  Ketch
//
//  Created by Aleksey Bodnya on 3/25/20.
//  Copyright © 2020 Switchbit. All rights reserved.
//

import UIKit

/// This class encapsulate everything about one network operation. It includes:
/// 1. Sending network request via passed `request`.
/// 2. Parsing the response data into `Codable` object.
/// 3. Handling & converting the response object into result object via passed `handler`.
/// 4. Retrieve cache in case of failure by calling `cacheRetrieve` block.
/// 5. Persist cache in case of success by calling `cacheSave` block.
/// 6. Prints debug info if needed
/// It guarantees thread safety.
class NetworkTask<ResponseType: Codable, ResultType> {

    typealias CompleteHandler = () -> ()
    typealias ResultHandler = (_ result: NetworkTaskResult<ResultType>) -> ()
    typealias CacheRetrieve = () -> ResultType?
    typealias CacheSave = (ResultType) -> ()

    // MARK: Initializer

    init(request: NetworkRequest, handler: ResponseHandler<ResponseType, ResultType>? = nil, cacheRetrieve: CacheRetrieve? = nil, cacheSave: CacheSave? = nil) {
        self.request = request
        self.handler = handler
        self.cacheRetrieve = cacheRetrieve
        self.cacheSave = cacheSave

        self.request.printDebugInfo = printDebugInfo
        self.request.onSuccess = { [weak self] data in
            guard let self = self else {
                return
            }
            let called = self.checkCalledQueue.sync { [weak self] in
                return self?.onResultCalled ?? true
            }
            guard !called else {
                return
            }
            self.checkCalledQueue.sync { [weak self] in
                return self?.onResultCalled = true
            }
            if self.printDebugInfo {
                if let object = try? JSONSerialization.jsonObject(with: data, options: .init()), let prettyPrintedData = try? JSONSerialization.data(withJSONObject: object, options: .prettyPrinted), let jsonString = String(data: prettyPrintedData, encoding: .utf8) {
                    print("✅ \(type(of: request)) JSON response: \(jsonString)")
                } else if let string = String(data: data, encoding: .utf8) {
                    print("🛂 \(type(of: request)) RAW response: \(string)")
                } else {
                    print("🛂 \(type(of: request)) DATA response length: \(data.count)")
                }
            }
            let response: ResponseType
            do {
                let decoder = JSONDecoder()
                response = try decoder.decode(ResponseType.self, from: data)
            } catch {
                self.failed(with: .decodeError(error))
                return
            }
            if let handler = self.handler {
                handler.handle(response: response, onSuccess: { (result) in
                    self.succeded(with: result)
                }, onError: { (error) in
                    self.failed(with: .handleError(error))
                })
            } else {
                self.succeded(with: nil)
            }
        }

        self.request.onError = { [weak self] error in
            guard let self = self else {
                return
            }
            let called = self.checkCalledQueue.sync { [weak self] in
                return self?.onResultCalled ?? true
            }
            guard !called else {
                return
            }
            self.checkCalledQueue.sync { [weak self] in
                return self?.onResultCalled = true
            }
            self.failed(with: error)
        }
    }

    // MARK: Public API

    /// Public convenient method to create task that immediately fails because of validation
    static func failed<ResponseType: Codable, ResultType>(error: ValidationError) -> NetworkTask<ResponseType, ResultType> {
        let task = NetworkTask<ResponseType, ResultType>(request: NetworkRequest())
        task.error = .validationError(error: error)
        task.validationFailedTask = true
        return task
    }

    /// Unique identifier of the task
    let identifier = UUID().uuidString

    /// Use it to handle success or failure
    var onResult: ResultHandler? = nil

    /// Called when the task is completed
    var onComplete: CompleteHandler? = nil

    /// Property to print debug info
    var printDebugInfo = true {
        didSet {
            request.printDebugInfo = printDebugInfo
        }
    }

    /// Method to schedule the task if it was not scheduled yet
    func schedule() {
        let called = self.checkCalledQueue.sync { [weak self] in
            return self?.scheduleCalled ?? true
        }
        guard !called else {
            return
        }
        self.checkCalledQueue.sync { [weak self] in
            return self?.scheduleCalled = true
        }
        if validationFailedTask, let error = error {
            // If it is failed already
            onResult?(.failure(error))
            onComplete?()
            return
        }
        request.send()
    }

    // MARK: Private API

    /// The result of the task
    private(set) var result: ResultType?

    /// Called when the task is succeded
    private func succeded(with result: ResultType?) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else {
                return
            }
            self.result = result
            if let result = self.result {
                self.cacheSave?(result)
            }
            self.onResult?(.success(self.result))
            self.onComplete?()
        }
    }

    /// Bool flag indicates that this task is already failed because of validation
    private(set) var validationFailedTask = false

    /// Error that occurred when the task is failed
    private(set) var error: NetworkTaskError?

    /// Called when the task is failed
    private func failed(with error: NetworkTaskError) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else {
                return
            }
            if self.printDebugInfo {
                print("❌ \(type(of: self.request)) failed with error: \(error)")
            }
            self.error = error
            if let cache = self.cacheRetrieve?() {
                self.onResult?(.cache(cache))
            } else {
                self.onResult?(.failure(error))
            }
            self.onComplete?()
        }
    }

    /// The request that is sent
    private let request: NetworkRequest

    /// The handler for the response
    private let handler: ResponseHandler<ResponseType, ResultType>?

    /// The block for retrieving the cache
    private let cacheRetrieve: CacheRetrieve?

    /// The block for persisting the cache
    private let cacheSave: CacheSave?

    /// The property indicates that the result block is already called
    private var onResultCalled = false

    /// The queue for guaranteeing thread safety
    private lazy var checkCalledQueue = DispatchQueue(label: "NetworkTask-\(identifier)")

    /// The property indicates that the `schedule` method is already called
    private var scheduleCalled = false
}
