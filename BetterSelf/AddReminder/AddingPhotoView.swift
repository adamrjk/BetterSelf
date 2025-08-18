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
    @State private var image: Image?
    @Binding private var photo: Data?

    @State private var selectedPhoto: PhotosPickerItem?

    var body: some View {
        VStack{
            PhotosPicker(selection: $selectedPhoto) {
                ZStack {
                    if let image {
                        image
                            .resizable()
                            .scaledToFit()
                            .cornerRadius(14)
                            .padding(15)
                            .background(
                                RoundedRectangle(cornerRadius: 14, style: .continuous)
                                    .fill(Color.creamyYellowGradient)
                            )
                    } else {
                        // Default state with fixed background
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .fill(Color.creamyYellowGradient)

                        VStack(alignment: .center, spacing: 8) {
                            Image(systemName: "photo.badge.plus")
                                .font(.system(size: 40, weight: .semibold))
                                .foregroundStyle(Color.purpleMainGradient)
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
                .shadow(color: .black.opacity(0.15), radius: 10, y: 5)
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
//            #warning("Work on handling Videos too")
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
