//
//  BannerView.swift
//  KetchSDK
//
//  Created by Anton Lyfar on 10.11.2022.
//

import SwiftUI

struct BannerView: View {
    @Environment(\.presentationMode) private var presentationMode: Binding<PresentationMode>
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Privacy Statement")
                    .font(.system(size: 20, weight: .heavy))
                Spacer()
                Button(action: { presentationMode.wrappedValue.dismiss() }) {
                    Text("X")
                }
            }
            
            Text(
                """
                We and our partners are using technologies like Cookies or Targeting and process personal \
                data like IP-address or browser information in order to personalize the advertisement that \
                you see. You can always change/withdraw your consent. Our Privacy Policy.
                """
            )
            .font(.system(size: 14))
            .padding(.bottom, 12)
            
            Button(action: { presentationMode.wrappedValue.dismiss() }) {
                Text("Confirm")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(height: 44)
                    .frame(maxWidth: .infinity)
            }
            .background(Color.blue.cornerRadius(5))
            
            Button(action: { presentationMode.wrappedValue.dismiss() }) {
                Text("Customize Settings")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.blue)
                    .frame(height: 44)
                    .frame(maxWidth: .infinity)
                    .overlay(RoundedRectangle(cornerRadius: 5).stroke(.blue, lineWidth: 1))
            }
            .background(Color.white)
            .cornerRadius(5)
            
            HStack {
                Text("Powered by")
                Spacer()
            }
        }
        .padding(24)
    }
}
