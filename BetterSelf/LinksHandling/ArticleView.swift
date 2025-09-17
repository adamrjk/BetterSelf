//
//  ArticleView.swift
//  BetterSelf
//
//  Created by Adam Damou on 15/09/2025.
//

import WebKit
import SwiftUI


struct ArticleWebView: UIViewRepresentable {
    let url: URL

    func makeUIView(context: Context) -> WKWebView {
        return WKWebView()
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        uiView.load(URLRequest(url: url))
    }
}

struct ArticleView: View {
    @State var link: String
    var body: some View {
        ArticleWebView(url: URL(string: link)!)
            .edgesIgnoringSafeArea(.all) // make it fullscreen
    }
}

//#Preview {
//    ArticleView()
//}
