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
    @FocusState private var keyboard: Bool

    @Bindable var reminder: Reminder

    @State private var refuseSaving = false


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
                                .fill(Color.cardBackground)
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
                                .fill(Color.cardBackground)
                                .shadow(color: .black.opacity(0.08), radius: 8, y: 4)
                        )
                        .padding(.horizontal, 16)
                         
                        TabView {
                            Tab{
                                switch reminder.type {
                                case .InstantInsight:
                                    AddingVideoView(firebaseVideoURL: $reminder.firebaseVideoURL, thumbnail: $reminder.photo)
                                case .EchoSnap:
                                    AddingPhotoView(photo: $reminder.photo)
                                default:
                                    AddingDescriptionView(text: $reminder.text, keyboard: $keyboard)
                                }
                            }
                            if reminder.type != .TimeLessLetter {
                                Tab {
                                    AddingDescriptionView(text: $reminder.text, keyboard: $keyboard)
                                }

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
                                .fill(Color.cardBackground)
                                .shadow(color: .black.opacity(0.08), radius: 8, y: 4)
                        )
                        .padding(.horizontal, 16)


                    }
                    .padding(.top, 20)
                }
            }
            .animation(.smooth, value: reminder.type)
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
                                .background(Color.cardBackground)
                                .clipShape(.capsule)
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
            .sheet(isPresented: $refuseSaving){
                RefuseSavingView()
                    .presentationDetents([.height(300)])
            }


        }

    }

}

#Preview {
    AddReminderView(reminder: .example)
}
