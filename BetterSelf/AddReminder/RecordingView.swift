//
//  RecordingView.swift
//  BetterSelf
//
//  Created by Adam Damou on 21/09/2025.
//

import Aespa
import SwiftUI
import AVKit

struct RecordingView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var viewModel: RecordingViewModel

    @State var isRecording = false
    @State var isFront = true

    @StateObject var color = ColorManager.shared

    let onVideoRecorded: (URL, Bool) -> Void

    var body: some View {
        NavigationStack {
            ZStack {
                viewModel.preview
                    .frame(minWidth: 0,
                           maxWidth: .infinity,
                           minHeight: 0,
                           maxHeight: .infinity)
                    .edgesIgnoringSafeArea(.all)

                VStack {
                    Spacer()

                    ZStack {
                        HStack {

                            Spacer()

                            // Position change + button
                            Button(action: {
                                viewModel.aespaSession.common(.position(position: isFront ? .back : .front))
                                isFront.toggle()


                            }) {
                                Image(systemName: "arrow.triangle.2.circlepath.camera.fill")
                                    .resizable()
                                    .foregroundColor(.white)
                                    .scaledToFit()
                                    .frame(width: 50, height: 50)
                                    .padding(20)
                                    .padding(.trailing, 20)
                            }
                            .shadow(radius: 5)
                            .contentShape(Rectangle())
                        }

                        // Shutter + button
                        recordingButtonShape(width: 60).onTapGesture {
                            if isRecording {
                                viewModel.aespaSession.stopRecording{ result in
                                    switch result {
                                    case .success(let videoFile):
                                        if let url = videoFile.path {

                                            onVideoRecorded(url, isFront)


                                        }
                                        else {
                                            print("No Valid URL")
                                        }
                                        dismiss()
                                    case .failure(let error):
                                        print("Error \(error.localizedDescription)")
                                        dismiss()
                                    }


                                }
                                isRecording = false
                            } else {
                                viewModel.aespaSession.video(.unmute)


                                viewModel.aespaSession.startRecording(autoVideoOrientationEnabled: true)

                                isRecording = true
                            }
                        }
                    }
                }
            }
            .animation(.easeInOut(duration: 0.5), value: isRecording)
            .navigationTitle("Video Recorder")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button{
                        dismiss()
                    } label: {
                        Text("Cancel")
                            .frame(minWidth: 70)

                            .clipShape(.capsule)

                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}
extension RecordingView {
    @ViewBuilder
    func roundRectangleShape(with image: Image, size: CGFloat) -> some View {
        image
            .resizable()
            .scaledToFill()
            .frame(width: size, height: size, alignment: .center)
            .clipped()
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(.white, lineWidth: 1)
            )
            .padding(20)
    }

    @ViewBuilder
    func recordingButtonShape(width: CGFloat) -> some View {
        ZStack {


            Circle()
                .strokeBorder( .gray, lineWidth: 3)
                .frame(width: width, height: width)
            if isRecording {
                RoundedRectangle(cornerRadius: 15)
                    .fill(.red)
                    .frame(width: width * 0.6, height: width * 0.6)
            }
            else{
                Circle()
                    .fill(.red )
                    .frame(width: width * 0.8, height: width * 0.8)
            }

        }
    }
}

//#Preview {
//    RecordingView()
//}
