//
//  NetworkTask+Mock.swift
//  KetchTests
//
//  Created by Aleksey Bodnya on 4/7/20.
//  Copyright © 2020 Switchbit. All rights reserved.
//

import Foundation

@testable import Ketch

extension NetworkTask {

    static func success<ResponseType: Codable, ResultType>(object: ResultType?) -> NetworkTask<ResponseType, ResultType> {
        return NetworkTaskSuccessMock(success: object)
    }
}

class NetworkTaskSuccessMock<ResponseType: Codable, ResultType>: NetworkTask<ResponseType, ResultType> {

    init(success: ResultType?) {
        self.success = success
        super.init(request: NetworkRequest())
    }

    let success: ResultType?

    override func schedule() {
        onResult?(.success(success))
        onComplete?()
    }
}
