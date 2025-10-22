//
//  ReminderView.swift
//  BetterSelf
//
//  Created by Adam Damou on 16/08/2025.
//

import SwiftUI

import AVKit

struct ReminderView: View {

    @Environment(\.dismiss) var dismiss

    @Environment(\.colorScheme) var scheme
    @EnvironmentObject var color: ColorManager

    let onExpandDetail: (() -> Void)?

    @State private var edit = false
    @State private var detailSheet = false
    @State var reminder: Reminder

    @State private var pendingShareURL: URL?
    @State private var isPresentingShare = false


    var body: some View {
        Group {
            if reminder.isYoutube {
                SharedLinkView(link: reminder.link, time: $reminder.time, text: reminder.text)
            }
            else if reminder.onlyLink {
                SharedLinkView(link: reminder.link, time: $reminder.time, text: "")
            }
            else {
                switch reminder.type {
                case .InstantInsight:
                    InstantInsightView(reminder: reminder)
                case .EchoSnap:
                    EchoSnapView(reminder: reminder)
                default:
                    TimeLessLetterView(reminder: reminder)
                }
            }
        }
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
                Button{
                    if UIDevice.current.userInterfaceIdiom == .pad, let expand = onExpandDetail {
                        expand()
                    } else {
                        dismiss()
                    }
                } label: {
                    HStack {
                        Image(systemName: UIDevice.current.userInterfaceIdiom == .pad ? "arrow.down.right.and.arrow.up.left" : "chevron.left")
                    }
                    .bold()
                    .foregroundStyle(color.button(scheme))
                    .padding(8)
                }
                .buttonStyle(.plain)
            }

            ToolbarItem(placement: .topBarLeading){
                Button {
                    edit.toggle()
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
                            _ = try await FirestoreService.shared.storeReminder(reminder)
                            pendingShareURL = getLink(reminder)
                            isPresentingShare = true
                        } catch {
                            print("Share prepare failed: \(error)")
                        }
                    }
                } label: {
                    Image(systemName: "square.and.arrow.up")
                        .foregroundStyle(color.itemColor(scheme))
                        .padding(8)
                }
                .buttonStyle(.plain)

            }


            if reminder.type != .InstantInsight {
                if !reminder.link.isEmpty && !reminder.isYoutube && !reminder.onlyLink{
                    ToolbarItem(placement: .topBarTrailing){
                        Button("Access Link", systemImage: "link.circle.fill"){
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
        .sheet(isPresented: $isPresentingShare){
            if let url = pendingShareURL {
                ShareSheet(activityItems: [url])
            }
        }
        .sheet(isPresented: $reminder.isShared){
            AddTitleSheet(title: $reminder.title)
                .presentationDetents([.height(300)])

        }
        .sheet(isPresented: $edit){
            AddReminderView(reminder: reminder)
                .onDisappear{
                    if TutorialManager.shared.inTutorial {
                        TutorialManager.shared.viewId("Reminder")
                        TutorialManager.shared.startTutorial("Reminder")
                    }
                }
        }
        .sheet(isPresented: $detailSheet){
            if reminder.type == .InstantInsight {
                NavigationView{
                    TimeLessLetterView(isSheet: true, reminder: reminder)
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
    init(reminder: Reminder, onExpandDetail: (() -> Void)? = nil) {
        _reminder = State(initialValue: reminder)
        self.onExpandDetail = onExpandDetail
    }






}



#Preview {
    ReminderView(reminder: .example)
}


