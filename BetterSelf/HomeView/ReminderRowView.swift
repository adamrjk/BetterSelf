//
//  ReminderRowView.swift
//  BetterSelf
//
//  Created by Adam Damou on 05/09/2025.
//

import SwiftUI

struct ReminderRowView: View {
    @State var reminder: Reminder
    
    @State var isPreview: Bool
    @StateObject var color = ColorManager.shared
    @Environment(\.colorScheme) var scheme


    var body: some View {



        HStack(spacing: 16) {
            // Left thumbnail with improved design
            if let image = loadImage(reminder) {
                image
                    .resizable()
                    .rotation3DEffect(.degrees(reminder.isFront ? 180 : 0), axis: (x: 0, y: 1, z: 0))
                    .scaledToFill()
                    .frame(width: isPreview ? 40 : 80, height: isPreview ? 40 : 80)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.white.opacity(0.3), lineWidth: 1)
                    )
                    .shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 4)
            }
            else if reminder.isYoutube {

                YouTubeThumbnailView(videoURL: reminder.link, type: isPreview ? .preview : .reminderRow)



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
                    if reminder.pinned {
                        Image(systemName: "pin.fill")
                            .font(.caption)
                            .foregroundStyle(.orange)
                            .fontWeight(.medium)
                            .padding(1)
                    }


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
        )
        .shadow(color: .black.opacity(0.08), radius: 12, x: 0, y: 6)


    }

    func loadImage(_ reminder: Reminder) -> Image? {

        guard let data = reminder.photo, let uiImage = UIImage(data: data) else {
            return nil
        }
        return Image(uiImage: uiImage)
    }
    func getId(_ link: String) -> String? {
        let patterns = [
              "youtube\\.com/watch\\?v=([a-zA-Z0-9_-]{11})",
              "youtu\\.be/([a-zA-Z0-9_-]{11})",
              "youtube\\.com/embed/([a-zA-Z0-9_-]{11})"
          ]

          for pattern in patterns {
              if let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive) {
                  let range = NSRange(link.startIndex..<link.endIndex, in: link)
                  if let match = regex.firstMatch(in: link, options: [], range: range) {
                      if let idRange = Range(match.range(at: 1), in: link) {
                          return String(link[idRange])
                      }
                  }
              }
          }
          return nil

    }
}

#Preview {
    ReminderRowView(reminder: .example, isPreview: true)
}
