//
//  ReminderView.swift
//  BetterSelf
//
//  Created by Adam Damou on 16/08/2025.
//

import SwiftUI
import SwiftData
import AVKit

struct ReminderView: View {
    @EnvironmentObject var flow: AppFlow
    @Environment(\.dismiss) var dismiss

    @Environment(\.colorScheme) var scheme
    @EnvironmentObject var color: ColorManager




    @State private var edit = false
    @State private var detailSheet = false
    @State var reminder: Reminder

    @State private var pendingShareURL: URL?
    @State private var isPresentingShare = false


    var body: some View {
        ZStack {
            color.background(scheme)
            
            ReminderContent(reminder: reminder, isInFeed: false)
                .ignoresSafeArea()
        }
        .onAppear{
            AnalyticsService.logScreenView(screenName: "Reminder", screenClass: "ReminderView")
            if TutorialManager.shared.inTutorial {
                TutorialManager.shared.viewId("Reminder")
                TutorialManager.shared.startTutorial("Reminder")

            }
        }
        .navigationBarBackButtonHidden()
        .navigationTitle(reminder.title)
        .toolbar {


            ToolbarItem(placement: .topBarLeading) {
                Button{
                    AnalyticsService.log(AnalyticsService.EventName.buttonTapped, params: [
                        "button": "back",
                        "view": "ReminderView",
                        "id": reminder.id.uuidString
                    ])
                    flow.popInsights()
                } label: {
                    HStack {
                        Image(systemName: "chevron.left")
                    }
                    .bold()
                    .foregroundStyle(color.button(scheme))
                    .padding(8)
                }
                .buttonStyle(.plain)
            }

            ToolbarItem(placement: .topBarLeading){
                Button {
                    AnalyticsService.log(AnalyticsService.EventName.reminderEdited, params: [
                        "id": reminder.id.uuidString,
                        "type": reminder.type.rawValue
                    ])
                    edit.toggle()
                    flow.addReminderSheet(reminder)
                } label: {
                    Label("Edit", systemImage: "pencil")
                        .bold()
                        .foregroundStyle(color.button(scheme))
                        .padding(8)

                }
                .buttonStyle(.plain)

            }
            ToolbarItem(placement: .topBarTrailing){
                Button {
                    Task {
                        do {
                            AnalyticsService.log(AnalyticsService.EventName.shareTapped, params: [
                                "id": reminder.id.uuidString,
                                "type": reminder.type.rawValue
                            ])
                            pendingShareURL = ReminderService.getLink(reminder)
                            if let url = pendingShareURL {
                                flow.shareSheet(url)
                                isPresentingShare = true
                                _ = try await FirestoreService.shared.storeReminder(reminder)
                            }



                        } catch {
                            print("Share prepare failed: \(error)")
                        }
                    }
                } label: {
                    Image(systemName: "square.and.arrow.up")
                        .foregroundStyle(color.button(scheme))
                        .padding(8)
                }
                .buttonStyle(.plain)

            }


            if reminder.type != .InstantInsight {
                if !reminder.link.isEmpty && !reminder.isYoutube && !reminder.onlyLink{
                    ToolbarItem(placement: .topBarTrailing){
                        Button("Access Link", systemImage: "link.circle.fill"){
                            AnalyticsService.log(AnalyticsService.EventName.linkOpened, params: [
                                "id": reminder.id.uuidString,
                                "url": reminder.link
                            ])
                            detailSheet.toggle()
                        }
                        .font(.headline)
                        .foregroundStyle(color.button(scheme))
                        .padding(8)
                        .buttonStyle(.plain)

                    }
                }


            }
            else {
                ToolbarItem(placement: .topBarTrailing){
                    Button("Details", systemImage: "info.circle.fill"){
                        AnalyticsService.log(AnalyticsService.EventName.buttonTapped, params: [
                            "button": "details",
                            "view": "ReminderView",
                            "id": reminder.id.uuidString
                        ])
                        detailSheet.toggle()
                    }
                    .font(.headline)
                    .foregroundStyle(color.button(scheme))
                    .padding(8)
                    .buttonStyle(.plain)
                }
            }

        }
        .toolbarBackground(color.overlayGradient(scheme), for: .bottomBar, .navigationBar, .tabBar)
        .toolbar(removing: .sidebarToggle)
//        .sheet(isPresented: $isPresentingShare){
//            if let url = pendingShareURL {
//                ShareSheet(activityItems: [url])
//            }
//        }
//        .sheet(item: $pendingShareURL){ shareURL in
//            ShareSheet(activityItems: [shareURL.url])
//        }
//        .sheet(isPresented: $reminder.isShared){
//            AddTitleSheet(title: $reminder.title)
//                .presentationDetents([.height(300)])
//
//        }
//        .sheet(isPresented: $edit){
//            AddReminderView(reminder: reminder)
//                .onDisappear{
//                    if TutorialManager.shared.inTutorial {
//                        TutorialManager.shared.viewId("Reminder")
//                        TutorialManager.shared.startTutorial("Reminder")
//                    }
//                }
//        }
        .sheet(isPresented: $detailSheet){
            if reminder.type == .InstantInsight {
                NavigationView{
                    TimeLessLetterView(isSheet: true, reminder: reminder, isInFeed: false)
                        .navigationTitle(reminder.title)
                        .navigationBarTitleDisplayMode(.inline)
                        .toolbarBackground(color.overlayGradient(scheme), for: .bottomBar, .navigationBar, .tabBar)
                }
                .presentationDetents([.medium, .large])
            }
            else {
                SharedLinkView(link: reminder.link, time: $reminder.time, text: "", isSheet: true)
            }


        }



    }

    init(reminder: Reminder) {
        _reminder = State(initialValue: reminder)
        print("Successfully initialising ReminderView")
    }






}



//#Preview {
//    ReminderView(reminder: .example)
//}


