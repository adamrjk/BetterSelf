//
//  FullScreenVideoPlayer.swift
//  BetterSelf
//
//  Created by Adam Damou on 18/08/2025.
//

import AVKit
import SwiftUI
import AVFoundation
import UIKit



struct CustomVideoPlayer: UIViewControllerRepresentable {
    let player: AVPlayer
    let isFront: Bool
    let bottomInset: CGFloat?
    let topInset: CGFloat?
    func makeUIViewController(context: Context) -> AVPlayerViewController {
        let controller = AVPlayerViewController()
        controller.player = player
        controller.videoGravity = .resizeAspectFill
        controller.showsPlaybackControls = false
        controller.allowsPictureInPicturePlayback = false
        if let bottomInset {
            controller.additionalSafeAreaInsets.bottom = bottomInset
        }
        if let topInset {
            controller.additionalSafeAreaInsets.top = topInset
        }
        player.allowsExternalPlayback = false

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

    @Environment(\.colorScheme) var scheme
    @EnvironmentObject var color: ColorManager

    @Binding var currentIndex: Int
    var index: Int
    var isInFeed: Bool = false

    var shouldPlay: Bool { currentIndex == index }
    @Environment(\.dismiss) var dismiss
    @State private var player: AVPlayer?
    @State private var isLoading = true
    @State private var loadError = false
    @State private var isPlaying = false
    @State private var isSeeking = false
    @State private var currentTime: Double = 0
    @State private var duration: Double = 0
    @State private var timeObserver: Any?

    private func configureAudioSession() {
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playback, mode: .moviePlayback, options: [])
            try session.setActive(true)
        } catch {
            print("Audio session setup error: \(error)")
        }
    }

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
                    CustomVideoPlayer(
                        player: player,
                        isFront: isFront,
                        bottomInset: isInFeed ? tabBarInset() : nil,
                        topInset: isInFeed ? topControlsInset() : nil
                    )

                    // Full-screen tap to toggle play/pause (kept below scrubber so sliders receive touches)
                    Rectangle()
                        .fill(Color.clear)
                        .contentShape(Rectangle())
                        .ignoresSafeArea()
                        .onTapGesture {
                            togglePlayPause()
                        }

                    // Custom controls overlay
                    // Center play button (visible only when paused)
                    if !isPlaying {
                        Button {
                            togglePlayPause()
                        } label: {
                            Image(systemName: "play.fill")
                                .font(.system(size: 48, weight: .bold))
                                .foregroundStyle(.white)
                                .padding(24)
                                .background(.black.opacity(0.35), in: Circle())
                        }
                        .buttonStyle(.plain)
                    }

                    // Bottom scrubber
                    VStack {
                        Spacer()
                        HStack(spacing: 12) {
                            // Scrubber
                            VStack(spacing: 4) {
                                Slider(
                                    value: Binding(
                                        get: { duration > 0 ? currentTime / duration : 0 },
                                        set: { newValue in
                                            guard let player = self.player else { return }
                                            isSeeking = true
                                            let target = (newValue * (duration > 0 ? duration : 0))
                                            let cmTime = CMTime(seconds: target, preferredTimescale: 600)
                                            player.seek(to: cmTime, toleranceBefore: .zero, toleranceAfter: .zero) { _ in
                                                isSeeking = false
                                            }
                                        }
                                    ),
                                    in: 0...1
                                )
                                .tint(color.button(scheme))

                                HStack {
                                    Text(timeString(currentTime))
                                        .font(.caption2)
                                        .foregroundColor(.white.opacity(0.9))
                                    Spacer()
                                    Text(timeString(max(duration - currentTime, 0)))
                                        .font(.caption2)
                                        .foregroundColor(.white.opacity(0.9))
                                }
                            }
                            .padding(.leading, 4)
                        }
                        .padding(.horizontal, 16)
                        .padding(.bottom, tabBarInset())
                        .background(
                            LinearGradient(
                                colors: [.clear, .black.opacity(0.35)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                    }
                }
            }
            .ignoresSafeArea(.container, edges: .top) // respect bottom safe area so controls sit above tab bar
            .onAppear {
                setupPlayer()
            }
            .onDisappear {
                cleanupPlayer()
            }
            .onChange(of: shouldPlay) { _, newValue in
                guard let player else { return }
                if newValue {
                    player.play()
                    isPlaying = true
                } else {
                    player.pause()
                    isPlaying = false
                }
            }
        }
    }

    private func tabBarInset() -> CGFloat {
        // Approximate tab bar height: 49pt plus device bottom safe area on home-indicator devices (~34pt)
        let bottomSafe = keyWindowBottomSafeArea()
        return 49 + bottomSafe
    }

    private func topControlsInset() -> CGFloat {
        // Simulate a navigation bar spacing so top controls sit below where a toolbar would be
        // Standard nav bar height is ~44pt. Add a small extra offset for clarity.
        return 44
    }

    private func keyWindowBottomSafeArea() -> CGFloat {
        for scene in UIApplication.shared.connectedScenes {
            if let windowScene = scene as? UIWindowScene {
                if let window = windowScene.windows.first(where: { $0.isKeyWindow }) {
                    return window.safeAreaInsets.bottom
                }
            }
        }
        return 0
    }

    private func setupPlayer() {
        configureAudioSession()
        // Try to use a preheated player (preferred to avoid item re-attachment)
        if let preheated = VideoPreheater.shared.dequeuePlayer(videoURL) {
            self.player = preheated
            self.isLoading = false
            if let item = preheated.currentItem {
                item.preferredForwardBufferDuration = 0.01
                item.preferredPeakBitRate = 500_000
                if #available(iOS 16.0, *) {
                    item.preferredMaximumResolution = CGSize(width: 640, height: 360)
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) {
                    item.preferredPeakBitRate = 0
                    if #available(iOS 16.0, *) {
                        item.preferredMaximumResolution = .zero
                    }
                }
            }
            if shouldPlay {
                preheated.playImmediately(atRate: 1.0)
            }
            return
        }

        // Fallback: create fresh item
        let item = AVPlayerItem(url: videoURL)
        // Favor extremely short startup buffer; TikTok-style quick start
        item.preferredForwardBufferDuration = 0.01
        // Constrain early quality to get first frame ASAP; will be lifted shortly after
        item.preferredPeakBitRate = 500_000 // ~0.5 Mbps for very fast start
        if #available(iOS 16.0, *) {
            item.preferredMaximumResolution = CGSize(width: 640, height: 360)
        }

        let player = AVPlayer(playerItem: item)
        // Do not wait to minimize stalling; start as soon as possible
        player.automaticallyWaitsToMinimizeStalling = false
        player.allowsExternalPlayback = false

        self.player = player
        // Reveal the player UI immediately; let it preroll in the background
        self.isLoading = false

        if shouldPlay {
            // Kick off playback right away
            player.playImmediately(atRate: 1.0)
            isPlaying = true
        }

        // After a brief moment, remove caps to allow better quality
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) {
            item.preferredPeakBitRate = 0 // system default / adaptive
            if #available(iOS 16.0, *) {
                item.preferredMaximumResolution = .zero // no cap
            }
        }

        // Observe duration and periodic time to update UI
        if let dur = player.currentItem?.asset.duration.seconds, dur.isFinite {
            self.duration = dur
        } else {
            // Load duration asynchronously
            Task {
                let seconds = try? await player.currentItem?.asset.load(.duration).seconds
                await MainActor.run {
                    self.duration = (seconds ?? 0).isFinite ? (seconds ?? 0) : 0
                }
            }
        }
        addTimeObserver(to: player)
    }

    private func cleanupPlayer() {
        if let player {
            if let observer = timeObserver {
                player.removeTimeObserver(observer)
                timeObserver = nil
            }
            player.pause()
        }
        player = nil
        // Deactivate audio session to restore system behavior
        do {
            try AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
        } catch {
            print("Failed to deactivate audio session: \(error)")
        }
    }

    private func addTimeObserver(to player: AVPlayer) {
        let interval = CMTime(seconds: 0.05, preferredTimescale: 600)
        timeObserver = player.addPeriodicTimeObserver(forInterval: interval, queue: .main) { time in
            if !isSeeking {
                self.currentTime = time.seconds.isFinite ? time.seconds : 0
                if let dur = player.currentItem?.duration.seconds, dur.isFinite {
                    self.duration = dur
                }
            }
        }
    }

    private func togglePlayPause() {
        guard let player else { return }
        if isPlaying {
            player.pause()
        } else {
            player.playImmediately(atRate: 1.0)
        }
        isPlaying.toggle()
    }

    private func timeString(_ seconds: Double) -> String {
        guard seconds.isFinite else { return "0:00" }
        let total = Int(seconds.rounded())
        let m = total / 60
        let s = total % 60
        return String(format: "%d:%02d", m, s)
    }
}






//#Preview {
//    FullScreenVideoPlayer(videoURL: URL(string: Reminder.example.firebaseVideoURL!)! )
//}


