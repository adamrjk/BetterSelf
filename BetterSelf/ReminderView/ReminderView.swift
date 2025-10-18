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


    @State private var edit = false
    @State private var detailSheet = false
    @State var reminder: Reminder



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
                    dismiss()
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

            ToolbarItem(placement: .topBarTrailing){
                Button {
                    edit.toggle()
                } label: {
                    Text("Edit")
                        .bold()

                }
                .padding(8)
                .foregroundStyle(color.button(scheme))
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
    init(reminder: Reminder) {
        _reminder = State(initialValue: reminder)
    }






}



#Preview {
    ReminderView(reminder: .example)
}


