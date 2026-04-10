//
//  YouTubePreheater.swift
//  BetterSelf
//
//  Created by AI on 22/11/2025.
//

import Foundation
import YouTubePlayerKit

final class YouTubePreheater {
    static let shared = YouTubePreheater()
    private init() {}

    private var urlToPlayer: [String: YouTubePlayer] = [:]

    func ensurePlayer(for urlString: String, startTimeSeconds: Int) -> YouTubePlayer {
        if let existing = urlToPlayer[urlString] { return existing }
        let player = YouTubePlayer(
            source: .init(urlString: urlString),
            parameters: .init(
                autoPlay: false,
                loopEnabled: false,
                startTime: Measurement(value: Double(startTimeSeconds), unit: .seconds),
                showControls: true,
                showFullscreenButton: true,
                progressBarColor: .white,
                keyboardControlsDisabled: false,
                showCaptions: false
            ),
            configuration: .init(
                fullscreenMode: .web,
                allowsInlineMediaPlayback: true,
                allowsAirPlayForMediaPlayback: true,
                allowsPictureInPictureMediaPlayback: true
            ),
            isLoggingEnabled: false
        )
        urlToPlayer[urlString] = player
        return player
    }

    func player(for urlString: String) -> YouTubePlayer? {
        urlToPlayer[urlString]
    }
}


