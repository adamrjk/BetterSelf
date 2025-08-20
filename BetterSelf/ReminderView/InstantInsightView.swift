//
//  InstantInsightView.swift
//  BetterSelf
//
//  Created by Adam Damou on 20/08/2025.
//

import SwiftUI

struct InstantInsightView: View {
    @State var reminder: Reminder

    var body: some View {
        GeometryReader { proxy in
            if let firebaseURL = reminder.firebaseVideoURL, let url = URL(string: firebaseURL) {
                ZStack {

                    FullScreenVideoPlayer(videoURL: url)
                        .ignoresSafeArea(.all, edges: .top)
                        .scaledToFill()
                        .frame(width: proxy.size.width)
                }

            }
        }
        .navigationTitle("")
        .statusBarHidden()
    }
}

#Preview {
    InstantInsightView(reminder: .example)
}



