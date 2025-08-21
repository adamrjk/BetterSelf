//
//  EchoSnapView.swift
//  BetterSelf
//
//  Created by Adam Damou on 20/08/2025.
//

import SwiftUI

struct EchoSnapView: View {
    @State var reminder: Reminder
    var body: some View {

            ZStack {
                Color.purpleMainGradient
                    .ignoresSafeArea()

                Color.purpleOverlayGradient
                    .ignoresSafeArea()
                ScrollView {
                        VStack(spacing: 16) {


                            if let image = loadImage(reminder.photo) {
                                VStack(alignment: .leading, spacing: 8){
                                    Text("Photo")
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                    image
                                        .resizable()
                                        .scaledToFit()
                                        .clipped()
                                        .cornerRadius(14)
                                }
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                                        .fill(Color.cardBackground)
                                )
                                .shadow(color: .black.opacity(0.05), radius: 6, y: 2)
                            }
                            Spacer()
                                .frame(height: 20)
                            if !reminder.text.isEmpty {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Description")
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)

                                    Text(reminder.text)
                                        .font(.subheadline)
                                        .multilineTextAlignment(.leading)

                                }
                                .padding()
                                .frame(minWidth: 350)
                                .background(
                                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                                        .fill(Color.cardBackground)

                                )
                                .shadow(color: .black.opacity(0.05), radius: 6, y: 2)



                            }

                            if !reminder.link.isEmpty {
                                Spacer()
                                    .frame(height: 30)
                                Button {
                                    launchLink()
                                } label: {
                                    Text("Access Link")
                                        .font(.subheadline)
                                        .bold()
                                        .foregroundStyle(.secondary)
                                        .padding()
                                        .background(Color.cardBackground)
                                        .clipShape(.rect(cornerRadius: 14))
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.horizontal)
                    
                }
                .defaultScrollAnchor(.center)


            }


    }

    func launchLink() {
        //Either show a sheet or navlink with the link result
        // or Show an actual WebView with the link result
    }

    func loadImage(_ data: Data?) -> Image? {
        guard let data,
              let uiImage = UIImage(data: data) else {
            return nil
        }
        return Image(uiImage: uiImage)
    }

}

#Preview {
    EchoSnapView(reminder: .example)
}
