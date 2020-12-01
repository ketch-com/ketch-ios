//
//  GetConsentStatusResponseHandlerTest.swift
//  KetchTests
//
//  Created by Aleksey Bodnya on 3/27/20.
//  Copyright © 2020 Switchbit. All rights reserved.
//

import XCTest

@testable import Ketch

class GetConsentStatusResponseHandlerTest: XCTestCase {

    func testResultFields() {
        let purposes = [
            "{purpose.1}": "disclosure",
            "{purpose.2}": "disclosure",
            "{purpose.3}": "consent_optout"
        ]
        let request = GetConsentStatusMockRequest()
        let handler = GetConsentStatusResponseHandler(purposes: purposes)
        let task = NetworkTask(request: request, handler: handler)
        let expectation = self.expectation(description: "response")
        task.onResult = { result in
            guard let response = result.object else {
                XCTFail("Result is nil")
                expectation.fulfill()
                return
            }
            XCTAssertEqual(response["{purpose.1}"], ConsentStatus(allowed: true, legalBasisCode: "disclosure"))
            XCTAssertEqual(response["{purpose.2}"], ConsentStatus(allowed: false, legalBasisCode: "disclosure"))
            XCTAssertEqual(response["{purpose.3}"], ConsentStatus(allowed: true, legalBasisCode: "consent_optout"))
            expectation.fulfill()

        }
        task.schedule()
        wait(for: [expectation], timeout: 5.0)
    }

}
