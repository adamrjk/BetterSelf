import SwiftUI
import UIKit
import Photos
import AVKit

struct VideoRecorderView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) var modelContext

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


    @StateObject private var uploadManager = UploadManager.shared


    @State private var showingImagePicker = false
    @State private var recordedVideoURL: URL?
    @State private var title = ""
    @State private var videoRecorded = false

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
                            .fill(Color.cardBackground)

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
                        .background(Color.cardBackground)
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
                            .fill(Color.cardBackground)

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
//                .ignoresSafeArea()
            }
            .sheet(isPresented: $videoRecorded){
                NavigationView {
                    ZStack {
                        Color.purpleMainGradient
                            .ignoresSafeArea()
                        Color.purpleOverlayGradient
                            .ignoresSafeArea()


                        VStack(spacing: 20){
                            Spacer()

                            VStack(alignment: .leading, spacing: 12) {

                                CleanText("Title")
                                TextField("Enter title...", text: $title)
                                    .padding(12)
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
                                    .fill(Color.cardBackground)
                                    .shadow(color: .black.opacity(0.08), radius: 8, y: 4)
                            )
                            .padding(.horizontal, 16)
                            Spacer()
                            Spacer()

                        }
                        .padding(.top, 20)
                        .navigationTitle("Add a Title")
                        .toolbar {
                            ToolbarItem(placement: .navigationBarTrailing) {
                                Button{
                                    let reminder = Reminder(
                                        title: title,
                                        text: "",
                                        link: ""
                                    )
                                    reminder.isChecked = true
                                    modelContext.insert(reminder)
                                    
                                    loadVideo(reminder)
                                    dismiss()
                                } label: {
                                    Text("Save")
                                        .foregroundStyle(.primary)

                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                }
                .presentationDetents([.medium])
            }
        }
    }

    func loadVideo(_ reminder: Reminder) {
        Task {
            if let url = recordedVideoURL {
                await uploadVideoToFirebase(videoURL: url, reminder: reminder)
            }
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
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let videoURL = info[.mediaURL] as? URL {
                // Video was recorded, call the callback
                parent.onVideoRecorded(videoURL)
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
