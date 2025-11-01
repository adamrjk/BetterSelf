//
//  AudioRecorderView.swift
//  BetterSelf
//
//  Created by Cursor on 01/11/2025.
//

import SwiftUI
import AVFoundation
import Speech

final class SpeechRecognizerManager: NSObject, ObservableObject {
    @Published var transcript: String = ""
    @Published var isRecording: Bool = false
    @Published var permissionDenied: Bool = false

    private let audioEngine = AVAudioEngine()
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let speechRecognizer = SFSpeechRecognizer()

    func requestPermissions() async -> Bool {
        let micGranted = await withCheckedContinuation { (continuation: CheckedContinuation<Bool, Never>) in
            AVAudioApplication.requestRecordPermission { granted in
                continuation.resume(returning: granted)
            }
        }

        if !micGranted {
            DispatchQueue.main.async { self.permissionDenied = true }
            return false
        }

        let speechAuth = await withCheckedContinuation { (continuation: CheckedContinuation<SFSpeechRecognizerAuthorizationStatus, Never>) in
            SFSpeechRecognizer.requestAuthorization { status in
                continuation.resume(returning: status)
            }
        }

        let allowed = speechAuth == .authorized
        if !allowed {
            DispatchQueue.main.async { self.permissionDenied = true }
        }
        return allowed
    }

    func startRecording() throws {
        guard !isRecording else { return }

        transcript = ""
        permissionDenied = false

        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
        try audioSession.setActive(true, options: .notifyOthersOnDeactivation)

        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        recognitionRequest?.shouldReportPartialResults = true

        guard let recognitionRequest else { throw NSError(domain: "Speech", code: -1) }
        guard let recognizer = speechRecognizer, recognizer.isAvailable else { throw NSError(domain: "Speech", code: -2) }

        let inputNode = audioEngine.inputNode

        recognitionTask = recognizer.recognitionTask(with: recognitionRequest) { [weak self] result, error in
            guard let self = self else { return }
            if let result = result {
                DispatchQueue.main.async {
                    self.transcript = result.bestTranscription.formattedString
                }
                if result.isFinal {
                    self.stopRecording()
                }
            }
            if error != nil {
                self.stopRecording()
            }
        }

        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { [weak self] buffer, _ in
            self?.recognitionRequest?.append(buffer)
        }

        audioEngine.prepare()
        try audioEngine.start()

        DispatchQueue.main.async {
            self.isRecording = true
        }
    }

    func stopRecording() {
        guard isRecording else { return }
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        recognitionRequest?.endAudio()
        recognitionTask?.cancel()
        recognitionTask = nil
        recognitionRequest = nil
        DispatchQueue.main.async {
            self.isRecording = false
        }
    }
}

struct AudioRecorderView: View {
    @StateObject private var speech = SpeechRecognizerManager()

    // Optional: expose the final transcript to parent
    var onTranscription: ((String) -> Void)? = nil

    var body: some View {
        VStack(spacing: 16) {
            if !speech.transcript.isEmpty && !speech.isRecording {
                Text(speech.transcript)
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(Color(.secondarySystemBackground))
                    )
                    .onAppear {
                        onTranscription?(speech.transcript)
                    }

                Button("Clear") {
                    speech.transcript = ""
                }
                .buttonStyle(.bordered)
            } else {
                Button(action: toggleRecording) {
                    ZStack {
                        Circle()
                            .fill(speech.isRecording ? Color.red : Color.accentColor)
                            .frame(width: 64, height: 64)

                        Image(systemName: speech.isRecording ? "stop.fill" : "mic.fill")
                            .foregroundStyle(.white)
                            .font(.title2)
                    }
                }
                .buttonStyle(.plain)

                Text(speech.isRecording ? "Listening..." : "Tap to speak")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }

            if speech.permissionDenied {
                Text("Microphone and Speech permissions are required.")
                    .foregroundStyle(.red)
                    .font(.footnote)
            }
        }
    }

    private func toggleRecording() {
        if speech.isRecording {
            speech.stopRecording()
        } else {
            Task {
                let permitted = await speech.requestPermissions()
                if permitted {
                    do { try speech.startRecording() } catch { }
                }
            }
        }
    }
}


