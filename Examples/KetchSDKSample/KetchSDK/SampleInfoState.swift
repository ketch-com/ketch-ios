//
//  SampleInfoState.swift
//  KetchSDK
//

import Foundation

/// Live values shown in the read-only Info panel. Seeded from `SampleConfig` and updated
/// by the jurisdiction/region SDK callbacks.
@MainActor
final class SampleInfoState: ObservableObject {
    @Published var jurisdiction: String
    @Published var region: String

    init(jurisdiction: String, region: String) {
        self.jurisdiction = jurisdiction
        self.region = region
    }
}
