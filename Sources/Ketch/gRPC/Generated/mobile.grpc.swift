//
// DO NOT EDIT.
//
// Generated by the protocol buffer compiler.
// Source: mobile.proto
//

//
// Copyright 2018, gRPC Authors All rights reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
import GRPC
import NIO
import SwiftProtobuf


/// Usage: instantiate Mobile_MobileClient, then call methods of this protocol to make API calls.
internal protocol Mobile_MobileClientProtocol: GRPCClient {
  func getConfiguration(
    _ request: Mobile_GetConfigurationRequest,
    callOptions: CallOptions?
  ) -> UnaryCall<Mobile_GetConfigurationRequest, Mobile_GetConfigurationResponse>

  func getConsent(
    _ request: Mobile_GetConsentRequest,
    callOptions: CallOptions?
  ) -> UnaryCall<Mobile_GetConsentRequest, Mobile_GetConsentResponse>

  func setConsent(
    _ request: Mobile_SetConsentRequest,
    callOptions: CallOptions?
  ) -> UnaryCall<Mobile_SetConsentRequest, Mobile_SetConsentResponse>

  func invokeRight(
    _ request: Mobile_InvokeRightRequest,
    callOptions: CallOptions?
  ) -> UnaryCall<Mobile_InvokeRightRequest, Mobile_InvokeRightResponse>

}

extension Mobile_MobileClientProtocol {

  /// Supercargo + Astrolabe
  ///
  /// - Parameters:
  ///   - request: Request to send to GetConfiguration.
  ///   - callOptions: Call options.
  /// - Returns: A `UnaryCall` with futures for the metadata, status and response.
  internal func getConfiguration(
    _ request: Mobile_GetConfigurationRequest,
    callOptions: CallOptions? = nil
  ) -> UnaryCall<Mobile_GetConfigurationRequest, Mobile_GetConfigurationResponse> {
    return self.makeUnaryCall(
      path: "/mobile.Mobile/GetConfiguration",
      request: request,
      callOptions: callOptions ?? self.defaultCallOptions
    )
  }

  /// Wheelhouse + Transponder
  ///
  /// - Parameters:
  ///   - request: Request to send to GetConsent.
  ///   - callOptions: Call options.
  /// - Returns: A `UnaryCall` with futures for the metadata, status and response.
  internal func getConsent(
    _ request: Mobile_GetConsentRequest,
    callOptions: CallOptions? = nil
  ) -> UnaryCall<Mobile_GetConsentRequest, Mobile_GetConsentResponse> {
    return self.makeUnaryCall(
      path: "/mobile.Mobile/GetConsent",
      request: request,
      callOptions: callOptions ?? self.defaultCallOptions
    )
  }

  /// Unary call to SetConsent
  ///
  /// - Parameters:
  ///   - request: Request to send to SetConsent.
  ///   - callOptions: Call options.
  /// - Returns: A `UnaryCall` with futures for the metadata, status and response.
  internal func setConsent(
    _ request: Mobile_SetConsentRequest,
    callOptions: CallOptions? = nil
  ) -> UnaryCall<Mobile_SetConsentRequest, Mobile_SetConsentResponse> {
    return self.makeUnaryCall(
      path: "/mobile.Mobile/SetConsent",
      request: request,
      callOptions: callOptions ?? self.defaultCallOptions
    )
  }

  /// InvokeRight is used to invoke a right for a data subject
  ///
  /// - Parameters:
  ///   - request: Request to send to InvokeRight.
  ///   - callOptions: Call options.
  /// - Returns: A `UnaryCall` with futures for the metadata, status and response.
  internal func invokeRight(
    _ request: Mobile_InvokeRightRequest,
    callOptions: CallOptions? = nil
  ) -> UnaryCall<Mobile_InvokeRightRequest, Mobile_InvokeRightResponse> {
    return self.makeUnaryCall(
      path: "/mobile.Mobile/InvokeRight",
      request: request,
      callOptions: callOptions ?? self.defaultCallOptions
    )
  }
}

internal final class Mobile_MobileClient: Mobile_MobileClientProtocol {
  internal let channel: GRPCChannel
  internal var defaultCallOptions: CallOptions

  /// Creates a client for the mobile.Mobile service.
  ///
  /// - Parameters:
  ///   - channel: `GRPCChannel` to the service host.
  ///   - defaultCallOptions: Options to use for each service call if the user doesn't provide them.
  internal init(channel: GRPCChannel, defaultCallOptions: CallOptions = CallOptions()) {
    self.channel = channel
    self.defaultCallOptions = defaultCallOptions
  }
}

/// To build a server, implement a class that conforms to this protocol.
internal protocol Mobile_MobileProvider: CallHandlerProvider {
  /// Supercargo + Astrolabe
  func getConfiguration(request: Mobile_GetConfigurationRequest, context: StatusOnlyCallContext) -> EventLoopFuture<Mobile_GetConfigurationResponse>
  /// Wheelhouse + Transponder
  func getConsent(request: Mobile_GetConsentRequest, context: StatusOnlyCallContext) -> EventLoopFuture<Mobile_GetConsentResponse>
  func setConsent(request: Mobile_SetConsentRequest, context: StatusOnlyCallContext) -> EventLoopFuture<Mobile_SetConsentResponse>
  /// InvokeRight is used to invoke a right for a data subject
  func invokeRight(request: Mobile_InvokeRightRequest, context: StatusOnlyCallContext) -> EventLoopFuture<Mobile_InvokeRightResponse>
}

extension Mobile_MobileProvider {
  internal var serviceName: Substring { return "mobile.Mobile" }

  /// Determines, calls and returns the appropriate request handler, depending on the request's method.
  /// Returns nil for methods not handled by this service.
  internal func handleMethod(_ methodName: Substring, callHandlerContext: CallHandlerContext) -> GRPCCallHandler? {
    switch methodName {
    case "GetConfiguration":
      return CallHandlerFactory.makeUnary(callHandlerContext: callHandlerContext) { context in
        return { request in
          self.getConfiguration(request: request, context: context)
        }
      }

    case "GetConsent":
      return CallHandlerFactory.makeUnary(callHandlerContext: callHandlerContext) { context in
        return { request in
          self.getConsent(request: request, context: context)
        }
      }

    case "SetConsent":
      return CallHandlerFactory.makeUnary(callHandlerContext: callHandlerContext) { context in
        return { request in
          self.setConsent(request: request, context: context)
        }
      }

    case "InvokeRight":
      return CallHandlerFactory.makeUnary(callHandlerContext: callHandlerContext) { context in
        return { request in
          self.invokeRight(request: request, context: context)
        }
      }

    default: return nil
    }
  }
}

