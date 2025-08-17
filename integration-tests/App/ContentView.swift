//
//  ContentView.swift
//  KetchIntegrationTests
//
//  Created for Ketch iOS SDK Integration Tests
//

import SwiftUI
import KetchSDK

struct ContentView: View {
    @ObservedObject var viewModel: IntegrationViewModel
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Title
                Text("Ketch SDK Integration Tests")
                    .font(.title)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.bottom, 8)
                
                // Status Section
                Group {
                    Text("Status")
                        .font(.headline)
                        .padding(.bottom, 4)
                    
                    Text(viewModel.statusText)
                        .padding(8)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(4)
                        .accessibilityIdentifier("statusText")
                }
                
                // Actions Section
                Group {
                    Text("Actions")
                        .font(.headline)
                        .padding(.bottom, 4)
                    
                    Button("Load") {
                        viewModel.load()
                    }
                    .buttonStyle(PrimaryButtonStyle())
                    .accessibilityIdentifier("loadButton")
                    
                    Button("Show Consent") {
                        viewModel.showConsent()
                    }
                    .buttonStyle(PrimaryButtonStyle())
                    .accessibilityIdentifier("showConsentButton")
                    
                    Button("Show Preferences") {
                        viewModel.showPreferences()
                    }
                    .buttonStyle(PrimaryButtonStyle())
                    .accessibilityIdentifier("showPreferencesButton")
                    
                    Button("Set Language (EN)") {
                        viewModel.setLanguageEN()
                    }
                    .buttonStyle(PrimaryButtonStyle())
                    .accessibilityIdentifier("setLanguageButton")
                    
                    Button("Set Jurisdiction (US)") {
                        viewModel.setJurisdictionUS()
                    }
                    .buttonStyle(PrimaryButtonStyle())
                    .accessibilityIdentifier("setJurisdictionButton")
                    
                    Button("Set Region (California)") {
                        viewModel.setRegionCalifornia()
                    }
                    .buttonStyle(PrimaryButtonStyle())
                    .accessibilityIdentifier("setRegionButton")
                }
                
                // SDK State Section
                Group {
                    Text("SDK State")
                        .font(.headline)
                        .padding(.top, 8)
                        .padding(.bottom, 4)
                    
                    Text(viewModel.environmentText)
                        .padding(.vertical, 2)
                        .accessibilityIdentifier("environmentText")
                    
                    Text(viewModel.consentText)
                        .padding(.vertical, 2)
                        .accessibilityIdentifier("consentText")
                    
                    Text(viewModel.usPrivacyText)
                        .padding(.vertical, 2)
                        .accessibilityIdentifier("usPrivacyText")
                    
                    Text(viewModel.tcfText)
                        .padding(.vertical, 2)
                        .accessibilityIdentifier("tcfText")
                    
                    Text(viewModel.gppText)
                        .padding(.vertical, 2)
                        .accessibilityIdentifier("gppText")
                }
                
                // Test Actions Section
                Group {
                    Text("Test Actions")
                        .font(.headline)
                        .padding(.top, 8)
                        .padding(.bottom, 4)
                    
                    Button("Validate Consent Banner") {
                        viewModel.validateWebViewContent(expectedInnerElementId: "ketch-consent-banner")
                    }
                    .buttonStyle(TestButtonStyle())
                    .accessibilityIdentifier("testValidateConsentBanner")
                    
                    Button("Validate Preferences Center") {
                        viewModel.validateWebViewContent(expectedInnerElementId: "ketch-preferences")
                    }
                    .buttonStyle(TestButtonStyle())
                    .accessibilityIdentifier("testValidatePreferencesCenter")
                    
                    Button("Click Primary Button") {
                        viewModel.clickButtonById(buttonId: "ketch-banner-button-primary")
                    }
                    .buttonStyle(TestButtonStyle())
                    .accessibilityIdentifier("testClickPrimary")
                    
                    Button("Click Tertiary Button") {
                        viewModel.clickButtonById(buttonId: "ketch-banner-button-tertiary")
                    }
                    .buttonStyle(TestButtonStyle())
                    .accessibilityIdentifier("testClickTertiary")
                    
                    Button("Update Identities") {
                        viewModel.updateIdentitiesWithUniqueValue()
                    }
                    .buttonStyle(TestButtonStyle())
                    .accessibilityIdentifier("testUpdateIdentities")
                    
                    Text(viewModel.testResultText)
                        .padding(8)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(4)
                        .accessibilityIdentifier("testResultText")
                }
            }
            .padding()
        }
    }
}

// Custom button styles
struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .frame(maxWidth: .infinity)
            .background(configuration.isPressed ? Color.blue.opacity(0.8) : Color.blue)
            .foregroundColor(.white)
            .cornerRadius(8)
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
    }
}

struct TestButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .frame(maxWidth: .infinity)
            .background(configuration.isPressed ? Color.orange.opacity(0.8) : Color.orange)
            .foregroundColor(.white)
            .cornerRadius(8)
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(viewModel: IntegrationViewModel())
    }
}
