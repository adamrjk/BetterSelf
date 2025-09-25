//
//  Youtube PlayerView.swift
//  BetterSelf
//
//  Created by Adam Damou on 15/09/2025.
//
import WebKit
import SwiftUI
import YouTubePlayerKit

struct YoutubeView: View {
    @State private var startTime = false
    @Environment(\.colorScheme) var scheme
    @StateObject var color = ColorManager.shared
    
    //    @State var videoURL: String
    @Binding var time: Int //in Seconds
    private let player: YouTubePlayer
    @State var videoURL: String
    let text: String

    init(videoURL: String, time: Binding<Int>, text: String){
        _videoURL = State(initialValue: videoURL)
        self.player = .init(
            source: .init(urlString: videoURL),
            parameters: .init(autoPlay: true, loopEnabled: false, startTime: Measurement(value: Double(time.wrappedValue), unit: UnitDuration.seconds) ,showControls: true, showFullscreenButton: true, progressBarColor: YouTubePlayer.Parameters.ProgressBarColor.white , keyboardControlsDisabled: false, showCaptions: false),
            configuration: .init(fullscreenMode: .web, allowsInlineMediaPlayback: true, allowsAirPlayForMediaPlayback: true, allowsPictureInPictureMediaPlayback: true),
            isLoggingEnabled: false
        )
        _time = time
        self.text = text

    }
    var body: some View {
        ZStack {
            color.mainGradient(scheme)
                .ignoresSafeArea()

            color.overlayGradient(scheme)
                .ignoresSafeArea()
            ZStack {
                ScrollView {

                    YouTubePlayerView(player)
                        .id(time)
                        .frame(maxWidth: .infinity)
                        .aspectRatio(16/9, contentMode: .fit)
                        .scaledToFit()
                        .cornerRadius(30)
                        .background(
                            RoundedRectangle(cornerRadius: 30)
                                .stroke(color.shadow(scheme).opacity(0.2), lineWidth: 1)
                        )
                        .shadow(color: color.shadow(scheme).opacity(0.15), radius: 8, x: 0, y: 4)
                        .shadow(color: color.shadow(scheme).opacity(0.1), radius: 16, x: 0, y: 8)
                        .padding(.bottom, 8)

                    if !text.isEmpty {
                        DescriptionView(text: text, isYoutube: true)
                            .background(
                                RoundedRectangle(cornerRadius: 30)
                                    .stroke(color.shadow(scheme).opacity(0.2), lineWidth: 1)
                                    .frame(maxWidth: .infinity)
                            )
                            .shadow(color: color.shadow(scheme).opacity(0.15), radius: 8, x: 0, y: 4)
                            .shadow(color: color.shadow(scheme).opacity(0.1), radius: 16, x: 0, y: 8)
                            .padding(.vertical, 20)

                    }


                }
                .defaultScrollAnchor(.center)

                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button {
                            startTime.toggle()

                        } label: {
                            Image(systemName: "timer")
                                .foregroundColor(.primary)
                                .padding()
                                .adaptiveGlass(scheme)
                                .clipShape(Circle())
                        }
                        .padding()
                    }

                }



            }



        }
        .sheet(isPresented: $startTime){
            StartTimeView(time: $time){ newTime in
                player.parameters.startTime = Measurement(value: Double(newTime), unit: UnitDuration.seconds)
            }
            .presentationDetents([.height(300)])
        }
    }
}



//#Preview {
//    YoutubeView(youtubeId: "nQY3-VGTXpk", time: 0)
//}

