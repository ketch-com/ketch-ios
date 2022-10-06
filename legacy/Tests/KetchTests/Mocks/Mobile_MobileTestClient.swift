//
//  Mobile_MobileTestClient.swift
//  KetchTests
//
//  Created by Igor Bogatchuk on 24.12.2020.
//  Copyright © 2020 Switchbit. All rights reserved.
//

import Foundation
import GRPC

@testable import Ketch

class Mobile_MobileTestClient: Mobile_MobileClientProtocol {
    private let fakeChannel: FakeChannel
    var defaultCallOptions: CallOptions

    var channel: GRPCChannel {
        return fakeChannel
    }

    init(fakeChannel: FakeChannel = FakeChannel(), defaultCallOptions callOptions: CallOptions = CallOptions()) {
        self.fakeChannel = fakeChannel
        self.defaultCallOptions = callOptions
    }

    /// Make a unary response for the Get RPC. This must be called
    /// before calling 'get'.
    /// - Parameter requestHandler: a handler for request parts sent by the RPC.
    func makeResponseStream<Request, Response>(path: String, requestHandler: @escaping (FakeRequestPart<Request>) -> () = { _ in } ) -> FakeUnaryResponse<Request, Response> {
        return fakeChannel.makeFakeUnaryResponse(path: path, requestHandler: requestHandler)
    }
}

extension Mobile_MobileTestClient {
    func makeGetConfigurationResponseStream() -> FakeUnaryResponse<Mobile_GetConfigurationRequest, Mobile_GetConfigurationResponse> {
        return makeResponseStream(path: "/mobile.Mobile/GetConfiguration") { (request: FakeRequestPart<Mobile_GetConfigurationRequest>) in }
    }

    func makeGetConsentResponseStream() -> FakeUnaryResponse<Mobile_GetConsentRequest, Mobile_GetConsentResponse> {
        return makeResponseStream(path: "/mobile.Mobile/GetConsent") { (request: FakeRequestPart<Mobile_GetConsentRequest>) in }
    }

    func makeSetConsentResponseStream() -> FakeUnaryResponse<Mobile_SetConsentRequest, Mobile_SetConsentResponse> {
        return makeResponseStream(path: "/mobile.Mobile/SetConsent") { (request: FakeRequestPart<Mobile_SetConsentRequest>) in }
    }

    func makeInvokeRightResponseStream() -> FakeUnaryResponse<Mobile_InvokeRightRequest, Mobile_InvokeRightResponse> {
        return makeResponseStream(path: "/mobile.Mobile/InvokeRight") { (request: FakeRequestPart<Mobile_InvokeRightRequest>) in }
    }
}
