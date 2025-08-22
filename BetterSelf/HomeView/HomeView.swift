//
//  HomeView.swift
//  BetterSelf
//
//  Created by Adam Damou on 15/08/2025.
//

import AVFoundation
import SwiftUI
import SwiftData



struct HomeView: View {
    @Environment(\.modelContext) var modelContext
    @Query(filter: #Predicate<Reminder> { reminder in
        reminder.isChecked == true
    }, sort: \Reminder.date) var reminders: [Reminder]

    @StateObject private var uploadManager = UploadManager.shared

    @State private var searchText = ""
    @State private var addReminder = false
    @State private var selectedReminder: Reminder?
    @State private var newReminder: Reminder?
    @State private var videoRecorder = false
    @State private var refuseLoading = false
    @Environment(\.colorScheme) var colorScheme

    var itemColor: LinearGradient {
        colorScheme == .light
        ? LinearGradient(colors: [.black], startPoint: .top, endPoint: .bottom)
        : Color.creamyYellowGradient
    }

    var filteredReminders: [Reminder] {
        if searchText.isEmpty {
           reminders
        } else {
            reminders.filter { $0.title.localizedStandardContains(searchText) }
        }
    }

    //Add Sorting if you want to




    var body: some View {
        NavigationStack {
            ZStack {
                Color.purpleMainGradient
                    .ignoresSafeArea()

                Color.purpleOverlayGradient
                    .ignoresSafeArea()
                Group {
                    if reminders.isEmpty {
                        VStack {
                            Text("Looks like you have no Reminders")
                                .font(.headline)
                                .multilineTextAlignment(.center)
                                .padding()
                            CleanText("Click the plus on the top right corner to add a new Reminder")
                                .multilineTextAlignment(.center)
                        }
                    }
                    else {
                        List {
                            ForEach(filteredReminders){ reminder in
                                Button {
                                    if reminder.type == .InstantInsight && reminder.firebaseVideoURL == nil {
                                        refuseLoading.toggle()
                                    }
                                    else {
                                        selectedReminder = reminder
                                    }
                                } label: {
                                    HStack(spacing: 16) {
                                        // Left thumbnail with improved design
                                        if let image = loadImage(reminder) {
                                            image
                                                .resizable()
                                                .scaledToFill()
                                                .frame(width: 80, height: 80)
                                                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 12)
                                                        .stroke(Color.white.opacity(0.3), lineWidth: 1)
                                                )
                                                .shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 4)
                                        }
                                        // Content section with improved typography
                                        VStack(alignment: .leading, spacing: 6) {
                                            Text(reminder.title)
                                                .font(.headline)
                                                .fontWeight(.semibold)
                                                .foregroundColor(.primary)
                                                .lineLimit(2)
                                                .fixedSize(horizontal: false, vertical: true)

                                            Text(reminder.text)
                                                .font(.subheadline)
                                                .foregroundColor(.secondary)
                                                .lineLimit(3)
                                                .fixedSize(horizontal: false, vertical: true)
                                                .multilineTextAlignment(.leading)
                                        }

                                        Spacer()
                                        VStack(spacing: 4) {
                                            if !reminder.text.isEmpty { ElementIndicatorView(systemName: "text.quote")}
                                            
                                            if reminder.firebaseVideoURL != nil { ElementIndicatorView(systemName: "video.fill")}
                                            else if reminder.type == .EchoSnap && reminder.photo != nil { ElementIndicatorView(systemName: "photo.fill") }

                                            if !reminder.link.isEmpty { ElementIndicatorView(systemName: "link.circle.fill")}
                                        }



                                    }
                                    .padding(.vertical, 14)
                                    .padding(.horizontal, 16)
                                    .background(
                                        RoundedRectangle(cornerRadius: 16)
                                            .fill(Color.white.opacity(0.1))
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 16)
                                                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
                                            )
                                    )
                                    .shadow(color: .black.opacity(0.08), radius: 12, x: 0, y: 6)
                                }
                                .buttonStyle(PlainButtonStyle())
                                .listRowBackground(Color.clear)
                                .listRowSeparator(.hidden)
                                .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                            }
                            .onDelete(perform: deletePerson)
                        }

                        .listStyle(PlainListStyle())
                        .searchable(text: $searchText, placement: .navigationBarDrawer, prompt: "Search for a Reminder")
                        .padding(0)

                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Add Reminder", systemImage: "plus"){
                        let reminder = Reminder(title: "", text: "", link: "")
                        modelContext.insert(reminder)
                        newReminder = reminder
                        addReminder.toggle()
                    }
                    .buttonStyle(.plain)
                    .foregroundStyle(itemColor)
                    .padding(7)
                    .background(Color.cardBackground)
                    .clipShape(.capsule)
                }


                ToolbarItem(placement: .topBarLeading){
                    Button("Quick Add", systemImage: "video.fill.badge.plus"){
                        videoRecorder.toggle()
                    }
                    .font(.caption)
                    .buttonStyle(.plain)
                    .foregroundStyle(itemColor)
                    .padding(8)
                    .background(Color.cardBackground)
                    .clipShape(.capsule)
                }
                //                #warning("Quick Add functionnality where you just record a video, AI fills in Title and Description and Thumbnail")
            }
            .sheet(isPresented: $addReminder, onDismiss: deleteEmptyReminder){
                if let reminder = newReminder {
                    AddReminderView(reminder: reminder)
                }
            }
            .sheet(isPresented: $refuseLoading){
                RefuseLoadingView()
                    .presentationDetents([.height(300)])
            }

            .sheet(isPresented: $videoRecorder) {
                VideoRecorderView()
            }
            .navigationTitle("BetterSelf")

            .toolbarBackground(Color.purpleOverlayGradient, for: .bottomBar, .navigationBar, .tabBar)
            .navigationDestination(item: $selectedReminder) { reminder in
                ReminderView(reminder: reminder)
            }
        }

    }
    func deleteEmptyReminder() {
        if let reminder = newReminder{
            guard reminder.isChecked == false else { return }
            if reminder.isEmpty {
                modelContext.delete(reminder)
            }
            if (reminder.type != .TimeLessLetter && reminder.photo == nil) {
                reminder.type = .TimeLessLetter
            }
            reminder.isChecked = true
        }

    }




    func deletePerson(at offsets: IndexSet) {
        for offset in offsets {
            let reminder = reminders[offset]

            if let url = reminder.firebaseVideoURL {
                Task {
                    await deleteVideo(url)
                }
            }

            modelContext.delete(reminder)
        }
    }

    func deleteVideo(_ url: String) async {
        FirebaseStorageService.shared.deleteVideo(firebaseURL: url) { _ in }
    }

    func loadImage(_ reminder: Reminder) -> Image? {

        guard let data = reminder.photo, let uiImage = UIImage(data: data) else {
            return nil
        }
        return Image(uiImage: uiImage)
    }


}

#Preview {
    HomeView()
}
