//
//  ThemeView.swift
//  BetterSelf
//
//  Created by Adam Damou on 18/10/2025.
//

import SwiftUI

struct ThemeView: View {

    @State private var selectedTheme: Theme = .yellowPurple
    @State private var autoDarkMode = true
    var body: some View {
        List {


            Toggle("Auto Dark Mode", isOn: $autoDarkMode)


            ForEach(Theme.allCases, id: \.self){ theme in

                Button{

                } label: {
//                    Image(theme)
                    

                }















            }
        }
    }
}


enum Theme: String, Codable, CaseIterable {
    case yellowPurple = "Yellow & Purple"
    case blackWhite = "Black & White"

}

#Preview {
    ThemeView()
}
