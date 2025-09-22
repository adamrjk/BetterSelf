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
    let isFront: Bool
    func makeUIViewController(context: Context) -> AVPlayerViewController {
        let controller = AVPlayerViewController()
        controller.player = player
        controller.videoGravity = .resizeAspectFill
        controller.showsPlaybackControls = true
        controller.allowsPictureInPicturePlayback = false

        // Apply 3D rotation only to the video content (not the controls)
        // Ensure subviews are laid out first
        if isFront {
            controller.view.setNeedsLayout()
            controller.view.layoutIfNeeded()

            DispatchQueue.main.async {
                if let videoView = findPlayerContentView(in: controller.view) {
                    var transform = CATransform3DIdentity
                    transform.m34 = -1.0 / 500.0 // perspective
                    transform = CATransform3DRotate(transform, .pi, 0, 1, 0) // 180 degrees around Y-axis
                    videoView.layer.transform = transform
                }
            }
        }

        return controller

    }
    func updateUIViewController(_ uiViewController: AVPlayerViewController, context: Context) {}

    private func findPlayerContentView(in root: UIView) -> UIView? {
        // Look for a view whose layer tree contains an AVPlayerLayer.
        if let sublayers = root.layer.sublayers, sublayers.contains(where: { $0 is AVPlayerLayer }) {
            return root
        }
        for subview in root.subviews {
            if let match = findPlayerContentView(in: subview) {
                return match
            }
        }
        return nil
    }
}





struct FullScreenVideoPlayer: View {
    let videoURL: URL
    let isFront: Bool
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
                    CustomVideoPlayer(player: player, isFront: isFront)

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






//#Preview {
//    FullScreenVideoPlayer(videoURL: URL(string: Reminder.example.firebaseVideoURL!)! )
//}

