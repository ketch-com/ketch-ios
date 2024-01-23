//
//  ContentView.swift
//  KetchSDK
//

import SwiftUI
import KetchSDK

struct ContentView: View {
    @ObservedObject var ketchUI: KetchUI
    
    init() {
        let ketch = KetchSDK.create(
            organizationCode: "bluebird",
            propertyCode: "mobile",
            environmentCode: "production",
            controllerCode: "my_controller",
            identities: [.idfa("00000000-0000-0000-0000-000000000000")] // or advertisingIdentifier.uuidString
        )
        
        ketchUI = KetchUI(
            ketch: ketch,
            experienceOptions: [
                .forceExperience(.cd)
            ]
        )
    }
    
    @State var lang = String()
    @State var jurisdiction = String()
    @State var region = String()
    
    var body: some View {
        VStack(alignment: .trailing, spacing: 40) {
            VStack(alignment: .leading, spacing: 5) {
                Text("Force language:")
                forceQueryTestView(title: "ketch_lang", value: $lang) {
                    ketchUI.reload(with: [.language(langId: lang.lowercased())])
                }
                Divider()
                Text("Force jurisdiction:")
                forceQueryTestView(title: "ketch_jurisdiction", value: $jurisdiction) {
                    ketchUI.reload(with: [.jurisdiction(code: jurisdiction.lowercased())])
                }
                Divider()
                Text("Force region:")
                forceQueryTestView(title: "ketch_region", value: $region) {
                    ketchUI.reload(with: [.region(region.lowercased())])
                }
            }
            
            Button("reload default Page") { ketchUI.reload() }
            
            HStack {
                Text("send js")
                VStack(alignment: .leading, spacing: 20) {
                    Button("showConsent") { ketchUI.showConsent() }
                    Button("showPreferences") { ketchUI.showPreferences() }
                    Button("getConfig") { ketchUI.getConfig() }
                }
                .padding()
                .border(.black)
            }
            
            HStack {
                Text("Test presentation")
                VStack(spacing: 40) {
                    HStack(spacing: 10) {
                        Button {
                            ketchUI.showExperience(presentationConfig: .init(vpos: .top, hpos: .left))
                        } label: { Image(systemName: "arrow.down.right.square") }
                        
                        Button {
                            ketchUI.showExperience(presentationConfig: .init(vpos: .top, hpos: .center))
                        } label: { Image(systemName: "arrow.down.square") }
                        
                        Button {
                            ketchUI.showExperience(presentationConfig: .init(vpos: .top, hpos: .right))
                        } label: { Image(systemName: "arrow.down.left.square") }
                    }
                    
                    Button {
                        ketchUI.showExperience(presentationConfig: .init(vpos: .center, hpos: .center))
                    } label: { Image(systemName: "square.on.square") }
                    
                    HStack(spacing: 10) {
                        Button {
                            ketchUI.showExperience(presentationConfig: .init(vpos: .bottom, hpos: .left))
                        } label: { Image(systemName: "arrow.up.right.square") }
                        
                        Button {
                            ketchUI.showExperience(presentationConfig: .init(vpos: .bottom, hpos: .center))
                        } label: { Image(systemName: "arrow.up.square") }
                        
                        
                        Button {
                            ketchUI.showExperience(presentationConfig: .init(vpos: .bottom, hpos: .right))
                        } label: { Image(systemName: "arrow.up.left.square") }
                    }
                }
                .padding()
                .border(.black)
            }
        }
        .padding()
        .onAppear {
            
        }
        .ketchView(model: $ketchUI.webPresentationItem)
    }
    
    @ViewBuilder func forceQueryTestView(
        title: String, value: Binding<String>, action: @escaping () -> Void
    ) -> some View {
        HStack(spacing: 5) {
            Text(title + "=")
            TextField("Value", text: value).frame(maxWidth: 50)
            Button("Reload", action: action)
                .opacity(value.wrappedValue.isEmpty ? 0 : 1)
                .frame(width: 50)
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    ContentView()
}
