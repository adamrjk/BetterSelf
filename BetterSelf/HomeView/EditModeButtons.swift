//
//  EditModeButtons.swift
//  BetterSelf
//
//  Created by Adam Damou on 20/11/2025.
//

import SwiftUI

struct EditModeButtons: View {
    @Environment(\.colorScheme) var scheme
    @Binding var deleteAlert: Bool
    let move: () -> Void
    var body: some View {
        VStack {
            Spacer()
            HStack {
                Button("Delete"){
                    AnalyticsService.log(AnalyticsService.EventName.buttonTapped, params: [
                        "button": "delete_overlay",
                        "view": "HomeView"
                    ])
                    deleteAlert.toggle()
                }
                .adaptiveGlass(scheme)
                .buttonStyle(.plain)
                Spacer()
                Button("Move"){
                    AnalyticsService.log(AnalyticsService.EventName.buttonTapped, params: [
                        "button": "move_overlay",
                        "view": "HomeView"
                    ])
                    move()
                }
                    .adaptiveGlass(scheme)
                    .buttonStyle(.plain)
            }
            .padding(.horizontal, 5)
        }
    }
}


