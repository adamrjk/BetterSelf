//
//  AddFolderView.swift
//  BetterSelf
//
//  Created by Adam Damou on 05/09/2025.
//

import SwiftData
import SwiftUI

struct AddFolderView: View {

    @Query var folders: [Folder]
    @Environment(\.dismiss) var dismiss
    @Bindable var folder: Folder
    @FocusState private var keyboard: Bool
    @State private var refuseSaving = false

    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        NavigationStack{
            ZStack {
                Color.purpleMainGradient
                    .ignoresSafeArea()
                Color.purpleOverlayGradient
                    .ignoresSafeArea()
                VStack(spacing: 20){

                    VStack(alignment: .leading, spacing: 12) {


                        CleanText("Name")
                            .foregroundColor(.primary)
                        TextField("Folder Name", text: $folder.name)
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
                            .fill(Color(.systemGray6))
                            .shadow(color: .black.opacity(0.08), radius: 8, y: 4)
                    )
                    .padding(.horizontal, 16)

                    Spacer()
                        .frame(maxHeight: 20)

                    HStack(spacing: 16 ) {
                        Toggle("Face ID to Unlock", isOn: $folder.faceID)
                            .foregroundStyle(.secondary)
                            .font(.subheadline)

                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(Color(.systemGray6))
                            .shadow(color: .black.opacity(0.08), radius: 8, y: 4)
                    )
                    .padding(.horizontal, 16)
                }

//                #warning("Add the possibility to choose some reminders to immediately add.")
            }
            .navigationTitle("New Folder")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing){
                    Button{
                        let nameIsNotValid = folders.contains { $0.name.lowercased() == folder.name.lowercased() }
                        if folder.name.isEmpty || nameIsNotValid {
                            refuseSaving.toggle()

                        }
                        else{
                            folder.isChecked = true
                            dismiss()
                        }
                    } label: {
                        Text("Save")
                    }
                    .buttonStyle(.plain)
                }
            }
            .sheet(isPresented: $refuseSaving){
                RefuseSavingView(title: "This Folder name is not valid", description: "The name cannot be empty nor identical to another folder")
                    .presentationDetents([.height(300)])
            }
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
                                        colorScheme == .light
                                        ? .white
                                        : Color( red: 0.318, green: 0.318, blue: 0.318)

                                    )
                                    .clipShape(.circle)
                                    .padding(.trailing)
                            }
                            .buttonStyle(.plain)
                        }
                        .padding(.bottom, 8)  // ← This adds 8 points of space below the button
                    }
                }
            )

        }



    }
}
#Preview {
    AddFolderView(folder: .example)
}
