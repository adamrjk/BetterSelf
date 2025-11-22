//
//  ReminderView.swift
//  BetterSelf
//
//  Created by Adam Damou on 16/08/2025.
//

import SwiftUI

import AVKit

struct IPadReminderView: View {

    @Environment(\.modelContext) var modelContext
    @Environment(\.dismiss) var dismiss

    @Environment(\.colorScheme) var scheme
    @EnvironmentObject var color: ColorManager

    @Binding var selectedFolder: Folder

    let onExpandDetail: (() -> Void)?
    let isDetailOnly: Bool

    @State private var edit = false
    @State private var detailSheet = false
    @State var reminder: Reminder

    @State private var pendingShareURL: URL?
    @State private var isPresentingShare = false

    @State private var newReminder: Reminder?
    @State private var startTimeSelector = false

    @State private var addReminder = false
    @State private var selectedReminder: Reminder?



    @Binding var column: NavigationSplitViewVisibility


    var body: some View {
        Group {
//            if reminder.isYoutube {
////                SharedLinkView(link: reminder.link, time: $reminder.time, text: reminder.text, isInFeed: false, currentIndex: .constant(0), index: 0)
//                Text("hello")
//            }
//            else if reminder.onlyLink {
//                SharedLinkView(link: reminder.link, time: $reminder.time, text: "")
//            }
//            else {
                switch reminder.type {
                case .InstantInsight:
                    InstantInsightView(reminder: reminder, isInFeed: false, currentIndex: .constant(0), index: 0)
                case .EchoSnap:
                    EchoSnapView(reminder: reminder, isInFeed: false)
                default:
                    TimeLessLetterView(reminder: reminder, isInFeed: false)
                }
//            }
        }
        .overlay(
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    
                    if column != .detailOnly,
                       #available(iOS 26, *){
                        Button{
                            AnalyticsService.log(AnalyticsService.EventName.buttonTapped, params: [
                                "button": "plus_overlay",
                                "view": "IPadReminderView"
                            ])
                            let reminder = Reminder(title: "", text: "", link: "", folder: selectedFolder)
                            modelContext.insert(reminder)
                            newReminder = reminder
                            addReminder.toggle()
                            if TutorialManager.shared.inTutorial {
                                TutorialManager.shared.handleTargetViewClick(target: "PlusButton")
                            }
                        }label: {

                            Image(systemName: "plus")
                                .font(.title2)
                                .foregroundStyle(scheme == .light
                                                 ? .white
                                                 : .black)
                                .padding(20)
                        }
                        .tutorialIdentifier("PlusButton")
                        .adaptiveTranslucent(color.plusButton(scheme))
                        .clipShape(.circle)
                        .padding(.vertical, reminder.isYoutube || reminder.type == .InstantInsight ? 100 : 0)


                    }





                }
                .padding(.trailing, 10)

            }
        )
        .onAppear{
            if TutorialManager.shared.inTutorial {
                TutorialManager.shared.viewId("Reminder")
                TutorialManager.shared.startTutorial("Reminder")

            }
        }
        .navigationBarBackButtonHidden()
        .navigationTitle(reminder.title)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                if column != .detailOnly {
                    Button {
                        AnalyticsService.log(AnalyticsService.EventName.buttonTapped, params: [
                            "button": "expand_detail",
                            "view": "IPadReminderView",
                            "id": reminder.id.uuidString
                        ])
                        onExpandDetail?()
                    } label: {
                        Image(systemName: UIDevice.current.userInterfaceIdiom == .pad ? "arrow.down.right.and.arrow.up.left" : "chevron.left")
                            .frame(width: 28, height: 28)
                    }
                    .foregroundStyle(color.button(scheme))
                    .buttonStyle(.plain)
                    .padding(8)
                }



            }

            ToolbarItem(placement: .topBarTrailing) {
                HStack(spacing: 4) {
                    // Share button (fixed space)
                    Button {
                        AnalyticsService.log(AnalyticsService.EventName.buttonTapped, params: [
                            "button": "edit",
                            "view": "IPadReminderView",
                            "id": reminder.id.uuidString
                        ])
                        edit.toggle()
                    } label: {
                        Image(systemName: "pencil")
                            .frame(width: 28, height: 28)
                    }
                    .foregroundStyle(color.button(scheme))
                    .buttonStyle(.plain)
                    .padding(8)


                    Button {
                        AnalyticsService.log(AnalyticsService.EventName.shareTapped, params: [
                            "id": reminder.id.uuidString,
                            "type": reminder.type.rawValue
                        ])
                        Task {
                            do {
                                pendingShareURL = getLink(reminder)
                                isPresentingShare = true
                                _ = try await FirestoreService.shared.storeReminder(reminder)
                            } catch {
                                print("Share prepare failed: \(error)")
                            }
                        }
                    } label: {
                        Image(systemName: "square.and.arrow.up")
                            .frame(width: 28, height: 28)
                    }
                    .foregroundStyle(color.button(scheme))
                    .buttonStyle(.plain)
                    .padding(8)

                    // Info/Link slot (fixed space, toggled by opacity)
                    let showInfo = (reminder.type == .InstantInsight)
                    let showLink = (!showInfo && !reminder.link.isEmpty && !reminder.isYoutube && !reminder.onlyLink)
                    Button {
                        AnalyticsService.log(AnalyticsService.EventName.buttonTapped, params: [
                            "button": (showInfo ? "details" : "access_link"),
                            "view": "IPadReminderView",
                            "id": reminder.id.uuidString
                        ])
                        detailSheet.toggle()
                    } label: {
                        Image(systemName: showInfo ? "info.circle.fill" : "link.circle.fill")
                            .frame(width: 28, height: 28)
                    }
                    .opacity((showInfo || showLink) ? 1 : 0)
                    .allowsHitTesting(showInfo || showLink)
                    .foregroundStyle(color.button(scheme))
                    .buttonStyle(.plain)
                    .padding(8)
                }
            }
        }
        .toolbarBackground(color.overlayGradient(scheme), for: .bottomBar, .navigationBar, .tabBar)
//        .toolbar(removing: .sidebarToggle)
        
//        .toolbar(removing: .sidebarToggle)
        .sheet(isPresented: $isPresentingShare){
            if let url = pendingShareURL {
                ShareSheet(activityItems: [url])
            }
        }
//        .sheet(isPresented: $reminder.isShared){
//            AddTitleSheet(title: $reminder.title)
//                .presentationDetents([.height(300)])
//
//        }
        .sheet(
            isPresented: $addReminder, onDismiss: deleteEmptyReminder){
                if let reminder = newReminder {
                    if #available(iOS 18.0, *) {
                        AddReminderView(reminder: reminder)
                            .presentationDetents([.height(800)])
                            .presentationSizing(.page)

                            .presentationDragIndicator(.visible)
                            .onDisappear{
                                if TutorialManager.shared.inTutorial {
                                    //                                sorting = .dateNew
                                    TutorialManager.shared.viewId("Home")
                                    TutorialManager.shared.startTutorial("Home")
                                }
                            }
                    } else {
                        // iOS 17 fallback
                        AddReminderView(reminder: reminder)
                            .presentationDetents([.large])
                            .presentationDragIndicator(.visible)
                            .onDisappear{
                                if TutorialManager.shared.inTutorial {
                                    TutorialManager.shared.viewId("Home")
                                    TutorialManager.shared.startTutorial("Home")
                                }
                            }
                    }
                }
            }
            .sheet(isPresented: $edit){
                if #available(iOS 18.0, *) {
                    AddReminderView(reminder: reminder)
                        .presentationDetents([.height(800)])
                        .presentationSizing(.page)
                        .presentationDragIndicator(.visible)
                        .onDisappear{
                            if TutorialManager.shared.inTutorial {
                                TutorialManager.shared.viewId("Reminder")
                                TutorialManager.shared.startTutorial("Reminder")
                            }
                        }
                } else {
                    AddReminderView(reminder: reminder)
                        .presentationDetents([.large])
                        .presentationDragIndicator(.visible)
                        .onDisappear{
                            if TutorialManager.shared.inTutorial {
                                TutorialManager.shared.viewId("Reminder")
                                TutorialManager.shared.startTutorial("Reminder")
                            }
                        }
                }
            }

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

            .sheet(isPresented: $startTimeSelector){
                StartTimeView(time: $reminder.time){ _ in }
                    .presentationDetents([.height(300)])
            }



    }

    func deleteEmptyReminder() {
        if let reminder = newReminder{
            guard reminder.isChecked == false else { return }
            if reminder.isEmpty {
                modelContext.delete(reminder)
            }
            if (reminder.type != .TimeLessLetter && reminder.photo == nil && !reminder.isLoading) {
                reminder.type = .TimeLessLetter
            }
            reminder.isChecked = true
        }

    }

    func getLink(_ reminder: Reminder) -> URL {
        if reminder.shareID != nil {
            return reminder.shareLink
        }
        else {
            reminder.shareID = generateShortID()
            return reminder.shareLink
        }


    }
    func generateShortID(length: Int = 6) -> String {
        let chars = Array("abcdefghijklmnopqrstuvwxyz0123456789")
        var result = ""
        for _ in 0..<length {
            result.append(chars.randomElement()!)
        }
        return result
    }
    init(reminder: Reminder, selectedFolder: Binding<Folder>, onExpandDetail: (() -> Void)? = nil, isDetailOnly: Bool = false, column: Binding<NavigationSplitViewVisibility>) {
        _reminder = State(initialValue: reminder)
        _selectedFolder = selectedFolder
        self.onExpandDetail = onExpandDetail
        self.isDetailOnly = isDetailOnly
        _column = column
    }






}



//#Preview {
//    ReminderView(reminder: .example)
//}


