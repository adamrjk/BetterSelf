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
            switch reminder.type {
            case .InstantInsight:
                InstantInsightView(reminder: reminder)
            case .EchoSnap:
                EchoSnapView(reminder: reminder)
            default:
                TimeLessLetterView(reminder: reminder)
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
                ToolbarItem(placement: .bottomBar){
                    // Date indicator at bottom right
                    HStack {
                        Spacer()

                        HStack {
                            Image(systemName: "calendar")
                                .font(.caption)
                                .foregroundStyle(calendarCardText)

                            Text(reminder.date, style: .date)
                                .font(.caption)
                                .foregroundStyle(calendarCardText)
                        }
                        .padding(3)
                        .background(newCardBackground)
                        .clipShape(.capsule)
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


        .sheet(isPresented: $edit){
            AddReminderView(reminder: reminder)
        }
        .sheet(isPresented: $detailSheet){
            NavigationView{
                TimeLessLetterView(isSheet: true, reminder: reminder)
                    .navigationTitle(reminder.title)
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbarBackground(Color.purpleOverlayGradient, for: .bottomBar, .navigationBar, .tabBar)
            }
            .presentationDetents([.medium, .large])


        }



    }





}



#Preview {
    ReminderView(reminder: .example)
}


