//
//  GetFullConfigurationResponseHandlerTest.swift
//  KetchTests
//
//  Created by Aleksey Bodnya on 3/26/20.
//  Copyright © 2020 Switchbit. All rights reserved.
//

import XCTest

@testable import Ketch

class GetFullConfigurationResponseHandlerTest: XCTestCase {

    func testResultFields() {
        let request = GetFullConfigurationMockRequest()
        let handler = ResponseHandlerCopyObject<Configuration>()
        let task = NetworkTask(request: request, handler: handler)
        let expectation = self.expectation(description: "response")
        task.onResult = { result in
            guard let config = result.object else {
                XCTFail("Result is nil")
                expectation.fulfill()
                return
            }
            XCTAssertEqual(config.version, 1)
            XCTAssertEqual(config.language, "en-US")
            XCTAssertEqual(config.organization?.code, "habu")
            XCTAssertEqual(config.application?.code, "sublimedaily")
            XCTAssertEqual(config.application?.name, "Sublime Daily")
            XCTAssertEqual(config.application?.platform, "WEB")
            XCTAssertEqual(config.environments?.count, 2)
            XCTAssertEqual(config.environments?[0].code, "production")
            XCTAssertEqual(config.environments?[0].hash, "4290636013626569096")
            XCTAssertEqual(config.environments?[1].code, "staging")
            XCTAssertEqual(config.environment?.code, "production")
            XCTAssertEqual(config.environment?.hash, "4290636013626569096")
            XCTAssertEqual(config.identities?["habu_cookie"]?.type, "window")
            XCTAssertEqual(config.identities?["habu_cookie"]?.variable, "window.__Habu.huid")
            XCTAssertEqual(config.deployment?.code, "habu_dep")
            XCTAssertEqual(config.deployment?.version, 1)
            XCTAssertEqual(config.policyScope?.defaultScopeCode, "gdpr")
            XCTAssertEqual(config.policyScope?.code, "ccpa")
            XCTAssertEqual(config.privacyPolicy?.code, "habupp")
            XCTAssertEqual(config.privacyPolicy?.version, 1)
            XCTAssertEqual(config.privacyPolicy?.url, "https://habu.com/privacypolicy")
            XCTAssertEqual(config.termsOfService?.code, "habutou")
            XCTAssertEqual(config.termsOfService?.version, 1)
            XCTAssertEqual(config.termsOfService?.url, "https://habu.com/tou")
            XCTAssertEqual(config.rights?.count, 3)
            XCTAssertEqual(config.rights?[0].code, "portability")
            XCTAssertEqual(config.rights?[0].name, "Portability")
            XCTAssertEqual(config.rights?[0].description, "Right to have all data provided to you.")
            XCTAssertEqual(config.regulations, ["ccpa"])
            XCTAssertEqual(config.purposes?.count, 8)
            XCTAssertEqual(config.purposes?[0].code, "identity_management")
            XCTAssertEqual(config.purposes?[0].name, "User ID Linking")
            XCTAssertEqual(config.purposes?[0].description, "Data can be used to bridge commonality of audience traits at a granular level.")
            XCTAssertEqual(config.purposes?[0].legalBasisCode, "disclosure")
            XCTAssertEqual(config.purposes?[0].requiresPrivacyPolicy, true)
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
