//
//  ReminderRowView.swift
//  BetterSelf
//
//  Created by Adam Damou on 05/09/2025.
//

import SwiftUI

struct ReminderRowView: View {
    let reminder: Reminder

    @State var isPreview: Bool
    var body: some View {
        HStack(spacing: 16) {
            // Left thumbnail with improved design
            if let image = loadImage(reminder) {
                image
                    .resizable()
                    .scaledToFill()
                    .frame(width: isPreview ? 40 : 80, height: isPreview ? 40 : 80)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.white.opacity(0.3), lineWidth: 1)
                    )
                    .shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 4)
            }
            // Content section with improved typography
            VStack(alignment: .leading, spacing: 6) {
                Text(reminder.title)
                    .font(isPreview ? .subheadline : .headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)

                Text(reminder.text)
                    .font(isPreview ? .caption : .subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(3)
                    .fixedSize(horizontal: false, vertical: true)
                    .multilineTextAlignment(.leading)
            }

            Spacer()
            if !isPreview {
                VStack(spacing: 4) {
                    if !reminder.text.isEmpty { ElementIndicatorView(systemName: "text.quote")}

                    if reminder.firebaseVideoURL != nil { ElementIndicatorView(systemName: "video.fill")}
                    else if reminder.type == .EchoSnap && reminder.photo != nil { ElementIndicatorView(systemName: "photo.fill") }

                    if !reminder.link.isEmpty { ElementIndicatorView(systemName: "link.circle.fill")}
                }
            }



        }
        .padding(.vertical, isPreview ? 7 : 14)
        .padding(.horizontal, isPreview ? 8 : 16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.1))
//                                            .overlay(
//                                                RoundedRectangle(cornerRadius: 16)
//                                                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
//                                            )
        )
        .shadow(color: .black.opacity(0.08), radius: 12, x: 0, y: 6)

    }

    func loadImage(_ reminder: Reminder) -> Image? {

        guard let data = reminder.photo, let uiImage = UIImage(data: data) else {
            return nil
        }
        return Image(uiImage: uiImage)
    }
}

#Preview {
    ReminderRowView(reminder: .example, isPreview: true)
}
