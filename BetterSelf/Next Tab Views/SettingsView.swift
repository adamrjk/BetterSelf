//
//  SettingsView.swift
//  BetterSelf
//
//  Created by Adam Damou on 15/08/2025.
//

import SwiftUI

struct SettingsView: View {

    @StateObject var color = ColorManager.shared
    @Environment(\.colorScheme) var scheme

    @State private var tutorial = false
    var body: some View {
        NavigationStack {
            ZStack {
                color.mainGradient(scheme)
                    .ignoresSafeArea()
                color.overlayGradient(scheme)
                    .ignoresSafeArea()
                ScrollView {
                    VStack(spacing: 16){

                        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)

                        Toggle("Start Tutorial Again", isOn: $tutorial)




                    }

                }
                .defaultScrollAnchor(.center)




            }
            .navigationTitle("Settings")
            .onChange(of: tutorial, launchTutorial)
        }



    }
    func launchTutorial(){
        if tutorial {
            UserDefaults().set(false, forKey: "Tutorial 1.3")
            TutorialManager.shared.folderViewStep = 3
        }




    }
}

#Preview {
    SettingsView()
}
