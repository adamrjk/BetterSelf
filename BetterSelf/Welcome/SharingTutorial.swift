//
//  SharingTutorial.swift
//  BetterSelf
//
//  Created by Adam Damou on 11/10/2025.
//

import AVKit
import SwiftUI

struct SharingTutorial: View {
    @Environment(\.dismiss) var dismiss
    @StateObject var color = ColorManager.shared
    @Environment(\.colorScheme) var scheme
    
    var body: some View {
        NavigationStack {
            ZStack {
                color.mainGradient(scheme)
                    .ignoresSafeArea()
                color.overlayGradient(scheme)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Title Section
                        VStack(spacing: 8) {
                            HStack {
                                Image(systemName: "square.and.arrow.up")
                                    .font(.subheadline)
                                    .foregroundColor(scheme == .light ? .blue : .yellow)

                                Text("Watch how to share videos directly to BetterSelf")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.center)
//                                    .padding(.horizontal)
                            }


                        }
                        .padding(.top)
                        
                        // Video Player Card
                        GifPlayerView(gifName: "tutorial")
                            .aspectRatio(9/16, contentMode: .fit)
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                            .shadow(color: .black.opacity(0.2), radius: 15, y: 8)
                            .padding(.horizontal, 30)
                        
                        // Steps
                        VStack(alignment: .leading, spacing: 16) {
                            StepRow(number: 1, text: "Find a video you want to remember")
                            StepRow(number: 2, text: "Tap the Share button")
                            StepRow(number: 3, text: "Select BetterSelf from the share menu")
                            StepRow(number: 4, text: "Your reminder gets created immediately!")
                        }
                        .padding(.horizontal, 24)
                        
                        // Try It Now Button
                        Button {
                            if let url = URL(string: "youtube://") {
                                if UIApplication.shared.canOpenURL(url) {
                                    UIApplication.shared.open(url)
                                } else {
                                    // Open YouTube website if app not installed
                                    UIApplication.shared.open(URL(string: "https://www.youtube.com")!)
                                }
                            }
                        } label: {
                            HStack {
                                Image(systemName: "play.rectangle.fill")
                                Text("Try It Now on YouTube")
                                    .fontWeight(.semibold)
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.red)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                        .padding(.horizontal, 24)
                        .padding(.bottom, 24)
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
            .navigationTitle("Sharing from Youtube")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

// MARK: - Helper View for Steps
struct StepRow: View {
    let number: Int
    let text: String
    @Environment(\.colorScheme) var scheme
    
    var body: some View {
        HStack(spacing: 12) {
            Text("\(number)")
                .font(.subheadline)
                .foregroundColor(.white)
                .frame(width: 20, height: 20)
                .background(scheme == .light ? Color.blue : Color.yellow)
                .clipShape(Circle())
            
            Text(text)
                .font(.subheadline)
                .foregroundColor(.primary)
            
            Spacer()
        }
    }
}

struct GifPlayer: UIViewControllerRepresentable {
    let player: AVPlayer
    func makeUIViewController(context: Context) -> AVPlayerViewController {
        let controller = AVPlayerViewController()
        controller.player = player
        controller.allowsPictureInPicturePlayback = false
        controller.showsPlaybackControls = false
//        controller.videoGravity = .as
        player.allowsExternalPlayback = false
        return controller

    }
    func updateUIViewController(_ uiViewController: AVPlayerViewController, context: Context) {}
}

// MARK: - Enhanced GifPlayerView with Looping
struct GifPlayerView: View {
    private let player: AVPlayer
    @State private var isLoaded = false
    @State private var loopingObserver: NSObjectProtocol?
    
    init(gifName: String) {
        if let path = Bundle.main.path(forResource: gifName, ofType: "mp4") {
            self.player = AVPlayer(url: URL(fileURLWithPath: path))
            self.player.actionAtItemEnd = .none
        } else {
            self.player = AVPlayer()
        }
    }
    
    var body: some View {
        ZStack {
            GifPlayer(player: player)


            // Loading indicator
            if !isLoaded {
                ProgressView()
                    .scaleEffect(1.5)
                    .tint(.white)
            }
        }
        .onAppear {
            // Add looping functionality when view appears
            loopingObserver = NotificationCenter.default.addObserver(
                forName: .AVPlayerItemDidPlayToEndTime,
                object: player.currentItem,
                queue: .main
            ) { _ in
                player.seek(to: .zero)
                player.play()
            }
            
            player.play()
            // Simulate loading complete
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                withAnimation {
                    isLoaded = true
                }
            }
        }
        .onDisappear {
            player.pause()
            // Remove observer when view disappears
            if let observer = loopingObserver {
                NotificationCenter.default.removeObserver(observer)
            }
        }
    }
}

#Preview {
    SharingTutorial()
}
