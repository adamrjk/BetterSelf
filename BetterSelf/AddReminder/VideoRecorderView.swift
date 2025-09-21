import SwiftUI
import UIKit
import Photos
import AVKit

struct VideoRecorderView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) var modelContext

    @StateObject private var uploadManager = UploadManager.shared
    @Environment(\.colorScheme) var colorScheme

    var itemColor: LinearGradient {
        colorScheme == .light
        ? Color.purpleMainGradient
        : Color.creamyYellowGradient
    }

    var bulletPointColor: Color {
        colorScheme == .light
        ? .blue
        : .creamyYellow
    }

    var buttonTextColor: Color {
        colorScheme == .light
        ? .black
        : .creamyYellow
    }

    var newCardBackground: LinearGradient {
         LinearGradient(
            colors: [
                colorScheme == .light ? Color("CreamyYellow1") : Color(.systemGray6),
                colorScheme == .light ? Color("CreamyYellow2")  : Color(.systemGray6)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
    }





    @State private var showingImagePicker = false
    @State private var recordedVideoURL: URL?
    @State private var videoRecorded = false
    @State private var title = ""

    var body: some View {
        NavigationView {
            ZStack {

                Color.purpleMainGradient
                    .ignoresSafeArea()

                Color.purpleOverlayGradient
                    .ignoresSafeArea()
                VStack(spacing: 20) {
                    // Header
                    VStack(spacing: 12) {
                        Image(systemName: "video.circle.fill")
                            .font(.system(size: 60))
                            .foregroundStyle(itemColor)

                        Text("Record Video Reminder")
                            .font(.title2)
                            .fontWeight(.semibold)

                        Text("Tap the button below to open the camera and record your video reminder")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    .padding(20)
                    .background(
                        RoundedRectangle(cornerRadius: 14)
                            .fill(newCardBackground)

                    )
                    .padding(.top, 40)


                    Spacer()
                        .frame(height: 60)

                    // Record button
                    Button(action: {
                        showingImagePicker = true
                    }) {
                        HStack(spacing: 12) {
                            Image(systemName: "camera.fill")
                                .font(.title2)
                            Text("Start Recording")
                                .font(.headline)
                        }
                        .foregroundStyle(buttonTextColor)

                        .padding(.horizontal, 30)
                        .padding(.vertical, 16)
                        .background(newCardBackground)
                        .cornerRadius(25)
                        .shadow(color: .black.opacity(0.2), radius: 8, y: 4)
                    }
                    .buttonStyle(.plain)

                    Spacer()
                        .frame(height: 60)

                    // Instructions
                    VStack(spacing: 8) {
                        Text("How it works:")
                            .font(.subheadline)
                            .fontWeight(.medium)

                        VStack(alignment: .leading, spacing: 6) {
                            HStack {
                                Image(systemName: "1.circle.fill")
                                    .foregroundStyle(bulletPointColor)
                                Text("Tap 'Start Recording' to open camera")
                            }
                            HStack {
                                Image(systemName: "2.circle.fill")
                                    .foregroundColor(bulletPointColor)
                                Text("Record your video reminder")
                            }
                            HStack {
                                Image(systemName: "3.circle.fill")
                                    .foregroundColor(bulletPointColor)
                                Text("Save the video to your library")
                            }
                        }
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 14)
                            .fill(newCardBackground)

                    )
                    .padding(.bottom, 40)
                }
                .padding()
            }
            .navigationTitle("Video Recorder")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .buttonStyle(.plain)
                    .foregroundStyle(.primary)
                }
            }

            .sheet(isPresented: $showingImagePicker) {
                ImagePicker(sourceType: .camera, mediaTypes: ["public.movie"], onVideoRecorded: { url in
                    recordedVideoURL = url
                    videoRecorded.toggle()
                })
            }
            .sheet(isPresented: $videoRecorded, onDismiss: saveReminder){
                AddTitleSheet(title: $title)
                    .presentationDetents([.medium])
            }

        }
    }
    func saveReminder() {
        let reminder = Reminder(
            title: title,
            text: "",
            link: ""
        )
        reminder.isChecked = true
        modelContext.insert(reminder)

        loadVideo(reminder)

        dismiss()
    }


    func loadVideo(_ reminder: Reminder) {
        Task {
            if let url = recordedVideoURL {
                // Generate thumbnail immediately
                if let thumbnail = await generateThumbnail(from: url) {
                    reminder.photo = thumbnail.jpegData(compressionQuality: 0.8)
                }

                // Upload video in background
                await uploadVideoToFirebase(videoURL: url, reminder: reminder)
            }
        }
    }

    // Generate thumbnail from video URL
    private func generateThumbnail(from videoURL: URL) async -> UIImage? {
        let asset = AVURLAsset(url: videoURL)
        let generator = AVAssetImageGenerator(asset: asset)
        generator.appliesPreferredTrackTransform = true

        // Get thumbnail at 0.1 seconds (very fast)
        let time = CMTime(seconds: 0.1, preferredTimescale: 600)

        do {
            let cgImage = try await generator.image(at: time).image
            return UIImage(cgImage: cgImage)
        } catch {
            print("Thumbnail generation error: \(error)")
            return nil
        }
    }

    func uploadVideoToFirebase(videoURL: URL, reminder: Reminder) async {
        uploadManager.startUpload(videoURL: videoURL){ result in
            switch result {
            case .success(let firebaseURL):
                reminder.firebaseVideoURL = firebaseURL

            case .failure(let error):
                print("Firebase upload failed: \(error.localizedDescription)")
            }
        }
    }
    

}

// UIImagePickerController wrapper for SwiftUI
struct ImagePicker: UIViewControllerRepresentable {
    @Environment(\.dismiss) var dismiss

    let sourceType: UIImagePickerController.SourceType
    let mediaTypes: [String]
    let onVideoRecorded: (URL) -> Void
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = sourceType
        picker.mediaTypes = mediaTypes
        picker.videoQuality = .typeHigh
        picker.allowsEditing = false
        picker.delegate = context.coordinator
        
        // Default to front camera (selfie mode)
        picker.cameraDevice = .front
        
        // Respect user camera settings (don't override mirroring, etc.)
        picker.cameraCaptureMode = .video
        
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    func dimissImagePicker(){
        dismiss()
    }

    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let videoURL = info[.mediaURL] as? URL {
                // Video was recorded, call the callback
                parent.onVideoRecorded(videoURL)
                parent.dismiss()

            }
            picker.dismiss(animated: true)
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true)
        }
        
        // Allow camera switching during recording
        func imagePickerController(_ picker: UIImagePickerController, didChangeCameraDevice cameraDevice: UIImagePickerController.CameraDevice) {
            // This method is called when user switches between front/back camera
            // The picker automatically handles the switch, we just let it happen
        }
    }
}

#Preview {
    VideoRecorderView()
}
