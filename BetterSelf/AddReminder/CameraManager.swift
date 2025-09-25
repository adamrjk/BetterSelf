import AVFoundation
import UIKit

class CameraManager: NSObject {
    private var captureSession: AVCaptureSession?
    private var videoDeviceInput: AVCaptureDeviceInput?
    private var audioDeviceInput: AVCaptureDeviceInput?
    private var movieFileOutput: AVCaptureMovieFileOutput?
    private var previewLayer: AVCaptureVideoPreviewLayer?
    
    private var currentCameraPosition: AVCaptureDevice.Position = .front
    private var isSessionConfigured = false
    
    override init() {
        super.init()
        setupCaptureSession()
    }
    
    private func setupCaptureSession() {
        captureSession = AVCaptureSession()
        guard let captureSession = captureSession else { return }
        
        // Configure session preset for high quality video
        if captureSession.canSetSessionPreset(.high) {
            captureSession.sessionPreset = .high
        }
    }
    
    func setupCamera(completion: @escaping (Bool) -> Void) {
        guard captureSession != nil else {
            completion(false)
            return
        }
        
        // Request camera permission
        AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
            guard granted else {
                completion(false)
                return
            }
            
            // Request microphone permission
            AVCaptureDevice.requestAccess(for: .audio) { granted in
                guard granted else {
                    completion(false)
                    return
                }
                
                self?.configureCaptureSession(completion: completion)
            }
        }
    }
    
    private func configureCaptureSession(completion: @escaping (Bool) -> Void) {
        guard let captureSession = captureSession else {
            completion(false)
            return
        }
        
        // Ensure we're not already configuring
        guard !isSessionConfigured else {
            completion(true)
            return
        }
        
        captureSession.beginConfiguration()
        
        // Add video input
        guard let videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: currentCameraPosition),
              let videoDeviceInput = try? AVCaptureDeviceInput(device: videoDevice),
              captureSession.canAddInput(videoDeviceInput) else {
            captureSession.commitConfiguration()
            completion(false)
            return
        }
        
        captureSession.addInput(videoDeviceInput)
        self.videoDeviceInput = videoDeviceInput
        
        // Add audio input
        guard let audioDevice = AVCaptureDevice.default(for: .audio),
              let audioDeviceInput = try? AVCaptureDeviceInput(device: audioDevice),
              captureSession.canAddInput(audioDeviceInput) else {
            captureSession.commitConfiguration()
            completion(false)
            return
        }
        
        captureSession.addInput(audioDeviceInput)
        self.audioDeviceInput = audioDeviceInput
        
        // Add movie file output
        let movieFileOutput = AVCaptureMovieFileOutput()
        if captureSession.canAddOutput(movieFileOutput) {
            captureSession.addOutput(movieFileOutput)
            self.movieFileOutput = movieFileOutput
            
            // Configure video settings
            if let connection = movieFileOutput.connection(with: .video) {
                if connection.isVideoStabilizationSupported {
                    connection.preferredVideoStabilizationMode = .auto
                }
                
                if connection.isVideoOrientationSupported {
                    connection.videoOrientation = .portrait
                }
            }
        }
        
        // Create preview layer
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer?.videoGravity = .resizeAspectFill
        
        captureSession.commitConfiguration()
        isSessionConfigured = true
        completion(true)
    }
    
    func getPreviewLayer() -> AVCaptureVideoPreviewLayer? {
        return previewLayer
    }
    
    func startSession() {
        guard let captureSession = captureSession, !captureSession.isRunning, isSessionConfigured else { return }
        
        DispatchQueue.global(qos: .userInitiated).async {
            captureSession.startRunning()
        }
    }
    
    func stopSession() {
        guard let captureSession = captureSession, captureSession.isRunning else { return }
        
        DispatchQueue.global(qos: .userInitiated).async {
            captureSession.stopRunning()
        }
    }
    
    func flipCamera() {
        guard let captureSession = captureSession, isSessionConfigured else { return }
        
        captureSession.beginConfiguration()
        
        // Remove current video input
        if let videoDeviceInput = videoDeviceInput {
            captureSession.removeInput(videoDeviceInput)
        }
        
        // Switch camera position
        currentCameraPosition = currentCameraPosition == .back ? .front : .back
        
        // Add new video input
        guard let videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: currentCameraPosition),
              let newVideoDeviceInput = try? AVCaptureDeviceInput(device: videoDevice),
              captureSession.canAddInput(newVideoDeviceInput) else {
            captureSession.commitConfiguration()
            return
        }
        
        captureSession.addInput(newVideoDeviceInput)
        videoDeviceInput = newVideoDeviceInput
        
        // Update video orientation
        if let movieFileOutput = movieFileOutput,
           let connection = movieFileOutput.connection(with: .video),
           connection.isVideoOrientationSupported {
            connection.videoOrientation = .portrait
        }
        
        captureSession.commitConfiguration()
    }
    
    func startRecording(completion: @escaping (Bool) -> Void) {
        guard let movieFileOutput = movieFileOutput, !movieFileOutput.isRecording else {
            completion(false)
            return
        }
        
        // Generate unique filename
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileName = "video_\(Date().timeIntervalSince1970).mov"
        let outputURL = documentsPath.appendingPathComponent(fileName)
        
        // Start recording
        movieFileOutput.startRecording(to: outputURL, recordingDelegate: self)
        completion(true)
    }
    
    func stopRecording(completion: @escaping (URL?) -> Void) {
        guard let movieFileOutput = movieFileOutput, movieFileOutput.isRecording else {
            completion(nil)
            return
        }
        
        // Store completion handler for delegate
        recordingCompletion = completion
        movieFileOutput.stopRecording()
    }
    
    // Store completion handler for recording delegate
    private var recordingCompletion: ((URL?) -> Void)?
}

// MARK: - AVCaptureFileOutputRecordingDelegate
extension CameraManager: AVCaptureFileOutputRecordingDelegate {
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        if let error = error {
            print("Recording error: \(error.localizedDescription)")
            recordingCompletion?(nil)
        } else {
            recordingCompletion?(outputFileURL)
        }
        recordingCompletion = nil
    }
}
