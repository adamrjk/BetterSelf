//
//  FullScreenVideoPlayer.swift
//  BetterSelf
//
//  Created by Adam Damou on 18/08/2025.
//

import AVKit
import SwiftUI

struct FullScreenVideoPlayer: View {
    let videoURL: URL
    @Environment(\.dismiss) var dismiss
    @State private var player: AVPlayer?

    var body: some View {
        GeometryReader { proxy in
            ZStack {
                Color.black.ignoresSafeArea()

                // Video player
                if let player = player {
                    VideoPlayer(player: player)
                        .clipped()



                }


            }
            .onAppear {
                setupPlayer()
            }
            .onDisappear {
                cleanupPlayer()
            }
        }
    }

    private func setupPlayer() {
        player = AVPlayer(url: videoURL)
    }

    private func cleanupPlayer() {
        player?.pause()
        player = nil
    }
}
#Preview {
    FullScreenVideoPlayer(videoURL: URL(string: Reminder.example.firebaseVideoURL!)! )
}
