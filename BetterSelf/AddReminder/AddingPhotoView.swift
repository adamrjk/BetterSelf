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
    @EnvironmentObject var color: ColorManager

    @State private var displayImage: Image?
    @Binding private var photoURL: String?

    @State private var selectedPhoto: PhotosPickerItem?
    @State private var isUploading = false

    var body: some View {
        VStack{
            PhotosPicker(selection: $selectedPhoto, matching: .images) {
                ZStack {
                    if let displayImage {
                        ZStack(alignment: .topTrailing) {
                            displayImage
                                .resizable()
                                .scaledToFit()
                                .cornerRadius(14)
                                .padding(15)
                                .background(
                                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                                        .fill(color.cardBackground(scheme))
                                )
                            if isUploading {
                                ProgressView()
                                    .padding(10)
                                    .background(.ultraThinMaterial, in: Circle())
                                    .padding(8)
                            }
                        }
                    } else {
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
            .onAppear(perform: loadExisting)
        }
    }

    func loadExisting() {
        guard let urlString = photoURL, let url = URL(string: urlString) else { return }
        Task {
            if let (data, _) = try? await URLSession.shared.data(from: url),
               let uiImage = UIImage(data: data) {
                displayImage = Image(uiImage: uiImage)
            }
        }
    }

    func loadImage() {
        Task {
            guard let data = try await selectedPhoto?.loadTransferable(type: Data.self),
                  let uiImage = UIImage(data: data) else { return }
            displayImage = Image(uiImage: uiImage)
            isUploading = true
            UploadManager.shared.startUpload(imageData: data) { result in
                isUploading = false
                switch result {
                case .success(let url):
                    photoURL = url
                case .failure(let error):
                    print("Photo upload failed: \(error.localizedDescription)")
                }
            }
        }
    }

    init(photoURL: Binding<String?>) {
        _photoURL = photoURL
    }
}

#Preview {
    AddingPhotoView(photoURL: .constant(nil))
}
