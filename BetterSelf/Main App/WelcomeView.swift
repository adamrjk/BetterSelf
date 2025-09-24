//
//  WelcomeView.swift
//  BetterSelf
//
//  Created by Adam Damou on 24/09/2025.
//

import SwiftUI

struct WelcomeView: View {
    @Environment(\.colorScheme) var scheme
    @StateObject var color = ColorManager.shared
    var body: some View {
        NavigationStack{
            ZStack {
                color.mainGradient(scheme)
                    .ignoresSafeArea()
                color.overlayGradient(scheme)
                VStack{

                }
            }
            .navigationTitle("Welcome to Betterself")
        }
    }
}

#Preview {
    WelcomeView()
}
