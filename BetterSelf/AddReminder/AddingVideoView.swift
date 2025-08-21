import AVKit
import PhotosUI
import SwiftUI
import FirebaseStorage
import Photos



struct AddingVideoView: View {
    @StateObject private var uploadManager = UploadManager.shared

    enum ViewState {
        case idle, showingThumbnail
    }

    @State private var viewState = ViewState.idle
    @State private var thumbnailImage: Image?
    @State private var selectedItem: PhotosPickerItem?

    @Binding private var firebaseVideoURL: String?
    @Binding private var thumbnail: Data?  // ✅ NEW: Binding to reminder.photo

    var body: some View {
        VStack {
            ZStack {
                switch viewState {
                case .idle:
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(Color.cardBackground)

                    PhotosPicker(selection: $selectedItem, matching: .videos){
                        VideoLoadingView()
                    }
                    .buttonStyle(.plain)
                    .padding()
                case .showingThumbnail:
                    if let image = thumbnailImage {
                        image
                            .resizable()
                            .scaledToFit()
                            .cornerRadius(14)
                            .padding(15)
                            .background(
                                RoundedRectangle(cornerRadius: 14, style: .continuous)
                                    .fill(Color.cardBackground)
                            )
                    }
                }
            }
            .frame(minHeight: 300)
            .shadow(color: .black.opacity(0.15), radius: 10, y: 5)
        }
        .padding(.horizontal, 20)
        .onChange(of: selectedItem, loadVideo)
        .onAppear(perform: videoEditing)
    }

    func videoEditing() {
        print(thumbnail == nil)
        if let data = thumbnail {
            viewState = .showingThumbnail
            thumbnailImage = Image(uiImage: UIImage(data: data)!)
        }
    }
    struct Video {
        var thumbnailImage: UIImage?
        var asset: AVAsset?
    }


    func loadVideo() {
        Task {
            do {
                // 🚀 FAST: Get video data and show thumbnail instantly
                if let movie = try await selectedItem?.loadTransferable(type: Movie.self) {
                    // Show thumbnail immediately (Movie should have thumbnail)
                    if let uiImage = movie.thumbnail {
                        await MainActor.run {
                            self.thumbnailImage = Image(uiImage: uiImage)
                            self.viewState = .showingThumbnail
                            
                            // 🎯 STORE THUMBNAIL IN REMINDER.PHOTO
                            self.thumbnail = uiImage.jpegData(compressionQuality: 0.8)
                        }
                    } else {
                        // Fallback: show "Video Loaded" text
                        await MainActor.run {
                            self.viewState = .showingThumbnail
                        }
                    }
                    
                    // 🔄 SLOW: Upload to Firebase in background
                    await uploadVideoToFirebase(videoURL: movie.url)
                } else {
                    print("Video loading failed")
                }
            } catch {
                print("Loading Failed \(error.localizedDescription)")
            }
        }
    }
    
    // Remove the complex thumbnail generation method - not needed

    
    func uploadVideoToFirebase(videoURL: URL) async {
        uploadManager.startUpload(videoURL: videoURL) { result in
            Task { @MainActor in
                switch result {
                case .success(let firebaseURL):
                    self.firebaseVideoURL = firebaseURL

                case .failure(let error):
                    print("Firebase upload failed: \(error.localizedDescription)")
                }
            }
        }
    }
    init(firebaseVideoURL: Binding<String?>, thumbnail: Binding<Data?>) {  // ✅ UPDATED: Added thumbnail parameter
        _firebaseVideoURL = firebaseVideoURL
        _thumbnail = thumbnail  // ✅ NEW: Store thumbnail binding
    }

    
    struct VideoLoadingView: View {

        @Environment(\.colorScheme) var colorScheme

        var itemColor: LinearGradient {
            colorScheme == .light
            ? Color.purpleMainGradient
            : Color.creamyYellowGradient
        }
        var body: some View {
            VStack(alignment: .center, spacing: 8) {
                Image(systemName: "video.fill.badge.plus")
                    .font(.system(size: 40, weight: .semibold))
                    .foregroundStyle(itemColor)



                Text("Video Reminder")
                    .font(.headline)
                CleanText("Add a Video that reminds you of this idea")
                    .multilineTextAlignment(.center)
            }
            .shadow(color: .black.opacity(0.15), radius: 10, y: 5)
            .padding(.horizontal, 20)
        }
    }
}







#Preview {
    AddingVideoView(firebaseVideoURL: .constant(nil), thumbnail: .constant(nil))
}


