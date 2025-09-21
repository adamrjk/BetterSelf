//
//  FullScreenVideoPlayer.swift
//  BetterSelf
//
//  Created by Adam Damou on 18/08/2025.
//

import AVKit
import SwiftUI



struct CustomVideoPlayer: UIViewControllerRepresentable {
    let player: AVPlayer

    func makeUIViewController(context: Context) -> AVPlayerViewController {
        let controller = AVPlayerViewController()
        controller.player = player
        controller.videoGravity = .resizeAspectFill

        // Disable AirPlay
//        controller.allowsPictureInPicturePlayback = false
        // Hide AirPlay button
        controller.showsPlaybackControls = true
//        controller.contentOverlayView?.isHidden = false

        return controller

    }
    func updateUIViewController(_ uiViewController: AVPlayerViewController, context: Context) {}

}





struct FullScreenVideoPlayer: View {
    let videoURL: URL
    @Environment(\.dismiss) var dismiss
    @State private var player: AVPlayer?
    @State private var isLoading = true
    @State private var loadError = false




    var body: some View {
        GeometryReader { proxy in
            ZStack {
                Color.black.ignoresSafeArea()

                if isLoading {
                    // Loading indicator
                    VStack {
                        Text("Loading Video...")
                            .foregroundStyle(.white)
                            .font(.headline)
                            .padding(.top)
                        ProgressView()
                    }
                } else if loadError {
                    // Error state
                    VStack {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.largeTitle)
                            .foregroundColor(.red)
                        Text("Failed to load video")
                            .foregroundColor(.white)
                            .padding(.top)
                    }
                } else if let player = player {
                    // Video player
                    CustomVideoPlayer(player: player)
//                        .frame(maxWidth: .infinity, maxHeight: .infinity)
//                        .ignoresSafeArea()


                }
            }
            .ignoresSafeArea(.container, edges: .bottom)
            .onAppear {
                setupPlayer()
            }
            .onDisappear {
                cleanupPlayer()
            }
        }
    }

    private func setupPlayer() {
        Task {
            do {
                // Create asset asynchronously
                let asset = AVURLAsset(url: videoURL)

                // Wait for asset to be ready (this prevents main thread blocking)
                let isPlayable = try await asset.load(.isPlayable)

                if isPlayable {
                    // Create player on main thread
                    await MainActor.run {
                        self.player = AVPlayer(playerItem: AVPlayerItem(asset: asset))

                        self.isLoading = false

                        // Start playing
                        self.player?.play()

                    }
                }
            } catch {
                await MainActor.run {
                    self.loadError = true
                    self.isLoading = false
                }
                print("Failed to load video: \(error)")
            }
        }
    }

    private func cleanupPlayer() {
        player?.pause()
        player = nil
    }

}






#Preview {
    FullScreenVideoPlayer(videoURL: URL(string: Reminder.example.firebaseVideoURL!)! )
}

