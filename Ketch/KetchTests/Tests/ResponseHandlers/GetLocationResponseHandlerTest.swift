//
//  GetLocationResponseHandlerTest.swift
//  KetchTests
//
//  Created by Aleksey Bodnya on 3/27/20.
//  Copyright © 2020 Switchbit. All rights reserved.
//

import XCTest

@testable import Ketch

class GetLocationResponseHandlerTest: XCTestCase {

    func testResultFields() {
        let request = GetLocationMockRequest()
        let handler = GetLocationResponseHandler()
        let task = NetworkTask(request: request, handler: handler)
        let expectation = self.expectation(description: "response")
        task.onResult = { result in
            guard let location = result.object else {
                XCTFail("Result is nil")
                expectation.fulfill()
                return
            }
            XCTAssertEqual(location.countryCode, "UA")
            XCTAssertEqual(location.regionCode, "30")
            expectation.fulfill()
        }
        task.schedule()
        wait(for: [expectation], timeout: 5.0)
    }

}
