import AVKit
import PhotosUI
import SwiftUI
import FirebaseStorage
import Photos



struct AddingVideoView: View {

    
    @Environment(\.colorScheme) var scheme

    @EnvironmentObject var color: ColorManager
    @StateObject private var uploadManager = UploadManager.shared

    enum ViewState {
        case idle, loading, showingThumbnail
    }

    @State private var viewState = ViewState.idle
    @State private var thumbnailImage: Image?
    @State private var selectedItem: PhotosPickerItem?

    @Binding private var firebaseVideoURL: String?
    @Binding private var thumbnailURL: String?
    @Binding private var isLoading: Bool


    var body: some View {
        VStack {
            ZStack {
                switch viewState {
                case .idle:
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(color.cardBackground(scheme))

                    PhotosPicker(selection: $selectedItem, matching: .videos){
                        VideoLoadingView()
                    }
                    .tutorialIdentifier("CameraIconButton")
                    .buttonStyle(.plain)
                    .padding()
                case .loading:
                    ZStack(alignment: .topTrailing){
                        ZStack {
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .fill(color.cardBackground(scheme))
                            VStack {
                                Text("Loading Video...")
                                    .font(.headline)
                                    .padding(.top)
                                ProgressView()
                            }
                        }
                        Button{
                            AnalyticsService.log(AnalyticsService.EventName.buttonTapped, params: [
                                "button": "cancel_video_loading",
                                "view": "AddingVideoView"
                            ])
                            isLoading = false
                            thumbnailImage = nil
                            selectedItem = nil
                            firebaseVideoURL = nil
                            thumbnailURL = nil
                            viewState = .idle

                        } label: {
                            Image(systemName: "xmark")
                                .foregroundStyle(
                                    scheme == .light
                                    ? .white
                                    : .black
                                )
                                .padding(5)
                                .background(.red)
                                .clipShape(.circle)
                        }
                        .buttonStyle(.plain)
                        .offset(x: 10)
                    }
                    .frame(minHeight: 300)
                    .shadow(color: .black.opacity(0.15), radius: 10, y: 5)



                case .showingThumbnail:
                    if let image = thumbnailImage {
                        ZStack(alignment: .topTrailing){
                            ZStack {
                                image
                                    .resizable()
                                    .scaledToFit()
                                    .cornerRadius(14)
                                    .padding(15)
                                    .background(
                                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                                            .fill(color.cardBackground(scheme))
                                    )

                                // Video play indicator
                                  Image(systemName: "play.circle.fill")
                                      .font(.system(size: 40))
                                      .foregroundColor(.white)
                                      .shadow(color: .black.opacity(0.3), radius: 2)
                            }
                            Button{
                                AnalyticsService.log(AnalyticsService.EventName.buttonTapped, params: [
                                    "button": "remove_video_thumbnail",
                                    "view": "AddingVideoView"
                                ])
                                isLoading = false
                                thumbnailImage = nil
                                selectedItem = nil
                                firebaseVideoURL = nil
                                thumbnailURL = nil
                                viewState = .idle

                            } label: {
                                Image(systemName: "xmark")
                                    .foregroundStyle(
                                        scheme == .light
                                        ? .white
                                        : .black
                                    )
                                    .padding(5)
                                    .background(.red)
                                    .clipShape(.circle)
                            }
                            .buttonStyle(.plain)
                            .offset(x: 10)






                        }
                    }
                }
            }
            .frame(minHeight: 300)
        }
        .padding(.horizontal, 20)
        .onChange(of: selectedItem, loadVideo)
        .onAppear(perform: videoEditing)
    }

    func videoEditing() {
        if let urlString = thumbnailURL, let url = URL(string: urlString) {
            viewState = .showingThumbnail
            Task {
                if let (data, _) = try? await URLSession.shared.data(from: url),
                   let uiImage = UIImage(data: data) {
                    thumbnailImage = Image(uiImage: uiImage)
                }
            }
        }
    }
    struct Video {
        var thumbnailImage: UIImage?
        var asset: AVAsset?
    }


    func loadVideo() {
        if selectedItem != nil {
            viewState = .loading
            isLoading = true
            TutorialManager.shared.handleTargetViewClick(target: "CameraIconButton")
            Task {
                do {
                    if let videoData = try await selectedItem?.loadTransferable(type: Data.self) {
                        if let uIImage = await generateThumbnail(from: videoData) {
                            self.thumbnailImage = Image(uiImage: uIImage)
                            self.viewState = .showingThumbnail
                            if let data = uIImage.jpegData(compressionQuality: 0.8) {
                                uploadManager.startUpload(imageData: data) { result in
                                    if case .success(let url) = result {
                                        self.thumbnailURL = url
                                    }
                                }
                            }
                        }


                        // Upload video in background
                        await uploadVideoToFirebase(videoData: videoData)
                    } else {
                        print("Video loading failed")
                    }
                } catch {
                    print("Loading Failed \(error.localizedDescription)")
                }
            }
        }
    }

    func generateThumbnail(from videoData: Data) async -> UIImage? {
        // Create a temporary URL for the data
        let tempURL = FileManager.default.temporaryDirectory.appending(path: "\(UUID().uuidString).mov")

        do {
            // Write data to temp file temporarily
            try videoData.write(to: tempURL)

            // Generate thumbnail from the temp file
            let asset = AVURLAsset(url: tempURL)
            let generator = AVAssetImageGenerator(asset: asset)
            generator.appliesPreferredTrackTransform = true

            // Get thumbnail at 0.1 seconds (very fast)
            let time = CMTime(seconds: 0.1, preferredTimescale: 600)

            let cgImage = try await generator.image(at: time).image
            let thumbnail = UIImage(cgImage: cgImage)

            // DELETE THE TEMP FILE IMMEDIATELY after thumbnail generation
            try FileManager.default.removeItem(at: tempURL)

            return thumbnail
        } catch {
            print("Thumbnail generation error: \(error)")
            // Also clean up temp file if thumbnail generation failed
            if FileManager.default.fileExists(atPath: tempURL.path) {
                try? FileManager.default.removeItem(at: tempURL)
            }
            return nil
        }
    }

    // Remove the complex thumbnail generation method - not needed

    
    func uploadVideoToFirebase(videoData: Data) async {
        uploadManager.startUpload(videoData: videoData) { result in
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
    init(firebaseVideoURL: Binding<String?>, thumbnailURL: Binding<String?>, isLoading: Binding<Bool>) {
        _firebaseVideoURL = firebaseVideoURL
        _thumbnailURL = thumbnailURL
        _isLoading = isLoading
    }

    
    struct VideoLoadingView: View {

        @Environment(\.colorScheme) var scheme
        @EnvironmentObject var color: ColorManager

        var body: some View {
            VStack(alignment: .center, spacing: 8) {
                Image(systemName: "video.fill.badge.plus")
                    .font(.system(size: 40, weight: .semibold))
                    .foregroundStyle(color.itemColor(scheme))

                Text("Video Reminder")
                    .font(.headline)
                CleanText("Add a Video that reminds you of this idea")
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, 20)
            .shadow(color: .black.opacity(0.08), radius: 8, y: 4)
        }
    }
}







#Preview {
    AddingVideoView(firebaseVideoURL: .constant(nil), thumbnailURL: .constant(nil), isLoading: .constant(false))
}

