//
//  WelcomeView.swift
//  BetterSelf
//
//  Created by Adam Damou on 24/09/2025.
//

import SwiftUI

struct WelcomeView: View {
    @Environment(\.colorScheme) var scheme
    @StateObject var color = ColorManager.shared
    @Environment(\.dismiss) var dismiss


    var body: some View {
        NavigationStack{
            ZStack {
                color.mainGradient(scheme)
                    .ignoresSafeArea()
                color.overlayGradient(scheme)
                    .ignoresSafeArea()
                VStack{
                    Image(systemName: "lightbulb.min.badge.exclamationmark.fill")
                        .font(.largeTitle)
                        .foregroundStyle(color.itemColor(scheme))
                        .padding()
                    Text("Welcome to BetterSelf")
                        .font(.largeTitle)
                        .bold()
                        .padding()


                    Text("Your companion to remember your learnings")
                        .font(.headline)
                        .italic()
                        .multilineTextAlignment(.center)
                        .frame(width: 300)
                        .padding(.bottom)


                    NavigationLink{
                        StoreIdeas(onDismiss: {
                            dismiss()
                        })
                    } label: {
                        Text("Next")
                            .font(.subheadline)
                            .bold()
                            .foregroundStyle(color.text(scheme))
                            .padding()
                            .padding(.horizontal, 10)
                            .background(color.button(scheme))
                            .clipShape(.capsule)


                    }
                    .buttonStyle(.plain)




                }
            }

        }
    }
}


struct StoreIdeas: View{
    @Environment(\.colorScheme) var scheme
    @StateObject var color = ColorManager.shared

    let onDismiss: () -> Void

    
    let elements: [String] = [
        "An Image you care about",
        "A Video of you explaining the idea",
        "A Clip from a Podcast",
        "An Article",
        "A written summary of the idea"
    ]

    var body: some View {
        ZStack {
            color.mainGradient(scheme)
                .ignoresSafeArea()
            color.overlayGradient(scheme)
                .ignoresSafeArea()
            VStack{
                Image(systemName: "square.and.arrow.down.fill")
                    .font(.largeTitle)
                    .foregroundStyle(color.itemColor(scheme))
                    .padding()
                Text("Store Ideas")
                    .font(.largeTitle)
                    .bold()
                    .padding()

                VStack(alignment: .leading, spacing: 15){
                    Text("They can be: ")
                        .font(.headline)
                        .italic()

                    ForEach(elements, id: \.self){ element in
                        HStack {
                            Circle()
                                .fill(Color.primary)
                                .frame(width: 7, height: 7)


                            Text(element)
                                .font(.subheadline)
                                .italic()


                        }

                    }
                }



                NavigationLink{
                    OrganiseIdeas(onDismiss: onDismiss)
                } label: {
                    Text("Next")
                        .font(.subheadline)
                        .bold()
                        .foregroundStyle(color.text(scheme))
                        .padding()
                        .padding(.horizontal, 10)
                        .background(color.button(scheme))
                        .clipShape(.capsule)


                }
                .buttonStyle(.plain)
                .padding(.top)




            }
        }
    }

}

struct OrganiseIdeas: View {
    @Environment(\.colorScheme) var scheme
    @StateObject var color = ColorManager.shared
    let onDismiss: () -> Void

    let elements: [String] = [
        "Work",
        "Health",
        "Family",
        "Books"
    ]

    var body: some View {
        ZStack {
            color.mainGradient(scheme)
                .ignoresSafeArea()
            color.overlayGradient(scheme)
                .ignoresSafeArea()
            VStack{
                Image(systemName: "folder.fill")
                    .font(.largeTitle)
                    .foregroundStyle(color.itemColor(scheme))
                    .padding()
                Text("Organise Them")
                    .font(.largeTitle)
                    .bold()
                    .padding()

                VStack(alignment: .leading, spacing: 15){
                    Text("Have separate spaces for each category:")
                        .font(.headline)
                        .italic()
                        .multilineTextAlignment(.center)
                        .frame(width: 200)

                    ForEach(elements, id: \.self){ element in
                        HStack {
                            Circle()
                                .fill(Color.primary)
                                .frame(width: 7, height: 7)


                            Text(element)
//                                .font(.footnote)
                                .bold()
                                .italic()


                        }

                    }

//                    .multilineTextAlignment(.center)
                }
                HStack {
                    Image(systemName: "lock.fill")

                    Text("Lock with Face ID for privacy")
                        .font(.headline)
                        .italic()

//                        .frame(width: 200)
                }
                .padding()



                NavigationLink{
                    QuickAccess(onDismiss: onDismiss)
                } label: {
                    Text("Next")
                        .font(.subheadline)
                        .bold()
                        .foregroundStyle(color.text(scheme))
                        .padding()
                        .padding(.horizontal, 10)
                        .background(color.button(scheme))
                        .clipShape(.capsule)


                }
                .buttonStyle(.plain)
                .padding(.top)




            }
        }
    }
}

struct QuickAccess: View {
    @Environment(\.colorScheme) var scheme
    @StateObject var color = ColorManager.shared
    let onDismiss: () -> Void

    let elements: [String] = [
        "Daily Notifications",
        "Access From Main View",
        "Access through BetterSelf Widget"
    ]

    let elements2: [String] = [
        "Share directly to BetterSelf",
        "Record a Video Immediately"
    ]

    var body: some View {
        ZStack {
            color.mainGradient(scheme)
                .ignoresSafeArea()
            color.overlayGradient(scheme)
                .ignoresSafeArea()
            VStack{
                Image(systemName: "bolt.fill")
                    .font(.largeTitle)
                    .foregroundStyle(color.itemColor(scheme))
                    .padding()
                Text("Quick Access")
                    .font(.largeTitle)
                    .bold()
                    .padding()

                VStack(alignment: .leading, spacing: 15){
                    Text("Select Reminders To Pin And Get:")
                        .font(.headline)
                        .italic()
                        .multilineTextAlignment(.center)
                        .frame(width: 200)

                    ForEach(elements, id: \.self){ element in
                        HStack {
                            Circle()
                                .fill(Color.primary)
                                .frame(width: 7, height: 7)


                            Text(element)
                                .font(.subheadline)
                                .bold()
                                .italic()


                        }

                    }

                    Text("Quick Add Feature:")
                        .font(.headline)
                        .italic()
                        .multilineTextAlignment(.center)
                        .frame(width: 200)
                        .padding(.top)

                    ForEach(elements2, id: \.self){ element in
                        HStack {
                            Circle()
                                .fill(Color.primary)
                                .frame(width: 7, height: 7)


                            Text(element)
                                .font(.subheadline)
                                .bold()
                                .italic()


                        }

                    }


//                    .multilineTextAlignment(.center)
                }



                Button{
                    onDismiss()
                } label: {
                    Text("Try it")
                        .font(.subheadline)
                        .bold()
                        .foregroundStyle(color.text(scheme))
                        .padding()
                        .padding(.horizontal, 10)
                        .background(color.button(scheme))
                        .clipShape(.capsule)


                }
                .buttonStyle(.plain)
                .padding(.top)




            }
        }
    }
}




#Preview {
    WelcomeView()
}
