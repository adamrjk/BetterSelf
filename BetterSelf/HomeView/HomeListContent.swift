//
//  HomeListContent.swift
//  BetterSelf
//
//  Created by AI on 24/10/2025.
//

import SwiftUI
import SwiftData



struct HomeListContent: View {
    @Environment(\.editMode) var editMode
    @EnvironmentObject var flow: AppFlow
    @Environment(\.colorScheme) var scheme
    @EnvironmentObject var color: ColorManager
    @Query private var reminders: [Reminder]
    @Bindable var vm: HomeViewModel

    private let folder: Folder?
//    let mode: HomeListLayoutMode
    let selectedReminderId: Reminder.ID?
    var sortedReminders: [Reminder]{ vm.unlockSortAndFilter(reminders) }

    var body: some View {
        Group {
            if reminders.isEmpty { EmptyHomeView() }
            else {

                List(selection: $vm.selection) {
                    ForEach(sortedReminders) { reminder in
                        let isSelected = (selectedReminderId == reminder.id)
                        Button {
                            AnalyticsService.log(AnalyticsService.EventName.buttonTapped, params: [
                                "button": "row_open",
                                "view": "HomeListContent",
                                "id": reminder.id.uuidString
                            ])
                            if editMode?.wrappedValue == .active {
                                // In edit mode, taps should toggle selection, not activate navigation
                                return
                            }
                            if reminder.isLoading && reminder.firebaseVideoURL == nil {
                                vm.refuseLoading.toggle()
                            } else {
                                flow.openReminder(reminder)

                            }
                        } label: {
                            ReminderRowView(reminder: reminder, isPreview: false)
                                .background(
                                    Group {
                                        if isSelected {
                                            color.cardBackground(scheme).opacity(0.25)
                                        } else {
                                            Color.clear
                                        }
                                    }
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                                        .stroke(isSelected ? color.button(scheme) : Color.clear, lineWidth: isSelected ? 1.5 : 0)
                                )
                                .shadow(color: isSelected ? color.shadow(scheme).opacity(0.35) : color.shadow(scheme).opacity(0.15), radius: isSelected ? 18 : 8, x: 0, y: isSelected ? 10 : 4)
                        }
//                        .tutorialIdentifier(ReminderService.isFirstId(reminder))
                        .swipeActions {
                            Button("", systemImage: "trash") {
                                AnalyticsService.log(AnalyticsService.EventName.buttonTapped, params: [
                                    "button": "delete_swipe",
                                    "view": "HomeListContent",
                                    "id": reminder.id.uuidString
                                ])
                                vm.requestDelete(reminder)
                            }
                            .tint(.red)
                        
                            Button("", systemImage: "folder.fill") {
                                AnalyticsService.log(AnalyticsService.EventName.buttonTapped, params: [
                                    "button": "move_swipe",
                                    "view": "HomeListContent",
                                    "id": reminder.id.uuidString
                                ])
                                vm.moveSelected(from: [reminder])
                            }
                            .tint(.black)
                        }
                        .tag(reminder.id)
                        .swipeActions(edge: .leading) {
                            Button("", systemImage: "pin.fill") {
                                reminder.pinned.toggle()
                                if reminder.pinned { reminder.datePinned = .now }
                                let event = reminder.pinned ? AnalyticsService.EventName.reminderPinned : AnalyticsService.EventName.reminderUnpinned
                                AnalyticsService.log(event, params: [
                                    "id": reminder.id.uuidString,
                                    "type": reminder.type.rawValue
                                ])
                            }
                            .tint(.orange)


                            Button {
                                AnalyticsService.log(AnalyticsService.EventName.shareTapped, params: [
                                    "id": reminder.id.uuidString,
                                    "type": reminder.type.rawValue
                                ])

                                Task {
                                    do {
                                        flow.shareSheet(ReminderService.getLink(reminder))
                                        _ = try await FirestoreService.shared.storeReminder(reminder)
                                    } catch {
                                        print("Share prepare failed: \(error)")
                                    }
                                }
                            } label: {
                                Image(systemName: "square.and.arrow.up")
                            }
                            .tint(.green)

                        }
                        .tag(reminder.id)
                    }
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                }
                .searchable(text: $vm.searchText, placement: .navigationBarDrawer, prompt: "Search for a Reminder")
                .listStyle(.plain)
                .padding(0)
            }

        }
    }

    init(_ folder: Folder?, _ vm: HomeViewModel) {
        self.folder = folder
        _vm = Bindable(vm)
        if let folder = folder {
            // Filter reminders for this folder
            let id = folder.persistentModelID
            _reminders = Query(filter: #Predicate<Reminder> { $0.folder?.persistentModelID == id })
        } else {
            _reminders = Query(filter: #Predicate<Reminder> { $0.isChecked == true })
        }
        self.selectedReminderId = nil
    }



}



