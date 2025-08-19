import AVKit
import PhotosUI
import SwiftUI
import FirebaseStorage



struct AddingVideoView: View {
    enum LoadState {
        case unknown, loading, loaded(Movie), failed, uploading
    }

    @State private var selectedItem: PhotosPickerItem?
    @State private var loadState = LoadState.unknown
    @State private var uploadProgress: Double = 0

    @Binding private var firebaseVideoURL: String?

    var body: some View {
        VStack {

            ZStack {
                switch loadState {
                case .unknown:
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(Color.creamyYellowGradient)
                    
                    PhotosPicker(selection: $selectedItem, matching: .videos){
                        VideoLoadingView(progress: false)
                    }
                    .buttonStyle(.plain)
                    .padding()

                case .loading:
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(Color.creamyYellowGradient)
                    
                    VideoLoadingView(progress: true)
                    
                case .uploading:
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(Color.creamyYellowGradient)
                    
                    VStack(spacing: 12) {
                        ProgressView()
                            .scaleEffect(1.2)
                        Text("Uploading to Firebase...")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        ProgressView(value: uploadProgress, total: 1.0)
                            .progressViewStyle(LinearProgressViewStyle())
                            .padding(.horizontal)
                    }

                case .loaded(let movie):
                    VideoPlayer(player: AVPlayer(url: movie.url))
                        .scaledToFit()
                        .clipped()
                        .cornerRadius(14)
                        .padding(15)
                        .background(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .fill(Color.creamyYellowGradient)
                        )

                case .failed:
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(Color.creamyYellowGradient)
                    
                    Text("Import failed")
                }
            }
            .frame(minHeight: 300)
            .shadow(color: .black.opacity(0.15), radius: 10, y: 5)


        }
        .padding(.horizontal, 20)
        .onAppear(perform: videoEditing)
        .onChange(of: selectedItem, loadVideo)
        


    }
    func videoEditing() {
        if let url = firebaseVideoURL{
            loadState = .loaded(Movie(url: URL(string: url)!))
        }
    }

    func loadVideo() {
        Task {
            do {
                loadState = .loading

                if let movie = try await selectedItem?.loadTransferable(type: Movie.self) {
                    // Upload to Firebase Storage
                    await uploadVideoToFirebase(videoURL: movie.url)
                } else {
                    loadState = .failed
                }
            } catch {
                loadState = .failed
            }
        }
    }
    
    func uploadVideoToFirebase(videoURL: URL) async {
        await MainActor.run {
            loadState = .uploading
            uploadProgress = 0
        }
        
        FirebaseStorageService.shared.uploadVideo(videoURL: videoURL) { result in
            Task { @MainActor in
                switch result {
                case .success(let firebaseURL):
                    self.firebaseVideoURL = firebaseURL
                    self.loadState = .loaded(Movie(url: videoURL))
                case .failure(let error):
                    print("Firebase upload failed: \(error)")
                    self.loadState = .failed
                }
            }
        }
    }
    init(firebaseVideoURL: Binding<String?>) {
        _firebaseVideoURL = firebaseVideoURL
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


