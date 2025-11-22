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
    @EnvironmentObject var color: ColorManager
    
    //    @State var videoURL: String
    @Binding var time: Int //in Seconds
    private let player: YouTubePlayer
    @State var videoURL: String
    let text: String

    let isInFeed: Bool
    @Binding var currentIndex: Int
    var index: Int

    var shouldPlay: Bool { currentIndex == index }

    @State var testPlay = true

    init(videoURL: String, time: Binding<Int>, text: String, isInFeed: Bool = false, currentIndex: Binding<Int> = .constant(0), index: Int = 0){
        _videoURL = State(initialValue: videoURL)
        self.player = .init(
            source: .init(urlString: videoURL),
            parameters: .init(autoPlay: currentIndex.wrappedValue == index, loopEnabled: false, startTime: Measurement(value: Double(time.wrappedValue), unit: UnitDuration.seconds) ,showControls: true, showFullscreenButton: true, progressBarColor: YouTubePlayer.Parameters.ProgressBarColor.white , keyboardControlsDisabled: false, showCaptions: false),
            configuration: .init(fullscreenMode: .web, allowsInlineMediaPlayback: true, allowsAirPlayForMediaPlayback: true, allowsPictureInPictureMediaPlayback: true),
            isLoggingEnabled: false
        )
        _time = time
        self.text = text
        self.isInFeed = isInFeed
        _currentIndex = currentIndex
        self.index = index

    }
    var body: some View {
        ZStack {
//            color.mainGradient(scheme)
//                .ignoresSafeArea()
//
//            color.overlayGradient(scheme)
//                .ignoresSafeArea()
            ZStack {
                ScrollView {
                    if shouldPlay {
                        YouTubePlayerView(player)
                            .id(time)
                            .frame(maxWidth: .infinity)
                            .aspectRatio(16.0/9.0, contentMode: .fit)
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
                    else {
                        EmptyView()
                    }



                }
                .defaultScrollAnchor(.center)
                .scrollDisabled(isInFeed)
//                .allowsHitTesting(isInFeed)
                if !isInFeed {
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            Button {
                                AnalyticsService.log(AnalyticsService.EventName.buttonTapped, params: [
                                    "button": "open_start_time",
                                    "view": "YoutubeView"
                                ])
                                startTime.toggle()
                                
                            } label: {
                                Image(systemName: "timer")
                                    .foregroundColor(.primary)
                                    .font(.title2)
                                    .padding(12)
                                    .frame(minWidth: 44, minHeight: 44)
                                    .adaptiveGlass(scheme)
                            }
                            .contentShape(Rectangle())
                            .zIndex(2)
                            .buttonStyle(.plain)
                            
                        }
                        .padding(.trailing)
                        .padding(.bottom, 4)
                        
                    }
                }



            }



        }
        .onChange(of: shouldPlay) { _, newValue in
            Task {
                if newValue {
                    try await player.play()
                } else {
                    try await player.pause()
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

