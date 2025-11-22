//
//  EchoSnapView.swift
//  BetterSelf
//
//  Created by Adam Damou on 20/08/2025.
//

import SwiftUI

struct EchoSnapView: View {
    @State var reminder: Reminder


    @Environment(\.colorScheme) var scheme
    @EnvironmentObject var color: ColorManager

    let isInFeed: Bool


    var body: some View {

            ZStack {
                if isInFeed {
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
                                    .fill(color.cardBackground(scheme))
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
                                    .fill(color.cardBackground(scheme))
                                
                            )
                            .shadow(color: .black.opacity(0.05), radius: 6, y: 2)
                        }
                    }
                    .padding(.horizontal)
                } else {
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
                                        .fill(color.cardBackground(scheme))
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
                                        .fill(color.cardBackground(scheme))

                                )
                                .shadow(color: .black.opacity(0.05), radius: 6, y: 2)



                            }
                        }
                        .padding(.horizontal)
                    }
                    .defaultScrollAnchor(.center)
                }


            }


    }

    func loadImage(_ data: Data?) -> Image? {
        guard let data,
              let uiImage = UIImage(data: data) else {
            return nil
        }
        return Image(uiImage: uiImage)
    }

}

//#Preview {
//    EchoSnapView(reminder: .example)
//}
