//
//  KetchIntegrationApp.swift
//  KetchIntegrationTests
//
//  Created for Ketch iOS SDK Integration Tests
//

import SwiftUI
import KetchSDK

@main
struct KetchIntegrationApp: App {
    @StateObject private var viewModel = IntegrationViewModel()
    
    var body: some Scene {
        WindowGroup {
            ContentView(viewModel: viewModel)
                .onAppear {
                    // Initialize any app-wide settings or configurations here
                    viewModel.initialize()
                }
        }
    }
}
