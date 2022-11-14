//
//  ModalView.swift
//  KetchSDK
//
//  Created by Anton Lyfar on 10.11.2022.
//

import SwiftUI

struct ModalView: View {
    @Environment(\.presentationMode) private var presentationMode: Binding<PresentationMode>

    var body: some View {
        ZStack {
            VStack(alignment: .leading, spacing: 0) {
                    HStack {
                        Text("Privacy Center")
                            .font(.system(size: 20, weight: .heavy))
                        Spacer()
                        Button(action: { presentationMode.wrappedValue.dismiss() }) {
                            Text("X")
                        }
                    }
                    .padding(.horizontal, 18)
                    .padding(.vertical, 20)
                    .background(Color(.systemGray6))




                VStack(alignment: .leading, spacing: 16) {
                    Text("About Your Privacy")
                        .font(.system(size: 16, weight: .bold))

                    Text(
                        """
                        Axonic, Inc. determines the use of personal data collected on our media properties and across \
                        the internet. We may collect data that you submit to us directly or data that we collect \
                        automatically including from cookies (such as device information or IP address).
                        """
                    )
                    .font(.system(size: 14))
                    .padding(.bottom, 12)

                    ScrollView(showsIndicators: true) {

                    }
                }
                .padding(18)

                VStack(spacing: 24) {
                    Button(action: { presentationMode.wrappedValue.dismiss() }) {
                        Text("Close")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(height: 44)
                            .frame(maxWidth: .infinity)
                    }
                    .background(Color.blue.cornerRadius(5))

                    HStack {
                        Text("Powered by")
                        Spacer()
                    }
                }
                .padding(24)
                .background(Color(.systemGray6))
            }
        }
        
    }
}
