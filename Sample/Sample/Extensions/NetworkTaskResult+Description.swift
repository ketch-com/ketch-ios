//
//  NetworkTaskResult+Description.swift
//  Sample
//
//  Created by Aleksey Bodnya on 4/6/20.
//  Copyright © 2020 Switchbit. All rights reserved.
//

import Foundation
import Ketch

extension NetworkTaskResult where ResultType: Codable {

    var description: String {
        let json = object
            .flatMap { try? JSONEncoder().encode($0) }
            .flatMap { try? JSONSerialization.jsonObject(with: $0, options: .init()) }
            .flatMap { try? JSONSerialization.data(withJSONObject: $0, options: .prettyPrinted) }
            .flatMap { String(data: $0, encoding: .utf8) }
            .flatMap { $0.replacingOccurrences(of: "\\/", with: "/")} ?? ""

        switch self {
        case .cache:
            return "Cache:\n\n\(json)"
        case .success:
            return "Success:\n\n\(json)"
        case .failure(let error):
            return "Failure:\n\n\(error.description)"
        }
    }
}

extension NetworkTaskResult where ResultType == Void {
    var description: String {
        switch self {
        case .success:
            return "Success:\n\n{}"
        case .failure(let error):
            return "Failure:\n\n\(error.description)"
        case .cache(_):
            return "Cache:\n\n{}"
        }
    }
}


extension NetworkTaskVoidResult {

    var description: String {
        switch self {
        case .success:
            return "Success:\n\n{}"
        case .failure(let error):
            return "Failure:\n\n\(error.description)"
        }
    }
}
