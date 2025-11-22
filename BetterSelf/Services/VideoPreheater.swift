//
//  VideoPreheater.swift
//  BetterSelf
//
//  Created by AI on 22/11/2025.
//

import Foundation
import AVFoundation

final class VideoPreheater {
    static let shared = VideoPreheater()
    private init() {}

    private struct Entry {
        let player: AVPlayer
        let item: AVPlayerItem
        var observation: NSKeyValueObservation?
    }

    private var urlToEntry: [URL: Entry] = [:]
    private let queue = DispatchQueue(label: "video-preheater-queue", qos: .userInitiated)

    func preheat(_ url: URL) {
        queue.async {
            if self.urlToEntry[url] != nil { return }

            let item = AVPlayerItem(url: url)
            // Aggressive quick-start tuning
            item.preferredForwardBufferDuration = 0.01
            item.preferredPeakBitRate = 500_000
            if #available(iOS 16.0, *) {
                item.preferredMaximumResolution = CGSize(width: 640, height: 360)
            }
            item.canUseNetworkResourcesForLiveStreamingWhilePaused = true

            let player = AVPlayer(playerItem: item)
            player.automaticallyWaitsToMinimizeStalling = false
            player.allowsExternalPlayback = false

            var entry = Entry(player: player, item: item, observation: nil)
            // Observe readiness; only then preroll to avoid the crash
            entry.observation = item.observe(\.status, options: [.new, .initial], changeHandler: { [weak self] observedItem, _ in
                guard let self else { return }
                if observedItem.status == .readyToPlay {
                    player.preroll(atRate: 0) { _ in }
                    // Stop observing after preroll trigger
                    self.queue.async {
                        var stored = self.urlToEntry[url]
                        stored?.observation = nil
                        self.urlToEntry[url] = stored
                    }
                }
            })

            self.urlToEntry[url] = entry
        }
    }

    // Prefer reusing the whole player to avoid re-attaching an item to a new AVPlayer
    func dequeuePlayer(_ url: URL) -> AVPlayer? {
        queue.sync {
            guard var entry = urlToEntry.removeValue(forKey: url) else { return nil }
            entry.observation = nil
            entry.player.cancelPendingPrerolls()
            entry.player.allowsExternalPlayback = false
            entry.player.automaticallyWaitsToMinimizeStalling = false
            return entry.player
        }
    }

    // Legacy: if caller insists on only the item, ensure we fully detach first
    func dequeue(_ url: URL) -> AVPlayerItem? {
        queue.sync {
            guard var entry = urlToEntry.removeValue(forKey: url) else { return nil }
            // Stop any pending prerolls and detach the item from its preheater player
            entry.player.cancelPendingPrerolls()
            entry.player.pause()
            if entry.player.currentItem === entry.item {
                entry.player.replaceCurrentItem(with: nil)
            } else {
                entry.player.replaceCurrentItem(with: nil)
            }
            entry.observation = nil
            return entry.item
        }
    }
}


