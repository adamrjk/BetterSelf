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

    @Environment(\.colorScheme) var colorScheme

    var calendarCardText: Color {
        colorScheme == .light
        ? .purple.opacity(0.7)
        : .creamyYellow
    }


    @State private var edit = false
    @State private var detailSheet = false
    @State var reminder: Reminder

    private var primaryColor: Color {
        reminder.type == .InstantInsight
        ? .white
        : .primary

    }

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
        Group {
            if reminder.isYoutube {
                SharedLinkView(link: reminder.link, time: $reminder.time)
            }
            else if reminder.onlyLink {
                SharedLinkView(link: reminder.link, time: $reminder.time)
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
                    .foregroundStyle(primaryColor)
                    .bold()

                }
            }

            ToolbarItem(placement: .topBarTrailing){
                Button {
                    edit.toggle()
                } label: {
                    Text("Edit")
                        .foregroundStyle(primaryColor)
                        .bold()
                }
            }


            if reminder.type != .InstantInsight {
                if !reminder.link.isEmpty && !reminder.isYoutube && !reminder.onlyLink{
                    ToolbarItem(placement: .topBarTrailing){
                        Button("Access Link", systemImage: "link.circle.fill"){
                            detailSheet.toggle()
                        }
                        .font(.headline)
                        .buttonStyle(.plain)
                        .foregroundStyle(.white)
                        .padding(8)
                    }
                }


            }
            else {
                ToolbarItem(placement: .topBarTrailing){
                    Button("Details", systemImage: "info.circle.fill"){
                        detailSheet.toggle()
                    }
                    .font(.headline)
                    .buttonStyle(.plain)
                    .foregroundStyle(.white)
                    .padding(8)
                }
            }

        }
        .toolbarBackground(Color.purpleOverlayGradient, for: .bottomBar, .navigationBar, .tabBar)
        .sheet(isPresented: $reminder.isShared){
            AddTitleSheet(title: $reminder.title)
                .presentationDetents([.height(300)])





        }


        .sheet(isPresented: $edit){
            AddReminderView(reminder: reminder)
        }
        .sheet(isPresented: $detailSheet){
            if reminder.type == .InstantInsight {
                NavigationView{
                    TimeLessLetterView(isSheet: true, reminder: reminder)
                        .navigationTitle(reminder.title)
                        .navigationBarTitleDisplayMode(.inline)
                        .toolbarBackground(Color.purpleOverlayGradient, for: .bottomBar, .navigationBar, .tabBar)
                }
                .presentationDetents([.medium, .large])
            }
            else {
                SharedLinkView(link: reminder.link, time: $reminder.time)
            }


        }



    }






}



#Preview {
    ReminderView(reminder: .example)
}


