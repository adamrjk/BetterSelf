//
//  SettingsView.swift
//  BetterSelf
//
//  Created by Adam Damou on 15/08/2025.
//

import SwiftUI

struct SettingsView: View {

    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var color: ColorManager
    @Environment(\.colorScheme) var scheme

    @State private var name = ""

    @State private var mode: AppearanceMode = .system

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
                        Spacer()
                            .frame(maxHeight: 20)


                        NavigationLink {
                            ThemeView()

                        } label: {
                            HStack {
                                Image(systemName: "paintpalette")
                                    .font(.title)
                                    .foregroundStyle(color.itemColor(scheme))
                                    .padding()
                                Text("Theme")
                                    .font(.headline)
                                Spacer()
                            }
                            .padding(.horizontal, 20)
                            //                            .padding(.vertical, 16)
                            .background(
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .fill(color.cardBackground(scheme))
                                    .shadow(color: .black.opacity(0.08), radius: 8, y: 4)
                            )
                        }
                        .buttonStyle(.plain)
                        .padding(.horizontal, 16)
                        .padding(.bottom)


                        NavigationLink {
                            AppIconView()

                        } label: {
                            HStack {
                                Image(systemName: "app.badge")
                                    .font(.title)
                                    .foregroundStyle(color.itemColor(scheme))
                                    .padding()
                                Text("App Icon")
                                    .font(.headline)
                                Spacer()
                            }
                            .padding(.horizontal, 20)
                            //                            .padding(.vertical, 16)
                            .background(
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .fill(color.cardBackground(scheme))
                                    .shadow(color: .black.opacity(0.08), radius: 8, y: 4)
                            )
                        }
                        .buttonStyle(.plain)
                        .padding(.horizontal, 16)
                        .padding(.bottom)




//                        HStack(spacing: 16 ) {
//                            Toggle("Start Tutorial Again", isOn: $tutorial)
//                                .tint(color.toggleColor(scheme)
//                                .foregroundStyle(.secondary)
//                                .font(.subheadline)
//
//                        }
//                        .padding(.horizontal, 20)
//                        .padding(.vertical, 16)
//                        .background(
//                            RoundedRectangle(cornerRadius: 16, style: .continuous)
//                                .fill(color.cardBackground(scheme))
//                                .shadow(color: .black.opacity(0.08), radius: 8, y: 4)
//                        )
//                        .padding(.horizontal, 16)

                    }
                }
                .defaultScrollAnchor(.center)
            }
            .onAppear{
                if let name = UserDefaults().value(forKey: "UserName") as? String{
                    self.name = name
                }
            }


            .navigationTitle("Settings")
            .onChange(of: tutorial, launchTutorial)
            .toolbar{
                ToolbarItem(placement: .topBarTrailing){
                    Button{
                        AnalyticsService.log(AnalyticsService.EventName.buttonTapped, params: [
                            "button": "settings_close",
                            "view": "SettingsView"
                        ])
                        dismiss()
                    }label: {
                        Image(systemName: "arrow.down")
                            .foregroundStyle(color.button(scheme))
                    }
                    .padding(8)
                    .buttonStyle(.plain)
                }
            }
        }



    }
    func launchTutorial(){
        if tutorial {
            if TutorialManager.shared.inTutorial {
                TutorialManager.shared.tutorialIsDone()
            }
            UserDefaults().set(false, forKey: "Tutorial \(NotificationManager.shared.version)")
            dismiss()
        }




    }
}

enum AppearanceMode: String, CaseIterable {
    case light = "Light"
    case dark = "Dark"
    case system = "System"

    var icon: String {
        switch self {
        case .light: return "sun.max.fill"
        case .dark: return "moon.fill"
        case .system: return "circle.lefthalf.filled"
        }
    }
}


struct AppearancePicker: View {
    @Binding var selectedMode: AppearanceMode
    @Environment(\.colorScheme) var scheme
    @EnvironmentObject var color: ColorManager


    var body: some View {
        VStack(spacing: 12) {
            CleanText("Appearance")

            HStack(spacing: 12) {
                ForEach(AppearanceMode.allCases, id: \.self) { mode in
                    Button {
                        selectedMode = mode
                    } label: {
                        VStack(spacing: 8) {
                            Image(systemName: mode.icon)
                                .font(.system(size: 28))
//                                .foregroundStyle(selectedMode == mode ? color.text(scheme) : .secondary)

                            Text(mode.rawValue)
                                .font(.subheadline)
                                .fontWeight(selectedMode == mode ? .semibold : .regular)
                                .foregroundStyle(selectedMode == mode ? .primary : .secondary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(selectedMode == mode ?
                                      Color.primary.opacity(scheme == .dark ? 0.15 : 0.08) :
                                      Color.primary.opacity(scheme == .dark ? 0.05 : 0.03))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(selectedMode == mode ?
                                        color.text(scheme) :
                                       Color.clear,
                                       lineWidth: 2)
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}

#Preview {
    SettingsView()
}



// MARK: - May be useful
//                    Text("Hey \(name)")
//                        .font(.headline)
//                        .padding()
//                        .frame(maxWidth: 320)
//                        .padding(.vertical, 16)
//                        .padding(.horizontal, 40)
//                        .background(
//                            RoundedRectangle(cornerRadius: 12)
//                                .fill(color.cardBackground(scheme))
//                                .shadow(color: color.shadow(scheme).opacity(0.06), radius: 2, y: 1)
//                        )
//                        .overlay(
//                            RoundedRectangle(cornerRadius: 12)
//                                .stroke(Color.primary.opacity(0.2), lineWidth: 1)
//                        )
//                        .padding(20)


//                    AppearancePicker(selectedMode: $mode)

//                    VStack(alignment: .leading, spacing: 12) {
//
//
//
//                        CleanText("LightTheme")
//                            .foregroundColor(.primary)
//                        ScrollView(.horizontal){
//                            Button{
//                                print("Hello")
//                            }label: {
//                                Color.creamyYellow
//                                    .frame(width: 30, height: 30)
//                                    .clipShape(.circle)
//                                    .overlay(
//                                        RoundedRectangle(cornerRadius: 12)
//                                            .stroke(Color.primary.opacity(0.2), lineWidth: 1)
//                                            .shadow(color: color.shadow(scheme).opacity(0.06), radius: 2, y: 1)
//                                    )
//                            }
//
//
//                        }
//                        .padding(12)
//                        .background(
//                            RoundedRectangle(cornerRadius: 12)
//                                .fill(color.cardBackground(scheme))
//                                .shadow(color: color.shadow(scheme).opacity(0.06), radius: 2, y: 1)
//                        )
//                        .overlay(
//                            RoundedRectangle(cornerRadius: 12)
//                                .stroke(Color.primary.opacity(0.2), lineWidth: 1)
//                        )
//                    }
//                    .padding(.horizontal, 20)
//                    .padding(.vertical, 16)
//                    .background(
//                        RoundedRectangle(cornerRadius: 16, style: .continuous)
//                            .fill(color.cardBackground(scheme))
//                            .shadow(color: .black.opacity(0.08), radius: 8, y: 4)
//                    )
//                    .padding(.horizontal, 16)
