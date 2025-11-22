//
//  InstantInsightView.swift
//  BetterSelf
//
//  Created by Adam Damou on 20/08/2025.
//

import SwiftUI

struct InstantInsightView: View {
    @State var reminder: Reminder
    let isInFeed: Bool
    @Binding var currentIndex: Int
    var index: Int
    var shouldPlay: Bool { currentIndex == index}

    var body: some View {
        GeometryReader { proxy in
            if let firebaseURL = reminder.firebaseVideoURL, let url = URL(string: firebaseURL) {
                ZStack {

                    FullScreenVideoPlayer(videoURL: url, isFront: reminder.isFront, currentIndex: $currentIndex, index: index, isInFeed: isInFeed)
                        .ignoresSafeArea(.all, edges: .top)
//                        .scaledToFill()
                        .frame(width: proxy.size.width)
                }

            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .statusBarHidden()
    }
}

//#Preview {
//    InstantInsightView(reminder: .example)
//}



