//
//  AddTitleSheet.swift
//  BetterSelf
//
//  Created by Adam Damou on 22/08/2025.
//

import SwiftUI
import UIKit
import Photos
import AVKit

struct AddTitleSheet: View {

    @Environment(\.dismiss) var dismiss

    @StateObject var color = ColorManager.shared

    @FocusState var keyboard: Bool
    @Binding var title: String

    @Environment(\.colorScheme) var scheme


    var body: some View {
        NavigationStack {
            ZStack {
                 Color.clear

                VStack(spacing: 20){
                    Spacer()
                    VStack(alignment: .leading, spacing: 12) {

                        CleanText("Title")
                        TextField("Enter title...", text: $title)
                            .focused($keyboard)
                            .padding(12)
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
                            .fill(color.cardBackground(scheme))
                            .shadow(color: .black.opacity(0.08), radius: 8, y: 4)
                    )
                    .padding(.horizontal, 16)

                    Spacer()
                    Spacer()


                }

            }
            .navigationTitle("Add a Title")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button{
                        dismiss()
                    } label: {
                        Text("Save")
                            .foregroundStyle(.primary)
                            .background(Color.clear)

                    }
                    .buttonStyle(.plain)
                }
            }
            .animation(.smooth, value: keyboard)
            .overlay(
                VStack {
                    Spacer()  // ← This pushes the button to the bottom of the screen
                    if keyboard {
                        HStack {
                            Spacer()
                            Button{
                                keyboard = false
                            } label: {
                                Image(systemName: "arrow.down")
                                    .foregroundStyle(.primary)
                                    .padding()
                                    .background(
                                        scheme == .light
                                        ? .white
                                        : Color( red: 0.318, green: 0.318, blue: 0.318)

                                    )
                                    .clipShape(.circle)
                                    .padding(.trailing)
                            }
                            .buttonStyle(.plain)
                        }
                        .padding(.bottom, 8 )  // ← This adds 8 points of space below the button
                    }
                }
            )
        }
    }
    init(title: Binding<String>){
        _title = title        
    }


    
}

//#Preview {
//    AddTitleSheet(title: .constant("Hello World"))
//}

