//
//  InMemoryCacheEngine.swift
//  KetchTests
//
//  Created by Aleksey Bodnya on 4/3/20.
//  Copyright © 2020 Switchbit. All rights reserved.
//

import Foundation

@testable import Ketch

class InMemoryCacheEngine: CacheEngine {

    var store = [String: Any]()

    func save<T>(key: String, object: T) where T: Codable {
        store[key] = object
    }

    func retrieve<T: Codable>(key: String) -> T? {
        if let object = store[key] {
            return object as? T
        }
        return nil
    }

}
