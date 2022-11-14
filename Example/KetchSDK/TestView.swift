//
//  TestView.swift
//  KetchSDK
//
//  Created by Anton Lyfar on 13.11.2022.
//

import SwiftUI

struct TestView: View {
    @State var showModal = false
    @State var showPopup = false

    var body: some View {
        ZStack {
            Color.white

            VStack(spacing: 40) {
                Button("ShowModal", action: { showModal = true })
                Button("ShowPopup", action: { showPopup = true })
            }

            Color.black
                .opacity(showModal ? 0.1 : 0)
                .onTapGesture { showModal = false; showPopup = false }
                .animation(.easeOut)

            VStack {
                Spacer()
                content
                    .animation(animation)
                    .offset(y: showModal ? 0 : UIScreen.main.bounds.height)
            }
            .ignoresSafeArea(edges: .bottom)

            content
                .frame(maxHeight: .infinity)
                .animation(animationModal)
                .offset(y: showPopup ? 0 : UIScreen.main.bounds.height)
                .padding(.horizontal, 10)
                .padding(.top, 60)
        }
        .ignoresSafeArea(.all)
    }

    @ViewBuilder
    private var content: some View {
        ZStack {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("Privacy Statement")
                        .font(.system(size: 20, weight: .heavy))
                    Spacer()
                    Button(action: { showModal = false; showPopup = false }) {
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

                // TODO: - REMOVE
                if showPopup { Spacer() }

                Button(action: { showModal = false; showPopup = false }) {
                    Text("Confirm")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(height: 44)
                        .frame(maxWidth: .infinity)
                }
                .background(Color.blue.cornerRadius(5))

                Button(action: { showModal = false; showPopup = false }) {
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
            .background(
                Color.white
                    .cornerRadius(8)
                    .shadow(color: .black.opacity(0.15), radius: 12, y: -4)
            )
            //          .padding()
            //          .layoutPriority(1)
            //          .frame(height: 200)
        }
    }

    private var animation: Animation {
        Animation
            .interpolatingSpring(mass: 0.7, stiffness: 300.0, damping: 30.0, initialVelocity: 10.0)
            .speed(5)
            .delay(0)
    }

    private var animationModal: Animation {
        Animation
            .interpolatingSpring(mass: 0.7, stiffness: 300.0, damping: 30.0, initialVelocity: 10.0)
            .speed(10)
            .delay(0)
    }
}


struct TestView_Previews: PreviewProvider {
    static var previews: some View {
        TestView()
//            .environmentObject(ModalManager())
    }
}
