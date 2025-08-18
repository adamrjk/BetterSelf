import SwiftUI
import UIKit
import Photos

struct VideoRecorderView: View {
    @Environment(\.dismiss) var dismiss
    @State private var showingImagePicker = false
    @State private var recordedVideoURL: URL?
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Header
                VStack(spacing: 12) {
                    Image(systemName: "video.circle.fill")
                        .font(.system(size: 60))
                        .foregroundStyle(Color.purpleMainGradient)
                    
                    Text("Record Video Reminder")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    Text("Tap the button below to open the camera and record your video reminder")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                .padding(.top, 40)
                
                Spacer()
                
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
                    .foregroundColor(.white)
                    .padding(.horizontal, 30)
                    .padding(.vertical, 16)
                    .background(Color.purpleMainGradient)
                    .cornerRadius(25)
                    .shadow(color: .black.opacity(0.2), radius: 8, y: 4)
                }
                
                Spacer()
                
                // Instructions
                VStack(spacing: 8) {
                    Text("How it works:")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Image(systemName: "1.circle.fill")
                                .foregroundColor(.blue)
                            Text("Tap 'Start Recording' to open camera")
                        }
                        HStack {
                            Image(systemName: "2.circle.fill")
                                .foregroundColor(.blue)
                            Text("Record your video reminder")
                        }
                        HStack {
                            Image(systemName: "3.circle.fill")
                                .foregroundColor(.blue)
                            Text("Save the video to your library")
                        }
                    }
                    .font(.caption)
                    .foregroundColor(.secondary)
                }
                .padding(.bottom, 40)
            }
            .padding()
            .navigationTitle("Video Recorder")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
        .sheet(isPresented: $showingImagePicker) {
            ImagePicker(sourceType: .camera, mediaTypes: ["public.movie"], onVideoRecorded: { url in
                recordedVideoURL = url
                // Here you would typically save the video URL to your reminder
                // For now, we'll just dismiss the recorder
                dismiss()
            })
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
    }
}

#Preview {
    VideoRecorderView()
}
