//
//  GetBootstrapConfigurationResponseHandlerTest.swift
//  KetchTests
//
//  Created by Aleksey Bodnya on 3/26/20.
//  Copyright © 2020 Switchbit. All rights reserved.
//

import XCTest

@testable import Ketch

class GetBootstrapConfigurationResponseHandlerTest: XCTestCase {

    func testResultFields() {
        let request = GetBootstrapConfigurationMockRequest()
        let handler = ResponseHandlerCopyObject<BootstrapConfiguration>()
        let task = NetworkTask(request: request, handler: handler)
        let expectation = self.expectation(description: "response")
        task.onResult = { result in
            guard let config = result.object else {
                XCTFail("Result is nil")
                expectation.fulfill()
                return
            }
            XCTAssertEqual(config.version, 1)
            XCTAssertEqual(config.organization?.code, "habu")
            XCTAssertEqual(config.application?.code, "sublimedaily")
            XCTAssertEqual(config.application?.name, "Sublime Daily")
            XCTAssertEqual(config.application?.platform, "WEB")
            XCTAssertEqual(config.environments?.count, 2)
            XCTAssertEqual(config.environments?[0].code, "production")
            XCTAssertEqual(config.environments?[0].pattern, "Ly9zdWJsaW1lZGFpbHkuY29t")
            XCTAssertEqual(config.environments?[0].hash, "4290636013626569096")
            XCTAssertEqual(config.environments?[1].code, "staging")
            XCTAssertEqual(config.environments?[1].pattern, "Ly9zdGFnZS5zdWJsaW1lZGFpbHkuY29t")
            XCTAssertEqual(config.environments?[1].hash, "5372302035981843260")
            XCTAssertEqual(config.policyScope?.defaultScopeCode, "gdpr")
            XCTAssertEqual(config.policyScope?.scopes?["GB"], "gdpr")
            XCTAssertEqual(config.policyScope?.scopes?["US-CA"], "ccpa")
            XCTAssertEqual(config.policyScope?.scopes?["US-GA"], "us_standard")
            XCTAssertEqual(config.policyScope?.scopes?["YT"], "gdpr")
            XCTAssertEqual(config.identities?["habu_cookie"]?.type, "window")
            XCTAssertEqual(config.identities?["habu_cookie"]?.variable, "window.__Habu.huid")
            XCTAssertEqual(config.scripts, ["https://cdn.b10s.io/transom/route/switchbit/semaphore/habu/semaphore.js"])
            XCTAssertEqual(config.services?.astrolabe, "https://cdn.b10s.io/astrolabe/")
            XCTAssertEqual(config.services?.gangplank, "https://cdn.b10s.io/gangplank/")
            XCTAssertEqual(config.services?.halyard, "https://cdn.b10s.io/transom/route/switchbit/halyard/habu/bundle.min.js")
            XCTAssertEqual(config.services?.supercargo, "https://cdn.b10s.io/supercargo/config/1/")
            XCTAssertEqual(config.services?.wheelhouse, "https://cdn.b10s.io/wheelhouse/")
            XCTAssertEqual(config.options?.localStorage, 1)
            XCTAssertEqual(config.options?.migration, 1)
            expectation.fulfill()

        }
        task.schedule()
        wait(for: [expectation], timeout: 5.0)
    }

}
