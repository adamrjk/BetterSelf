//
//  AddingPhotoView.swift
//  BetterSelf
//
//  Created by Adam Damou on 16/08/2025.
//

import SwiftData
import PhotosUI
import SwiftUI

struct AddingPhotoView: View {

    
    @Environment(\.colorScheme) var scheme

    @StateObject var color = ColorManager.shared



    @State private var image: Image?
    @Binding private var photo: Data?

    @State private var selectedPhoto: PhotosPickerItem?


    var body: some View {
        VStack{
            PhotosPicker(selection: $selectedPhoto, matching: .images) {
                ZStack {
                    if let image {
                        image
                            .resizable()
                            .scaledToFit()
                            .cornerRadius(14)
                            .padding(15)
                            .background(
                                RoundedRectangle(cornerRadius: 14, style: .continuous)
                                    .fill(color.cardBackground(scheme))
                            )
                    } else {
                        // Default state with fixed background
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .fill(color.cardBackground(scheme))

                        VStack(alignment: .center, spacing: 8) {
                            Image(systemName: "photo.badge.plus")
                                .font(.system(size: 40, weight: .semibold))
                                .foregroundStyle(color.itemColor(scheme))
                            Text("Photo Reminder")
                                .font(.headline)

                            CleanText("Add an Image that reminds you of this idea")
                                .multilineTextAlignment(.center)
                        }
                        .frame(maxWidth: .infinity, minHeight: 300)
                        .padding()


                    }

                }
                .frame(minHeight: 300)
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            }
            .padding(.horizontal, 20)
            .buttonStyle(.plain)
            .onChange(of: selectedPhoto, loadImage)
            .onAppear(perform: imageEditing)
        }
    }
    func imageEditing() {
        if let data = photo {
            image = Image(uiImage: UIImage(data: data)!)
        }
    }


    func loadImage() {
        Task {
            guard let data = try await selectedPhoto?.loadTransferable(type: Data.self) else { return }
            photo = data
            image = Image(uiImage: UIImage(data: data)!)
        }
    }
    init(photo: Binding<Data?>){
        _photo = photo
    }
}

#Preview {
    AddingPhotoView(photo: .constant(nil))
}
