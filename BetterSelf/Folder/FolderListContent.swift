//
//  FolderListContent.swift
//  BetterSelf
//
//  Created by AI on 24/10/2025.
//


import SwiftData
import SwiftUI



struct FolderListContent: View {
    @EnvironmentObject var flow: AppFlow
    @Environment(\.modelContext) var modelContext
    @Environment(\.isSearching) var isSearching
    @Environment(\.colorScheme) var scheme
    @EnvironmentObject var color: ColorManager
    @Query(filter: #Predicate<Folder> { $0.isChecked == true},
           sort: \Folder.date) var folders: [Folder]
    @Query(filter: #Predicate<Reminder> { $0.isChecked == true },
           sort: \Reminder.date) var reminders: [Reminder]

    @Bindable var vm: FolderViewModel
    private var unlockedReminders: [Reminder] { reminders.filter { $0.isLocked == false } }
    private var filteredReminders: [Reminder] { vm.filter(unlockedReminders) }
    private var pinned: [Reminder] { vm.getPinned(unlockedReminders) }

    private var reminderService: ReminderService {
        ReminderService(provider: { modelContext })
    }
    
    private var folderService: FolderService {
        FolderService(provider: { modelContext })
    }

    init(vm: FolderViewModel) {
        _vm = Bindable(vm)
    }
    var body: some View {
        Group {
            if isSearching || !vm.searchText.isEmpty {
                searchResultsView
            } else {
                pinnedSectionView
                foldersSectionView
            }
        }
        .animation(.smooth, value: pinned)
        .onChange(of: pinned) { _, _ in
            vm.storePinnedReminders(pinned)
            if let last = pinned.last {
                vm.addNotification(for: last)
            }
        }
    }

    @ViewBuilder
    private var searchResultsView: some View {
        ForEach(filteredReminders) { reminder in
            Button {
                AnalyticsService.log(AnalyticsService.EventName.buttonTapped, params: [
                    "button": "search_result_open",
                    "view": "FolderListContent",
                    "id": reminder.id.uuidString
                ])
                if reminder.type == .InstantInsight && reminder.firebaseVideoURL == nil && !reminder.isYoutube {
                    vm.refuseLoading.toggle()
                } else {
                    flow.openReminder(reminder)
                }
            } label: {
                ReminderRowView(reminder: reminder, isPreview: true)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 7)
            }
        }
    }

    @ViewBuilder
    private var pinnedSectionView: some View {
        VStack(alignment: .leading, spacing: 0) {
            VStack(alignment: .leading, spacing: 12) {
                Text("Pinned")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                    .padding(.horizontal, 20)
                    .padding(.top, 16)

                if pinned.isEmpty {
                    VStack(spacing: 8) {
                        Text("Choose up to 3 Reminders for Quick Access")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .padding(.horizontal, 20)
                            .padding(.top, 16)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.vertical, 20)
                } else {
//                    if mode == .iPad {
//                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 320, maximum: 480), spacing: 16)], spacing: 12) {
//                            ForEach(pinned) { reminder in
//                                Button {
//                                    AnalyticsService.log(AnalyticsService.EventName.buttonTapped, params: [
//                                        "button": "pinned_open",
//                                        "view": "FolderListContent",
//                                        "id": reminder.id.uuidString
//                                    ])
//                                    if reminder.type == .InstantInsight && reminder.firebaseVideoURL == nil && !reminder.isYoutube {
//                                        vm.refuseLoading.toggle()
//                                    } else {
//                                        flow.openReminder(reminder)
//                                    }
//                                } label: {
//                                    ReminderRowView(reminder: reminder, isPreview: true)
//                                }
//                            }
//                        }
//                        .padding(.horizontal, 16)
//                    } else {
                        ForEach(pinned) { reminder in
                            Button {
                                AnalyticsService.log(AnalyticsService.EventName.buttonTapped, params: [
                                    "button": "pinned_open",
                                    "view": "FolderListContent",
                                    "id": reminder.id.uuidString
                                ])
                                if reminder.type == .InstantInsight && reminder.firebaseVideoURL == nil && !reminder.isYoutube {
                                    vm.refuseLoading.toggle()
                                } else {
                                    flow.openReminder(reminder)
                                }
                            } label: {
                                ReminderRowView(reminder: reminder, isPreview: true)
                            }
                            .padding(.horizontal, 16)
                        }
//                    }
                }
            }
            .padding(.bottom, 8)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(color.shadow(scheme).opacity(0.2), lineWidth: 1)
                    .shadow(color: color.shadow(scheme).opacity(0.15), radius: 8, x: 0, y: 4)
                    .shadow(color: color.shadow(scheme).opacity(0.1), radius: 16, x: 0, y: 8)
            )
            .shadow(color: color.shadow(scheme).opacity(0.15), radius: 8, x: 0, y: 4)
            .shadow(color: color.shadow(scheme).opacity(0.1), radius: 16, x: 0, y: 8)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 5)
    }

    @ViewBuilder
    private var foldersSectionView: some View {
        ZStack {
            VStack(alignment: .leading, spacing: 0) {
                VStack(alignment: .leading, spacing: 0) {
                    Text("Folders")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                        .padding(.horizontal, 20)
                        .padding(.top, 16)
                        .padding(.bottom, 12)

                    VStack(spacing: 0) {
                        Button {
                            AnalyticsService.log(AnalyticsService.EventName.buttonTapped, params: [
                                "button": "open_all_reminders",
                                "view": "FolderListContent"
                            ])
                            if TutorialManager.shared.inTutorial {
                                TutorialManager.shared.handleTargetViewClick(target: "AllRemindersButton")
                            }

                            flow.openAllReminders()
                        } label: {
                            FolderRowView(folder: nil, count: folderService.getCount(nil, unlockedReminders))
                                .padding(.horizontal, 16)
                                .padding(.vertical, 12)
                                .opacity(1)
                        }
                        .tutorialIdentifier("AllRemindersButton")

                        if !folders.isEmpty {
                            Divider()
                                .padding(.top, 6)
                        }

                        foldersListView
                    }
                }
            }
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(color.shadow(scheme).opacity(0.2), lineWidth: 1)
                    .shadow(color: color.shadow(scheme).opacity(0.15), radius: 8, x: 0, y: 4)
                    .shadow(color: color.shadow(scheme).opacity(0.1), radius: 16, x: 0, y: 8)
            )
            .shadow(color: color.shadow(scheme).opacity(0.15), radius: 8, x: 0, y: 4)
            .shadow(color: color.shadow(scheme).opacity(0.1), radius: 16, x: 0, y: 8)
        }
        .padding(.horizontal, 16)
        .padding(.top, 10)
    }

    @ViewBuilder
    private var foldersListView: some View {
        List {
            ForEach(folders) { folder in
                if folder.faceID && folder.isLocked {
                    Button { AnalyticsService.log(AnalyticsService.EventName.buttonTapped, params: [
                        "button": "authenticate_folder",
                        "view": "FolderListContent",
                        "folder": folder.name
                    ]); vm.authenticate(folder) } label: {
                        FolderRowView(folder: folder, count: folderService.getCount(folder, unlockedReminders))
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                        if folder != folders.last { Divider() }
                    }
                } else {
                    Button {
                        AnalyticsService.log(AnalyticsService.EventName.buttonTapped, params: [
                            "button": "open_folder",
                            "view": "FolderListContent",
                            "folder": folder.name
                        ]);
                        flow.openFolder(folder)
                    } label: {
                        FolderRowView(folder: folder, count: folderService.getCount(folder, unlockedReminders))
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                        if folder != folders.last { Divider() }
                    }
                    .swipeActions {
                        Button("", systemImage: "trash") {
                            AnalyticsService.log(AnalyticsService.EventName.buttonTapped, params: [
                                "button": "folder_delete_swipe",
                                "view": "FolderListContent",
                                "folder": folder.name
                            ])
                            vm.requestDelete(folder)

                        }
                        .tint(.red)
                    }
                }
            }
            .listRowInsets(EdgeInsets())
            .listRowBackground(Color.clear)
            .listRowSeparator(.hidden)
        }
        .frame(height: CGFloat(55 * folders.count))
        .scrollDisabled(true)
        .listStyle(.plain)
    }


}



