import AVKit
import PhotosUI
import SwiftUI



struct AddingVideoView: View {
    enum LoadState {
        case unknown, loading, loaded(Movie), failed
    }

    @State private var selectedItem: PhotosPickerItem?
    @State private var loadState = LoadState.unknown

    @Binding private var videoURL: URL?

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
        if let url = videoURL{
            loadState = .loaded(Movie(url: url))
        }
    }

    func loadVideo() {
        Task {
            do {
                loadState = .loading

                if let movie = try await selectedItem?.loadTransferable(type: Movie.self) {
                    videoURL = movie.url
                    loadState = .loaded(movie)
                } else {
                    loadState = .failed
                }
            } catch {
                loadState = .failed
            }
        }

    }
    init(videoURL: Binding<URL?>) {
        _videoURL = videoURL
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
    AddingVideoView(videoURL: .constant(nil))
}
