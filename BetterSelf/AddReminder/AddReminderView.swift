//
//  AddReminderView.swift
//  BetterSelf
//
//  Created by Adam Damou on 15/08/2025.
//

import SwiftData
import PhotosUI
import SwiftUI


struct AddReminderView: View {
    @Environment(\.dismiss) var dismiss
    @FocusState var keyboard: Bool

    @Bindable var reminder: Reminder

    @State private var refuseSaving = false
    @State private var isYoutube = false
    @State private var startTime = false

    enum AddReminderPage: Hashable { case main, description }
    @State private var selectedPage: AddReminderPage = .main

    @Environment(\.colorScheme) var colorScheme

    var newCardBackground: LinearGradient {
         LinearGradient(
            colors: [
                colorScheme == .light ? Color("CreamyYellow1") : Color(.systemGray6),
                colorScheme == .light ? Color("CreamyYellow2")  : Color(.systemGray6)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
    }



    var body: some View {
        NavigationStack {
            ZStack {
                Color.purpleMainGradient
                    .ignoresSafeArea()

                Color.purpleOverlayGradient
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 20) {
                        VStack(alignment: .leading, spacing: 12) {


                            CleanText("Title")
                                .foregroundColor(.primary)
                            TextField("Enter title...", text: $reminder.title)
                                .padding(12)
                                .focused($keyboard)
                                .foregroundStyle(.primary)
                                .background(
                                       RoundedRectangle(cornerRadius: 12)
                                           .fill(Color(.systemGray6)) // Automatically adapts
                                           .shadow(color: .primary.opacity(0.06), radius: 2, y: 1)
                                )
                                .overlay(
                                       RoundedRectangle(cornerRadius: 12)
                                           .stroke(Color.primary.opacity(0.2), lineWidth: 1)
                                )

                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .fill(newCardBackground)
                                .shadow(color: .black.opacity(0.08), radius: 8, y: 4)
                        )
                        .padding(.horizontal, 16)

                        VStack(alignment: .leading, spacing: 12) {
                            CleanText("Choose a Reminder type")
                                .padding(.horizontal, 20)

                            Picker("Reminder Type", selection: $reminder.type){
                                ForEach(ReminderType.allCases, id: \.self) { type in
                                    Text(type.rawValue)
                                        .tag(type)
                                }
                            }
                            .padding(12)
                            .pickerStyle(.segmented)

                        }
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .fill(newCardBackground)
                                .shadow(color: .black.opacity(0.08), radius: 8, y: 4)
                        )
                        .padding(.horizontal, 16)
                         
                        TabView(selection: $selectedPage) {

                            MainTabContent(reminder: reminder, keyboard: $keyboard, isYoutube: $isYoutube)
                                    .tag(AddReminderPage.main)
                            if reminder.type != .TimeLessLetter {
                                AddingDescriptionView(text: $reminder.text, keyboard: $keyboard)
                                    .tag(AddReminderPage.description)
                            }
                        }
                        .tabViewStyle(.page)
                        .frame(height: 300)


                        VStack(alignment: .leading, spacing: 12) {
                            CleanText("Add a Link to an Article, Video, Book, etc...")
                            TextField("Link", text: $reminder.link)
                                .padding(12)
                                .focused($keyboard)
                                .foregroundStyle(.primary)
                                .background(
                                       RoundedRectangle(cornerRadius: 12)
                                           .fill(Color(.systemGray6)) // Automatically adapts
                                           .shadow(color: .primary.opacity(0.06), radius: 2, y: 1)
                                   )
                                   .overlay(
                                       RoundedRectangle(cornerRadius: 12)
                                           .stroke(Color.primary.opacity(0.2), lineWidth: 1)
                                   )
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .fill(newCardBackground)
                                .shadow(color: .black.opacity(0.08), radius: 8, y: 4)
                        )
                        .padding(.horizontal, 16)


                    }
                    .padding(.top, 20)
                }
            }
            .animation(.smooth, value: keyboard)
//            .animation(.smooth, value: reminder.type)
            .navigationTitle("New Reminder")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing){
                    Button{
                        if reminder.isEmpty {
                            refuseSaving.toggle()
                        }
                        else {
                            dismiss()
                        }
                    } label: {
                        HStack {
                            Text("Save")
                                .frame(width: 50)
                                .font(.headline)
                                .foregroundStyle(.primary)
                                .padding(7)
                                .background(newCardBackground)
                                .clipShape(.capsule)
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
            .overlay(
                VStack {
                    Spacer()  // ← This pushes the button to the bottom of the screen
                    if keyboard {
                        HStack {
                            Spacer()
                            Button{
                                keyboard = false
                            } label: {
                                Image(systemName: "arrow.down")
                                    .foregroundStyle(.primary)
                                    .padding()
                                    .background(
                                        colorScheme == .light
                                        ? .white
                                        : Color( red: 0.318, green: 0.318, blue: 0.318)

                                    )
                                    .clipShape(.circle)
                                    .padding(.trailing)
                            }
                            .buttonStyle(.plain)
                        }
                        .padding(.bottom, 8)  // ← This adds 8 points of space below the button
                    }
                }
            )
            .sheet(isPresented: $startTime){
                StartTimeView(time: $reminder.time)
                    .presentationDetents([.height(300)])

            }
            .sheet(isPresented: $refuseSaving){
                RefuseSavingView(title: "Your Reminder is empty", description: "Add a Description, a Photo, a Video or a Link to create your Reminder")
                    .presentationDetents([.height(300)])
            }
            .onChange(of: reminder.link){ oldV, newV in
                checkIfYoutube(newV)

            }
            .onChange(of: reminder.type) { _, newType in
                if newType == .TimeLessLetter && selectedPage == .description {
                    selectedPage = .main
                }
            }


        }

    }

    struct MainTabContent: View {
        @Bindable var reminder: Reminder
        @FocusState.Binding var keyboard: Bool
        @Binding var isYoutube: Bool
        var body: some View {
            switch reminder.type {
                  case .InstantInsight:
                        if isYoutube {
                            YoutubeView(isPlayable: false, youtubeId: getId(reminder.link) ?? "", time: $reminder.time)

                      } else {
                          AddingVideoView(firebaseVideoURL: $reminder.firebaseVideoURL, thumbnail: $reminder.photo)
          
                      }
                  case .EchoSnap:
                       AddingPhotoView(photo: $reminder.photo)
                  default:
                      AddingDescriptionView(text: $reminder.text, keyboard: $keyboard)
                  }

        }
        func getId(_ link: String) -> String? {
            let patterns = [
                  "youtube\\.com/watch\\?v=([a-zA-Z0-9_-]{11})",
                  "youtu\\.be/([a-zA-Z0-9_-]{11})",
                  "youtube\\.com/embed/([a-zA-Z0-9_-]{11})"
              ]

              for pattern in patterns {
                  if let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive) {
                      let range = NSRange(link.startIndex..<link.endIndex, in: link)
                      if let match = regex.firstMatch(in: link, options: [], range: range) {
                          if let idRange = Range(match.range(at: 1), in: link) {
                              return String(link[idRange])
                          }
                      }
                  }
              }
              return nil

        }
    }






    func checkIfYoutube(_ link: String){
        if link.localizedStandardContains("youtube.com") || link.localizedStandardContains("youtu.be") {
            isYoutube = true
            startTime = true
            reminder.type = .InstantInsight
            selectedPage = .main


        }
        else {
            isYoutube = false
        }


    }


}

#Preview {
    AddReminderView(reminder: Reminder(title: "", text: "", link: ""))
        .modelContainer(for: Reminder.self)
}

