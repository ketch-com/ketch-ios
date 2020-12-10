//
//  BootstrapConfiguration+Mock.swift
//  KetchTests
//
//  Created by Aleksey Bodnya on 4/3/20.
//  Copyright © 2020 Switchbit. All rights reserved.
//

import Foundation

@testable import Ketch

extension BootstrapConfiguration {

    static func mock() -> BootstrapConfiguration {
        let jsonString = GetBootstrapConfigurationMockRequest().json
        let data = jsonString.data(using: .utf8)!
        let object = try! JSONDecoder().decode(BootstrapConfiguration.self, from: data)
        return object
    }
}
