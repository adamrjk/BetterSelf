//
//  SharedLinkView.swift
//  BetterSelf
//
//  Created by Adam Damou on 15/09/2025.
//

import SwiftUI

struct SharedLinkView: View {
    let id: String


    var body: some View {
        YoutubeView(youtubeId: id)
    }
}

#Preview {
    SharedLinkView(id: "nQY3-VGTXpk")
}
