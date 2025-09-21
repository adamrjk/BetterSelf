//
//  StartTimeView.swift
//  BetterSelf
//
//  Created by Adam Damou on 15/09/2025.
//

import SwiftUI

struct StartTimeView: View {
    @Environment(\.dismiss) var dismiss

    @Binding var time: Int
    @State private var seconds: Int
    @State private var minutes: Int
    @State private var hours: Int
    @Environment(\.colorScheme) var colorScheme
    var body: some View {
        NavigationStack {
            ZStack {
                Color.purpleMainGradient
                    .ignoresSafeArea()
                Color.purpleOverlayGradient
                    .ignoresSafeArea()

                TimeSelector(time: $time, seconds: $seconds, minutes: $minutes, hours: $hours)

                
            }
            .navigationTitle("Select Start Time")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing){
                    Button{
                        time = hours * 3600 + minutes * 60 + seconds
                        dismiss()
                        
                    } label: {
                        Text("Ok")
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
    init(time: Binding<Int>) {
        _time = time
        let seconds = time.wrappedValue
        hours = seconds / 3600
        minutes = ( seconds % 3600 ) / 60
        self.seconds = seconds % 60



    }

}


struct TimeSelector: View {
    @Binding var time: Int
    @Binding var seconds: Int
    @Binding  var minutes: Int
    @Binding var hours: Int
    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            VStack(alignment: .leading, spacing: 12) {

                HStack(spacing: 0) {
                    Picker("Hours", selection: $hours) {
                        ForEach(0..<4, id: \.self) { hour in
                            Text("\(hour) h").tag(hour)
                        }
                    }
                    .pickerStyle(.wheel)
                    .frame(width: 50, height: 150)
                    .clipped()
                    Picker("Minutes", selection: $minutes) {
                        ForEach(0..<60, id: \.self) { min in
                            Text("\(min) m").tag(min)
                        }
                    }
                    .pickerStyle(.wheel)
                    .frame(width: 100, height: 150)
                    .clipped()

                    Picker("Seconds", selection: $seconds) {
                        ForEach(0..<60, id: \.self) { sec in
                            Text("\(sec) s").tag(sec)
                        }
                    }
                    .pickerStyle(.wheel)
                    .frame(width: 100, height: 150)
                    .clipped()
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(Color(.systemGray6))
                        .shadow(color: .black.opacity(0.08), radius: 8, y: 4)
                )
                .padding(12)



            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color(.systemGray6))
                    .shadow(color: .black.opacity(0.08), radius: 8, y: 4)
            )
            .padding(.horizontal, 16)

            Spacer()
        }
    }
}

#Preview {
    StartTimeView(time: .constant(10))
}
