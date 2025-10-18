//
//  AppIconView.swift
//  BetterSelf
//
//  Created by Adam Damou on 18/10/2025.
//

import SwiftUI

struct AppIconView: View {
    let appIcons = [("BetterSelf", "AlternateIconSet1"), ("Dark", "AlternateIconSet2")]

    @State private var currentAppIcon = ""
    var body: some View {


        List {

            ForEach(appIcons, id: \.0){ appIcon in

                Button{
                    currentAppIcon = appIcon.1
                    changeAppIcon(to: appIcon.1)

                } label: {

                    HStack {
                        Image(appIcon.1)
                            .resizable()
                            .cornerRadius(15)
                            .frame(width: 50, height: 50)
                            .scaledToFit()

                        Text(appIcon.0)
                            .foregroundStyle(.white)
                            .font(.headline)


                        Spacer()

                        if currentAppIcon == appIcon.1 {

                            Image(systemName: "checkmark.circle.fill")
                                .font(.headline)
                                .foregroundStyle(.green)
                                .padding()

                        }

                    }


                }






            }




        }
        .onAppear{
            if let icon = UserDefaults.standard.value(forKey: "CurrentAppIcon") as? String {
                currentAppIcon = icon
            }
            else {
                currentAppIcon = "AlternateIconSet1"
            }


        }
        .onChange(of: currentAppIcon){
            UserDefaults.standard.setValue(currentAppIcon, forKey: "CurrentAppIcon")
        }
        .navigationTitle("App Icon")
    }

    func changeAppIcon(to iconName: String?) {
        guard UIApplication.shared.supportsAlternateIcons else {
            print("Alternate icons are not supported.")
            return
        }

        UIApplication.shared.setAlternateIconName(iconName) { error in
            if let error = error {
                print("Failed to change app icon: \(error.localizedDescription)")
            } else {
                print("App icon changed successfully!")

            }
        }
    }
}

#Preview {
    AppIconView()
}
