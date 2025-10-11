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

                VStack(spacing: 16){

                    VStack(alignment: .leading, spacing: 12) {

                        CleanText("LightTheme")
                            .foregroundColor(.primary)
                        ScrollView(.horizontal){
                            Button{
                                print("Hello")
                            }label: {
                                Color.creamyYellow
                                    .frame(width: 30, height: 30)
                                    .clipShape(.circle)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(Color.primary.opacity(0.2), lineWidth: 1)
                                            .shadow(color: color.shadow(scheme).opacity(0.06), radius: 2, y: 1)
                                    )
                            }


                        }
                        .padding(12)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color(.systemGray6)) // Automatically adapts
                                .shadow(color: color.shadow(scheme).opacity(0.06), radius: 2, y: 1)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.primary.opacity(0.2), lineWidth: 1)
                        )
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(Color(.systemGray6))
                            .shadow(color: .black.opacity(0.08), radius: 8, y: 4)
                    )
                    .padding(.horizontal, 16)

                    Spacer()
                        .frame(maxHeight: 20)

                    HStack(spacing: 16 ) {
                        Toggle("Start Tutorial Again", isOn: $tutorial)
                            .tint(scheme == .light
                                  ? .purple
                                  : .yellow)
                            .foregroundStyle(.secondary)
                            .font(.subheadline)

                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(color.cardBackground(scheme))
                            .shadow(color: .black.opacity(0.08), radius: 8, y: 4)
                    )
                    .padding(.horizontal, 16)


                }
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
