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

    @StateObject var color = ColorManager.shared

    @State private var refuseSaving = false
    @State private var startTime = false

    enum AddReminderPage: Hashable { case main, description }
    @State private var selectedPage: AddReminderPage = .main

    @Environment(\.colorScheme) var scheme

    var body: some View {
        NavigationStack {
            ZStack {
                color.mainGradient(scheme)
                    .ignoresSafeArea()

                color.overlayGradient(scheme)
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
                                .fill(color.cardBackground(scheme))
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
                                .fill(color.cardBackground(scheme))
                                .shadow(color: .black.opacity(0.08), radius: 8, y: 4)
                        )
                        .padding(.horizontal, 16)

                        TabView(selection: $selectedPage) {

                            MainTabContent(reminder: reminder, keyboard: $keyboard)
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
                                .fill(color.cardBackground(scheme))
                                .shadow(color: .black.opacity(0.08), radius: 8, y: 4)
                        )
                        .padding(.horizontal, 16)


                    }
                    .padding(.top, 20)
                }
            }
            .onChange(of: keyboard){
                if TutorialManager.shared.inTutorial {
                    if keyboard {
                        TutorialManager.shared.handleKeyboardAppeared()
                    }
                    else {
                        TutorialManager.shared.handleKeyboardDismissed()
                    }
                }
            }
            .onAppear{
                if TutorialManager.shared.inTutorial {
                    TutorialManager.shared.viewId("AddReminder")
                    TutorialManager.shared.startTutorialForSheet( "AddReminder")
                }

            }
            .animation(.smooth, value: keyboard)
            //            .animation(.smooth, value: reminder.type)
            .navigationTitle("New Reminder")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing){
                    Button{
                        if reminder.isEmpty{
                            refuseSaving.toggle()
                        }
                        else if TutorialManager.shared.inTutorial && (reminder.title.isEmpty || reminder.text.isEmpty || reminder.firebaseVideoURL == nil ) {
                            refuseSaving.toggle()
                        }
                        else {
                            if TutorialManager.shared.inTutorial {
                                TutorialManager.shared.handleTargetViewClick(target: "SaveReminderButton")
                            }
                            dismiss()
                        }
                    } label: {
                        HStack {
                            Text("Save")
//                                .frame(width: 50)
//                                .font(.headline)
//                                .foregroundStyle(.primary)
//                                .padding(7)
//                                .background(color.cardBackground(scheme))
//                                .clipShape(.capsule)
                        }
                    }
                    .tutorialIdentifier("SaveReminderButton")
//                    .buttonStyle(.plain)
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
                                        scheme == .light
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
                StartTimeView(time: $reminder.time){ _ in
                }
                    .presentationDetents([.height(300)])

            }
            .sheet(isPresented: $refuseSaving){
                RefuseView(title: "Your Reminder is empty", description: "Add a Description, a Photo, a Video or a Link to create your Reminder")
                    .presentationDetents([.height(300)])
            }
            .onChange(of: reminder.isYoutube){ oldV, newV in
                if newV {
                    youtubeHandling()
                }
            }
        }
        .overlay{
            if TutorialManager.shared.inTutorial {
                TutorialManager.shared.tutorialView(viewId: "AddReminder")
                    .ignoresSafeArea(.all)
            }
        }


    }

    struct MainTabContent: View {
        @Environment(\.colorScheme) var scheme
        @Bindable var reminder: Reminder
        @FocusState.Binding var keyboard: Bool
        var body: some View {
            switch reminder.type {
            case .InstantInsight:
                if reminder.isYoutube {
                    ZStack(alignment: .topTrailing){

                        YouTubeThumbnailView(videoURL: reminder.link, type: .addReminder)

                        Button{
                            reminder.link = ""

                        } label: {
                            Image(systemName: "xmark")
                                .foregroundStyle(
                                    scheme == .light
                                    ? .white
                                    : .black
                                )
                                .padding(5)
                                .background(.red)
                                .clipShape(.circle)
                        }
                        .buttonStyle(.plain)
                        .offset(x: 10)
                    }
                    .padding(.horizontal, 20)


                } else {
                    AddingVideoView(firebaseVideoURL: $reminder.firebaseVideoURL, thumbnail: $reminder.photo, isLoading: $reminder.isLoading)

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

    func youtubeHandling(){
        startTime = true
        reminder.type = .InstantInsight
        selectedPage = .main
    }
}

#Preview {
    AddReminderView(reminder: Reminder(title: "", text: "", link: ""))
        .modelContainer(for: Reminder.self)
}

