//
//  Configuration+Mock.swift
//  KetchTests
//
//  Created by Aleksey Bodnya on 4/3/20.
//  Copyright © 2020 Switchbit. All rights reserved.
//

import Foundation

@testable import Ketch

extension Configuration {

    static func mock() -> Configuration {
        let jsonString = GetFullConfigurationMockRequest().json
        let data = jsonString.data(using: .utf8)!
        let object = try! JSONDecoder().decode(Configuration.self, from: data)
        return object
    }
}
