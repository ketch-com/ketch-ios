//
//  SampleLogging.swift
//  KetchSDK
//

import Foundation
import KetchSDK

enum SampleLogging {
    static let attLastStatusKey = "ketch_att_last"

    static func storedAttPrev() -> String {
        UserDefaults.standard.string(forKey: attLastStatusKey) ?? "notDetermined"
    }

    static func formatAttState(current: String, previous: String) -> String {
        "ketch_att=\(current) ketch_att_prev=\(previous)"
    }

    static func formatConsent(_ consent: KetchSDK.ConsentStatus) -> String {
        var parts: [String] = []

        if let purposes = consent.purposes {
            let allowed = purposes.filter(\.value).map(\.key).sorted()
            let denied = purposes.filter { !$0.value }.map(\.key).sorted()
            parts.append(
                "purposes(\(purposes.count)) allowed=[\(allowed.joined(separator: ","))] denied=[\(denied.joined(separator: ","))]"
            )
        } else {
            parts.append("purposes=nil")
        }

        if let vendors = consent.vendors {
            parts.append("vendors(\(vendors.count))=[\(vendors.sorted().joined(separator: ","))]")
        }

        if let protocols = consent.protocols, !protocols.isEmpty {
            let protocolSummary = protocols
                .sorted(by: { $0.key < $1.key })
                .map { "\($0.key)=\($0.value)" }
                .joined(separator: ", ")
            parts.append("protocols={\(protocolSummary)}")
        }

        return parts.joined(separator: "; ")
    }
}
