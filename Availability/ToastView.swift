//
//  ToastView.swift
//  Availability
//
//  Created by Praval Gautam on 07/08/24.
//

import SwiftUI

struct ToastView: View {
    var message: String
    var duration: TimeInterval
    @Binding var isPresented: Bool
    
    var body: some View {
        ZStack {
            if isPresented {
                VStack {
                    Spacer()
                    HStack {
                        Text(message)
                            .font(.callout)
                            .padding()
                            .background(Color.black)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                            .padding(.bottom, 20)
                        
                        Spacer()
                    }
                    .transition(.move(edge: .bottom))
                    .animation(.easeInOut(duration: 0.5), value: isPresented)
                }
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
                        withAnimation {
                            isPresented = false
                        }
                    }
                }
            }
        }
    }
}


