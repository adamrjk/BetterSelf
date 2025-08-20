import AVKit
import PhotosUI
import SwiftUI
import FirebaseStorage



struct AddingVideoView: View {
    @StateObject private var uploadManager = UploadManager.shared

    enum ViewState {
        case idle, showingThumbnail
    }

    @State private var viewState = ViewState.idle
//    @Binding private var thumbnail: Data?
    @State private var selectedItem: PhotosPickerItem?

//    @State private var thumbnailImage: Image?

    @Binding private var firebaseVideoURL: String?

    var body: some View {
        VStack {
            ZStack {
                switch viewState {
                case .idle:
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(Color.creamyYellowGradient)

                    PhotosPicker(selection: $selectedItem, matching: .videos){
                        VideoLoadingView(progress: false)
                    }
                    .buttonStyle(.plain)
                    .padding()
                case .showingThumbnail:
                    Text("Video Loaded")
                    /*if let image = thumbnailImage {
                        image
                            .resizable()
                            .scaledToFit()
                            .cornerRadius(14)
                            .padding(15)
                            .background(
                                RoundedRectangle(cornerRadius: 14, style: .continuous)
                                    .fill(Color.creamyYellowGradient)
                                )
                    }*/
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
//        if thumbnail != nil {
//            viewState = .showingThumbnail
//        }
    }
    struct Video {
        var thumbnailImage: UIImage?
        var asset: AVAsset?
    }


    func loadVideo() {
        Task {
            do {
                //Make Thumbnail
                /*let imageManager = PHImageManager.default()

                let fetchOptions = PHFetchOptions()
                let imageRequestOptions = PHImageRequestOptions()

                let fetchResult = PHAsset.fetchAssets(with: .video, options: fetchOptions)
                fetchResult.enumerateObjects { (phAsset, _, _) in
                    var video = Video()
                    imageManager.requestAVAsset(forVideo: phAsset, options: nil) { (avAsset, _, _) in
                        if avAsset != nil {
                            video.asset = avAsset!
                        }
                        imageManager.requestImage(for: phAsset, targetSize: CGSize(width: 200, height: 200), contentMode: .aspectFit, options: imageRequestOptions) { (uiImage, _) in
                            video.thumbnailImage = uiImage!
//                            self.videos.append(video)
                        }
                    }
                }

                if let data = try await selectedItem?.loadTransferable(type: Data.self) {
                    //                thumbnail = data
                    print(data.count)
                    print("Getting the Image")
//                    thumbnailImage = image

                }*/



                if let movie = try await selectedItem?.loadTransferable(type: Movie.self) {
                    // Upload to Firebase Storage
                    viewState = .showingThumbnail
                    await uploadVideoToFirebase(videoURL: movie.url)


                } else {
                    print("Loading Failed")
                }
            } catch {
                print("Loading Failed \(error.localizedDescription)")
            }
        }
    }

    
    func uploadVideoToFirebase(videoURL: URL) async {
        uploadManager.startUpload(videoURL: videoURL){ result in
            switch result {
            case .success(let firebaseURL):
                self.firebaseVideoURL = firebaseURL

            case .failure(let error):
                print("Firebase upload failed: \(error.localizedDescription)")
            }
        }




    }
    init(firebaseVideoURL: Binding<String?>) {
        _firebaseVideoURL = firebaseVideoURL
    }


    private func generateThumbnail(from videoURL: URL, atTime time: CMTime = CMTimeMake(value: 1, timescale: 1)) async -> UIImage? {
        // Create an AVAsset from the video URL
        let asset = AVURLAsset(url: videoURL)

        // Create an AVAssetImageGenerator
        let generator = AVAssetImageGenerator(asset: asset)
        generator.appliesPreferredTrackTransform = true
        generator.requestedTimeToleranceBefore = .zero
        generator.requestedTimeToleranceAfter = CMTime(seconds: 3, preferredTimescale: 600)

        do {
            let videoDuration = try await asset.load(.duration)
            let thumbnail = try await generator.image(at: videoDuration).image
            return UIImage(cgImage: thumbnail)
        } catch {
            debugPrint("Error generating thumbnail: \(error.localizedDescription)")
            return nil
        }
    }





    
    struct VideoLoadingView: View {
        @State var progress: Bool
        var body: some View {
            VStack(alignment: .center, spacing: 8) {
                Image(systemName: "video.fill.badge.plus")
                    .font(.system(size: 40, weight: .semibold))
                    .foregroundStyle(Color.purpleMainGradient)
                Text("Video Reminder")
                    .font(.headline)
                CleanText("Add a Video that reminds you of this idea")
                    .multilineTextAlignment(.center)
                if progress {
                    ProgressView()
                }
            }
            .shadow(color: .black.opacity(0.15), radius: 10, y: 5)
            .padding(.horizontal, 20)
        }
    }
}







#Preview {
    AddingVideoView(firebaseVideoURL: .constant(nil))
}


