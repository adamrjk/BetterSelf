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
    @State private var isPlaying = false
    @State private var showControls = true
    @State private var progress: Double = 0
    @State private var duration: Double = 0
    @State private var currentTime: Double = 0

    var body: some View {
        GeometryReader { proxy in
            ZStack {
                // Purple background
                Color.purpleMainGradient
                    .ignoresSafeArea()

                Color.purpleOverlayGradient
                    .ignoresSafeArea()

                // Video player
                if let player = player {
                    VideoPlayer(player: player)
                        .scaledToFill()
                        .frame(width: proxy.size.width, height: proxy.size.height)
                        .clipped()
                        .onTapGesture {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                showControls.toggle()
                            }
                        }
                }

                // Overlay controls
                if showControls {
                    VStack {
                        // Top bar with close button
                        HStack {
                            Button {
                                dismiss()
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .font(.title)
                                    .foregroundColor(.white)
                                    .background(Color.black.opacity(0.3))
                                    .clipShape(Circle())
                            }

                            Spacer()
                        }
                        .padding()

                        Spacer()

                        // Center play/pause button
                        Button {
                            togglePlayPause()
                        } label: {
                            Image(systemName: isPlaying ? "pause.circle.fill" : "play.circle.fill")
                                .font(.system(size: 80))
                                .foregroundColor(.white)
                                .background(Color.black.opacity(0.3))
                                .clipShape(Circle())
                        }

                        Spacer()

                        // Bottom progress bar and controls
                        VStack(spacing: 16) {
                            // Progress bar
                            ProgressView(value: progress, total: 1.0)
                                .progressViewStyle(LinearProgressViewStyle(tint: .white))
                                .scaleEffect(y: 2)
                                .padding(.horizontal)

                            // Time and controls
                            HStack {
                                Text(formatTime(currentTime))
                                    .foregroundColor(.white)
                                    .font(.caption)
                                    .monospacedDigit()

                                Spacer()

                                // Skip backward
                                Button {
                                    skipBackward()
                                } label: {
                                    Image(systemName: "gobackward.15")
                                        .font(.title2)
                                        .foregroundColor(.white)
                                        .background(Color.black.opacity(0.3))
                                        .clipShape(Circle())
                                }

                                // Skip forward
                                Button {
                                    skipForward()
                                } label: {
                                    Image(systemName: "goforward.30")
                                        .font(.title2)
                                        .foregroundColor(.white)
                                        .background(Color.black.opacity(0.3))
                                        .clipShape(Circle())
                                }

                                Text(formatTime(duration))
                                    .foregroundColor(.white)
                                    .font(.caption)
                                    .monospacedDigit()
                            }
                            .padding(.horizontal)
                        }
                        .padding(.bottom, 50)
                    }
                    .background(
                        LinearGradient(
                            colors: [Color.black.opacity(0.6), Color.clear, Color.black.opacity(0.6)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                }
            }
        }
        .onAppear {
            setupPlayer()
        }
        .onDisappear {
            cleanupPlayer()
        }
    }

    private func setupPlayer() {
        player = AVPlayer(url: videoURL)

        // Get video duration
        let asset = AVURLAsset(url: videoURL)
        Task {
            do {
                let durationValue = try await asset.load(.duration)
                await MainActor.run {
                    duration = durationValue.seconds
                }
            } catch {
                print("Error loading duration: \(error)")
            }
        }

        // Add time observer
        let interval = CMTime(seconds: 0.1, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        player?.addPeriodicTimeObserver(forInterval: interval, queue: .main) { time in
            currentTime = time.seconds
            if duration > 0 {
                progress = currentTime / duration
            }
        }
    }

    private func togglePlayPause() {
        if isPlaying {
            player?.pause()
        } else {
            player?.play()
        }
        isPlaying.toggle()
    }

    private func skipForward() {
        let newTime = currentTime + 30
        let time = CMTime(seconds: min(newTime, duration), preferredTimescale: 1)
        player?.seek(to: time)
    }

    private func skipBackward() {
        let newTime = currentTime - 15
        let time = CMTime(seconds: max(newTime, 0), preferredTimescale: 1)
        player?.seek(to: time)
    }

    private func formatTime(_ time: Double) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }

    private func cleanupPlayer() {
        player?.pause()
        player = nil
    }
}
//#Preview {
//    FullScreenVideoPlayer(videoURL: <#T##URL#>)
//}
