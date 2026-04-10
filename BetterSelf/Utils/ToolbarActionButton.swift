//
//  ToolbarActionButton.swift
//  BetterSelf
//
//  Created by AI Assistant on 19/11/2025.
//

import SwiftUI

struct VideoRecorderToolBarButton: View {
    let flow: AppFlow
    let color: Color
    var body: some View {
        Button("Quick Add", systemImage: "video.fill.badge.plus"){
            AnalyticsService.log(AnalyticsService.EventName.buttonTapped, params: [
                "button": "quick_add",
                "view": "HomeView"
            ])
            flow.cameraSheet()
        }
        .buttonStyle(.plain)
        .foregroundStyle(color)
        .padding(8)
    }
}

struct SelectToolbarButton: View {
    @Environment(\.colorScheme) var scheme
    @StateObject var color = ColorManager.shared
    var body: some View {
        HStack {
            Image(systemName: "checkmark.circle.fill")
                .font(.subheadline)
                .buttonStyle(.plain)
                .foregroundStyle(color.button(scheme))
                .padding(8)

            Text("Select Reminders")
        }


    }
}

struct EllipsisToolbarButton: View {
    @Environment(\.colorScheme) var scheme
    @StateObject var color = ColorManager.shared
    var body: some View {

        Image(systemName: "ellipsis")
            .font(.subheadline)
            .foregroundStyle(color.button(scheme))
            .padding(8)
    }
}


struct SortingToolbarButton: View {
    @Environment(\.colorScheme) var scheme
    @StateObject var color = ColorManager.shared
    @Binding var sorting: Sorting
    var body: some View{
        Menu {

            Picker("Sort", selection: $sorting) {
                Text("Newest First")
                    .tag( Sorting.dateNew)

                Text("Oldest First")
                    .tag(Sorting.dateOld)
                Text("Title")
                    .tag(Sorting.name)

            }
        }label: {
            HStack {
                Image(systemName: "arrow.up.arrow.down")
                    .font(.subheadline)
                    .foregroundStyle(color.button(scheme))
                    .padding(7)

                Text("Sort By")

            }
        }
    }
}


// Small helper to conditionally apply a modifier
private extension View {
    @ViewBuilder
    func ifLet<T>(_ value: T?, apply: (Self, T) -> some View) -> some View {
        if let value {
            apply(self, value)
        } else {
            self
        }
    }
}


