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
                                .foregroundColor(.black)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.whiteFieldGradient)
                                        .shadow(color: .black.opacity(0.06), radius: 2, y: 1)
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.yellow.opacity(0.3), lineWidth: 1)
                                )
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .fill(Color.creamyYellowGradient)
                                .shadow(color: .black.opacity(0.08), radius: 8, y: 4)
                        )
                        .padding(.horizontal, 16)

                        TabView {
                            Tab {
                                AddingVideoView(firebaseVideoURL: $reminder.firebaseVideoURL)
                                

                            }

                            Tab {
                                AddingPhotoView(photo: $reminder.photo)
                            }

                            Tab{
                                AddingDescriptionView(text: $reminder.text, keyboard: $keyboard)
                            }



                        }
                        .tabViewStyle(.page)
                        .frame(height: 300)



                        VStack(alignment: .leading, spacing: 12) {
                            CleanText("Add a Link to an Article, Video, Book, etc...")
                            TextField("Link", text: $reminder.link)
                                .padding(12)
                                .focused($keyboard)
                                .foregroundColor(.black)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.whiteFieldGradient)
                                        .shadow(color: .black.opacity(0.06), radius: 2, y: 1)
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.yellow.opacity(0.3), lineWidth: 1)
                                )
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .fill(Color.creamyYellowGradient)
                                .shadow(color: .black.opacity(0.08), radius: 8, y: 4)
                        )
                        .padding(.horizontal, 16)


                    }
                    .padding(.top, 20)
                }
            }
            .navigationTitle("New Reminder")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing){
                    Button{
                        dismiss()
                    } label: {
                        HStack {
                            Text("Save")
                                .frame(width: 50)
                                .font(.headline)
                                .foregroundStyle(.black)
                                .padding(7)
                                .background(Color.creamyYellowGradient)
                                .clipShape(.capsule)
                        }
                    }
                }
            }

        }

    }

}

#Preview {
    AddReminderView(reminder: .example)
}
