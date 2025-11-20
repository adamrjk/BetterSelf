import SwiftUI
import AVFoundation
import UIKit

struct CustomCameraView: UIViewControllerRepresentable {
//    var dismiss: () -> Void
    let onVideoRecorded: (URL, Bool) -> Void

    func makeUIViewController(context: Context) -> CameraViewController {
        let controller = CameraViewController()
        controller.onVideoRecorded = onVideoRecorded
//        controller.onDismiss = {
//            dismiss()
//        }
        return controller
    }
    
    func updateUIViewController(_ uiViewController: CameraViewController, context: Context) {
        // No updates needed
    }
}

class CameraViewController: UIViewController {
    var onVideoRecorded: ((URL, Bool) -> Void)?
    var onDismiss: (() -> Void)?
    var isFront = true

    private let cameraManager = CameraManager()
    private var previewLayer: AVCaptureVideoPreviewLayer?
    private var recordButton: UIButton!
    private var closeButton: UIButton!
    private var recordingIndicator: UIView!
    private var redCircle: UIView!
    private var redCircleWidthConstraint: NSLayoutConstraint!
    private var redCircleHeightConstraint: NSLayoutConstraint!
    private var isRecording = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        setupCamera()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Don't start session here - let the manager handle it after setup
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        cameraManager.stopSession()
    }
    
    private func setupCamera() {
        cameraManager.setupCamera { [weak self] success in
            DispatchQueue.main.async {
                if success {
                    self?.setupPreviewLayer()
                    self?.cameraManager.startSession()
                } else {
                    self?.showCameraError()
                }
            }
        }
    }
    
    private func setupPreviewLayer() {
        guard let previewLayer = cameraManager.getPreviewLayer() else { return }
        
        previewLayer.frame = view.bounds
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.insertSublayer(previewLayer, at: 0)
        self.previewLayer = previewLayer
        
        // Ensure UI elements are on top of the preview layer
        view.bringSubviewToFront(closeButton)
        view.bringSubviewToFront(recordButton)
        view.bringSubviewToFront(recordingIndicator)
    }
    
    private func setupUI() {
        view.backgroundColor = .black
        
        // Close button
        closeButton = UIButton(type: .system)
        closeButton.setTitle("Cancel", for: .normal)
        closeButton.tintColor = .white
        closeButton.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        closeButton.layer.cornerRadius = 20
        closeButton.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
        view.addSubview(closeButton)
        
        
        // Record button
        recordButton = UIButton(type: .custom)

        recordButton.backgroundColor = UIColor(red: 0.3, green: 0.3, blue: 0.3, alpha: 1.0)
        recordButton.layer.cornerRadius = 35
        recordButton.layer.borderWidth = 0
        recordButton.layer.shadowColor = UIColor.black.cgColor
        recordButton.layer.shadowOffset = CGSize(width: 0, height: 2)
        recordButton.layer.shadowRadius = 4
        recordButton.layer.shadowOpacity = 0.3
        recordButton.addTarget(self, action: #selector(recordButtonTapped), for: .touchUpInside)
        recordButton.isHidden = false
        recordButton.alpha = 1.0
        recordButton.isUserInteractionEnabled = true
        NSLayoutConstraint.activate([
            recordButton.widthAnchor.constraint(equalToConstant: 72),
            recordButton.heightAnchor.constraint(equalToConstant: 72)

            ])



        // Add red inner circle
        redCircle = UIView()
        redCircle.backgroundColor = .red
        redCircle.layer.cornerRadius = 30
        redCircle.translatesAutoresizingMaskIntoConstraints = false
        redCircle.isUserInteractionEnabled = false
        recordButton.addSubview(redCircle)
        
        redCircleWidthConstraint = redCircle.widthAnchor.constraint(equalToConstant: 60)
        redCircleHeightConstraint = redCircle.heightAnchor.constraint(equalToConstant: 60)
        
        NSLayoutConstraint.activate([
            redCircle.centerXAnchor.constraint(equalTo: recordButton.centerXAnchor),
            redCircle.centerYAnchor.constraint(equalTo: recordButton.centerYAnchor),
            redCircleWidthConstraint,
            redCircleHeightConstraint
        ])
        
        view.addSubview(recordButton)
        
        // Recording indicator
        recordingIndicator = UIView()
        recordingIndicator.backgroundColor = .red
        recordingIndicator.layer.cornerRadius = 4
        recordingIndicator.isHidden = true
        view.addSubview(recordingIndicator)
    }
    
    private func setupConstraints() {
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        recordButton.translatesAutoresizingMaskIntoConstraints = false
        recordingIndicator.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            // Close button
            closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            closeButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            closeButton.widthAnchor.constraint(equalToConstant: 80),
            closeButton.heightAnchor.constraint(equalToConstant: 40),
            
            // Record button
            recordButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            recordButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -50),
//            recordButton.widthAnchor.constraint(equalToConstant: 80),
//            recordButton.heightAnchor.constraint(equalToConstant: 80),
            
            // Recording indicator
            recordingIndicator.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            recordingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            recordingIndicator.widthAnchor.constraint(equalToConstant: 8),
            recordingIndicator.heightAnchor.constraint(equalToConstant: 8)
        ])
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        previewLayer?.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: view.bounds.height)
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override var prefersHomeIndicatorAutoHidden: Bool {
        return true
    }
    
    @objc private func closeButtonTapped() {
        onDismiss?()
    }
    
    @objc private func flipCameraTapped() {
        isFront.toggle()
        cameraManager.flipCamera()
    }
    
    @objc private func recordButtonTapped() {
        if isRecording {
            stopRecording()
        } else {
            startRecording()
        }
    }
    
    private func startRecording() {
        cameraManager.startRecording { [weak self] success in
            DispatchQueue.main.async {
                if success {
                    self?.isRecording = true
                    self?.updateRecordingUI()
                }
            }
        }
    }
    
    private func stopRecording() {
        cameraManager.stopRecording { [weak self] url in
            DispatchQueue.main.async {
                self?.isRecording = false
                self?.updateRecordingUI()
                if let url = url {
                    self?.onVideoRecorded?(url, self?.isFront ?? true)
                }
                self?.onDismiss?()
            }
        }
    }
    
    private func updateRecordingUI() {
        if isRecording {
            // Hide red circle and show red rounded rectangle
            UIView.animate(withDuration: 0.2, delay: 0, options: [.curveEaseIn, .beginFromCurrentState], animations: {
                self.redCircle.layer.cornerRadius = 17
                self.redCircleWidthConstraint.constant = 45
                self.redCircleHeightConstraint.constant = 45
                self.view.layoutIfNeeded()
            })
            recordingIndicator.isHidden = false
            
            // Add pulsing animation to recording indicator
            let pulseAnimation = CABasicAnimation(keyPath: "opacity")
            pulseAnimation.fromValue = 1.0
            pulseAnimation.toValue = 0.3
            pulseAnimation.duration = 0.8
            pulseAnimation.repeatCount = .infinity
            pulseAnimation.autoreverses = true
            recordingIndicator.layer.add(pulseAnimation, forKey: "pulse")
        } else {
            // Show red circle and hide red rounded rectangle
            UIView.animate(withDuration: 1, delay: 0, options: [.curveEaseIn, .beginFromCurrentState], animations: {
                self.redCircle.layer.cornerRadius = 30
                self.redCircleWidthConstraint.constant = 60
                self.redCircleHeightConstraint.constant = 60
                self.view.layoutIfNeeded()
            })
            recordingIndicator.isHidden = true
            recordingIndicator.layer.removeAllAnimations()
        }
    }
    
    private func showCameraError() {
        let alert = UIAlertController(title: "Camera Error", message: "Unable to access camera. Please check permissions.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            self.onDismiss?()
        })
        present(alert, animated: true)
    }
}
