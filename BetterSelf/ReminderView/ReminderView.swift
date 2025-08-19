//
//  ReminderView.swift
//  BetterSelf
//
//  Created by Adam Damou on 16/08/2025.
//

import SwiftUI

import AVKit

struct ReminderView: View {

    enum SpaceArrangment {
        case withImage, withoutImage
    }

    @Environment(\.dismiss) var dismiss

    @State private var edit = false
    private var spaceArrangment: SpaceArrangment {
        reminder.photo != nil
        ? .withImage
        : .withoutImage

    }
    @State var reminder: Reminder
    @State private var videoSheet = false


    var body: some View {
        GeometryReader { proxy in
            ZStack {
                Color.purpleMainGradient
                    .ignoresSafeArea()

                Color.purpleOverlayGradient
                    .ignoresSafeArea()
                ScrollView {
                    Spacer()
                        .frame(height:
                                spaceArrangment == .withImage
                               ? 50
                               : 120
                        )

                    VStack(spacing: 16) {


                        if let image = loadImage(reminder.photo) {
                            VStack(alignment: .leading, spacing: 8){
                                Text("Photo")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                                image
                                    .resizable()
                                    .scaledToFit()
                                    .clipped()
                                    .cornerRadius(14)
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 14, style: .continuous)
                                    .fill(Color.creamyYellowGradient)
                            )
                            .shadow(color: .black.opacity(0.05), radius: 6, y: 2)
                        }

                        if !reminder.text.isEmpty {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Description")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)

                                Text(reminder.text)
                                    .font(.subheadline)
                                    .multilineTextAlignment(.leading)

                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 14, style: .continuous)
                                    .fill(Color.creamyYellowGradient)
                            )
                            .shadow(color: .black.opacity(0.05), radius: 6, y: 2)

                        }
                        Spacer()
                            .frame(height:
                                    spaceArrangment == .withImage
                                   ? 0
                                   : 30
                            )

                        if !reminder.link.isEmpty {
                            Button {
                                launchLink()
                            } label: {
                                Text("Access Link")
                                    .font(.subheadline)
                                    .bold()
                                    .foregroundStyle(.secondary)
                                    .padding()
                                    .background(Color.creamyYellowGradient)
                                    .clipShape(.rect(cornerRadius: 14))
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal)
                }


            }

        }
        .navigationBarBackButtonHidden()
        .navigationTitle(reminder.title)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button{
                    dismiss()
                } label: {
                    HStack {
                        Image(systemName: "chevron.left")
                        Text("Reminders")
                    }
                    .foregroundStyle(.black)

                }

            }

            ToolbarItem(placement: .topBarTrailing){
                Button {
                    edit.toggle()
                } label: {
                    Text("Edit")
                        .foregroundStyle(.black)
                }
            }


            ToolbarItem(placement: .topBarTrailing){
                if reminder.firebaseVideoURL != nil {
                    Button("Video", systemImage: "video.fill"){
                        videoSheet.toggle()
                    }
                }
            }
            ToolbarItem(placement: .bottomBar){
                // Date indicator at bottom right
                HStack {
                    Spacer()

                    HStack {
                        Image(systemName: "calendar")
                            .font(.caption)
                            .foregroundStyle(.purple.opacity(0.7))

                        Text(reminder.date, style: .date)
                            .font(.caption)
                            .foregroundStyle(.purple.opacity(0.7))
                            .padding(.trailing)
                    }
                    .padding(3)
                    .background(Color.creamyYellowGradient)
                    .clipShape(.capsule)
                }

            }

        }
        .toolbarBackground(Color.purpleOverlayGradient, for: .bottomBar, .navigationBar, .tabBar)
        .sheet(isPresented: $videoSheet) {
            if let firebaseURL = reminder.firebaseVideoURL, let url = URL(string: firebaseURL) {
                FullScreenVideoPlayer(videoURL: url)
                    .ignoresSafeArea()
            }
        }
        .sheet(isPresented: $edit){
            AddReminderView(reminder: reminder)
        }



    }
    func loadImage(_ data: Data?) -> Image? {
        guard let data,
              let uiImage = UIImage(data: data) else {
            return nil
        }
        return Image(uiImage: uiImage)
    }

    func launchLink() {
        //Either show a sheet or navlink with the link result
        // or Show an actual WebView with the link result
    }



}



#Preview {
    ReminderView(reminder: .example)
}


