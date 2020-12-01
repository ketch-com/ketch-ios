//
//  URLSessionMock.swift
//  KetchTests
//
//  Created by Aleksey Bodnya on 4/3/20.
//  Copyright © 2020 Switchbit. All rights reserved.
//

import UIKit

class URLSessionMock: URLSession {

    override init() {
        super.init()
    }

    var mockedJSON: String?
    var mockedResponse: URLResponse?
    var mockedError: Error?
    private(set) var request: URLRequest?

    override func dataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
        self.request = request
        completionHandler(mockedJSON?.data(using: .utf8), mockedResponse, mockedError)
        return URLSessionDataTask()
    }
}
