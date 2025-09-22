//
//  RecordingViewModel.swift
//  BetterSelf
//
//  Created by Adam Damou on 21/09/2025.
//

@preconcurrency import Aespa
import SwiftUI
import Foundation
import Combine

class RecordingViewModel: ObservableObject {
    let aespaSession: AespaSession
    

    var preview: some View {
        aespaSession.interactivePreview()

        // Or you can give some options
        //        let option = InteractivePreviewOption(enableZoom: true)
        //        return aespaSession.interactivePreview(option: option)
    }

    private var subscription = Set<AnyCancellable>()

    @Published var videoAlbumCover: Image?
    @Published var videoFiles: [VideoAsset] = []

    init() {
        let option = AespaOption(albumName: nil)
        self.aespaSession = Aespa.session(with: option)

        // Common setting
        aespaSession
            .common(.position(position: .front))
            .common(.focus(mode: .continuousAutoFocus))
            .common(.changeMonitoring(enabled: true))
            .common(.orientation(orientation: .portrait))
            .common(.quality(preset: .high))
//            .common(.custom(tuner: WideColorCameraTuner())) { result in
//                if case .failure(let error) = result {
//                    print("Error: ", error)
//                }
//            }

        aespaSession
            .video(.unmute)
//            .video(.stabilization(mode: .standard))



    }
}
extension RecordingViewModel {
    // Example for using custom session tuner
    struct WideColorCameraTuner: AespaSessionTuning {
        func tune<T>(_ session: T) throws where T : AespaCoreSessionRepresentable {
            session.avCaptureSession.automaticallyConfiguresCaptureDeviceForWideColor = true
        }
    }
}

