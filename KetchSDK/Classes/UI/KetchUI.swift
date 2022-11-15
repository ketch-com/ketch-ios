//
//  KetchUI.swift
//  KetchSDK
//
//  Created by Anton Lyfar on 08.11.2022.
//

import SwiftUI
import Combine

public class KetchUI: ObservableObject {
    @Published public var presentationItem: PresentationItem?

    private var subscriptions = Set<AnyCancellable>()
    private var configuration: KetchSDK.Configuration?
    private var consentStatus: KetchSDK.ConsentStatus?

    public init(ketch: Ketch) {
        ketch.configurationPublisher
            .replaceError(with: nil)
            .sink { configuration in
                self.configuration = configuration
            }
            .store(in: &subscriptions)

        ketch.consentPublisher
            .replaceError(with: nil)
            .sink { consentStatus in
                self.consentStatus = consentStatus
            }
            .store(in: &subscriptions)
    }

    public func showBanner() {
        guard
            let configuration,
            let consentStatus,
            let banner = configuration.experiences?.consent?.banner
        else { return }

        presentationItem = PresentationItem(
            itemType: .banner(banner, config: configuration, consent: consentStatus)
        )
    }

    public func showModal() {
        presentationItem = PresentationItem(itemType: .modal)
    }

    public func showJIT() {
        presentationItem = PresentationItem(itemType: .jit)
    }

    public func showPreference() {
        presentationItem = PresentationItem(itemType: .preference)
    }
}
