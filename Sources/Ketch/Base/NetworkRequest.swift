//
//  Ketch.swift
//  Ketch
//
//  Created by Aleksey Bodnya on 3/25/20.
//  Copyright © 2020 Switchbit. All rights reserved.
//

import Foundation

// MARK: -

/// This base class is responsible to retrieve Data from some source
class NetworkRequest {

    typealias SuccessHandler = (_ data: Data) -> ()
    typealias ErrorHandler = (_ error: NetworkTaskError) -> ()

    /// Is called when the request is succeeded
    var onSuccess: SuccessHandler? = nil

    /// Is called when the request is failed
    var onError: ErrorHandler? = nil

    /// Indicated do we need to print debug info on each request
    var printDebugInfo = true

    /// Method to send request. Must be implemented in subclasses
    func send() {
        fatalError("not implemented")
    }
}

// MARK: -

/// This base class is responsible to retrieve Data from Network by sending GET/POST request via URLSession
class BaseRequest: NetworkRequest {

    // MARK: Init

    init(session: URLSession) {
        self.session = session
    }

    // MARK: Properties

    /// URLSession used to send request
    private let session: URLSession

    /// URLSessionDataTask which is scheduled via `session`
    private var task: URLSessionDataTask?

    // MARK: Methods

    /// This method creates request via `createRequest` method, creates associated `task` via `session` object and schedules the `task`.
    /// This method handles completion of `task`, handles status code of the request and calls `onSuccess` or `onError` handler depending on result
    override func send() {
        let request = createRequest()

        if printDebugInfo {
            print("🚹 \(type(of: self)) send request \(request.httpMethod ?? "") \(request.url?.absoluteString ?? "<NO URL>") with body \(String(data: request.httpBody ?? Data(), encoding: .utf8) ?? "<NO DATA>")")
        }
        task = session.dataTask(with: request, completionHandler: { [weak self] (data, response, error) in
            if let statusCode = (response as? HTTPURLResponse)?.statusCode {
                switch statusCode {
                case 300 ... 499:
                    self?.onError?(.invalidStatusCode(statusCode))
                case 500 ... 599:
                    self?.onError?(.serverNotReachable)
                default: break
                }
            }
            guard let data = data else {
                self?.onError?(.requestError(error))
                return
            }
            self?.onSuccess?(data)
        })
        task?.resume()
    }

    /// This method creates URLRequest. Must be overriden in subclasses
    func createRequest() -> URLRequest {
        fatalError("not implemented")
    }

    /// This convenient method is used to create request. You can call it in your `createRequest` overriden method.
    func request(_ url: URL, method: HTTPMethod = .get, body: [String: Any]? = nil) -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        baseHeaders().forEach { (key, value) in
            request.setValue(value, forHTTPHeaderField: key)
        }
        if let body = body, let data = try? JSONSerialization.data(withJSONObject: body) {
            request.httpBody = data
        }
        return request
    }

    /// This method defines base headers added to each request
    private func baseHeaders() -> [String: String] {
        return ["Content-Type": "application/json"]
    }
}

// MARK: - HTTPMethod

extension BaseRequest {

    /// Method of HTTP request: GET or POST
    enum HTTPMethod: String {
        case get = "GET"
        case post = "POST"
    }
}
