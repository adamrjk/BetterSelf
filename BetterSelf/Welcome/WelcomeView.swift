//
//  WelcomeView.swift
//  BetterSelf
//
//  Created by Adam Damou on 24/09/2025.
//

import SwiftUI

struct WelcomeView: View {
    @Environment(\.colorScheme) var scheme
    @EnvironmentObject var color: ColorManager
    @Environment(\.dismiss) var dismiss




    var body: some View {
        NavigationStack{
            ZStack {
                color.mainGradient(scheme)
                    .ignoresSafeArea()
                color.overlayGradient(scheme)
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    Spacer()
                    
                    // Hero icon with animation potential
                    ZStack {
                        // Outer glow circle
                        Circle()
                            .fill(color.itemColor(scheme).opacity(0.1))
                            .frame(width: 140, height: 140)
                        
                        // Inner circle
                        Circle()
                            .fill(color.itemColor(scheme).opacity(0.2))
                            .frame(width: 110, height: 110)
                        
                        // Icon
                        Image(systemName: "brain.head.profile")
                            .font(.system(size: 60, weight: .medium))
                            .foregroundStyle(color.itemColor(scheme))
                    }
                    .padding(.bottom, 35)
                    
                    // Main title
                    VStack(spacing: 8) {
                        HStack(spacing: 6) {
                            Text("Welcome to")
                                .font(.system(size: 32, weight: .semibold))
                            Text("BetterSelf")
                                .font(.system(size: 32, weight: .bold))
                                .italic()
                                .foregroundStyle(color.itemColor(scheme))
                        }
                        .padding(.bottom, 4)
                        
                        Text("Your personal space to remember")
                            .font(.title3)
                            .foregroundStyle(.primary)
                        
                        Text("your learnings")
                            .font(.title3)
                            .bold()
                            .foregroundStyle(color.itemColor(scheme))
                    }
                    .multilineTextAlignment(.center)
                    .padding(.bottom, 30)

                    VStack(spacing: 16) {
                        FeatureRow(
                            icon: "lightbulb.fill",
                            text: "Capture ideas, lessons & insights",
                            scheme: scheme
                        )
                        
                        FeatureRow(
                            icon: "arrow.up.forward",
                            text: "Track your growth over time",
                            scheme: scheme
                        )
                        
                        FeatureRow(
                            icon: "sparkles",
                            text: "Never forget what shaped you",
                            scheme: scheme
                        )
                    }
                    .padding(.horizontal, 40)
                    .padding(.bottom, 45)
                    
                    Spacer()
                    
                    // Call to action
                    NavigationLink{
                        Questions(onDismiss: {
                            dismiss()
                        })



                    } label: {
                        HStack(spacing: 8) {
                            Text("Begin Your Journey")
                                .font(.headline)
                                .bold()
                            Image(systemName: "arrow.right")
                                .font(.headline)
                        }
                        .foregroundStyle(color.text(scheme))
                        .frame(maxWidth: 300)
                        .padding()
                        .background(color.itemColor(scheme))
                        .clipShape(Capsule())
                        .shadow(color: color.shadow(scheme).opacity(0.3), radius: 8, x: 0, y: 4)
                    }
                    .buttonStyle(.plain)
                    .padding(.bottom, 50)
                }
                .padding(.horizontal, 30)
            }

        }
    }
}

struct FeatureRow: View {
    let icon: String
    let text: String
    let scheme: ColorScheme

    @EnvironmentObject var color: ColorManager
    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(color.itemColor(scheme))
                .frame(width: 28)
            
            Text(text)
                .font(.body)
                .foregroundStyle(.primary)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

struct Questions: View{
    @Environment(\.colorScheme) var scheme
    @EnvironmentObject var color: ColorManager

    let onDismiss: () -> Void

    @State private var name = ""
    @FocusState var keyboard: Bool




    var body: some View {
        ZStack {
            color.mainGradient(scheme)
                .ignoresSafeArea()
            color.overlayGradient(scheme)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                Spacer()
                
                // Icon
                ZStack {
                    Circle()
                        .fill(color.itemColor(scheme).opacity(0.1))
                        .frame(width: 130, height: 130)
                    
                    Circle()
                        .fill(color.itemColor(scheme).opacity(0.18))
                        .frame(width: 100, height: 100)
                    
                    Image(systemName: "person.fill")
                        .font(.system(size: 55, weight: .medium))
                        .foregroundStyle(color.itemColor(scheme))
                }
                .padding(.bottom, 35)
                
                // Title
                VStack(spacing: 6) {
                    Text("Your Journey begins here")
                        .font(.title)
                        .bold()
                }
                .padding(.bottom, 40)
                
                // Name input section
                VStack(spacing: 16) {
                    Text("What should we call you?")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundStyle(.secondary)

                    TextField("Your name", text: $name)
                        .font(.title3)
                        .focused($keyboard)
                        .multilineTextAlignment(.center)
                        .padding(.vertical, 16)
                        .padding(.horizontal, 20)
                        .frame(width: 300)
                        .background(
                            RoundedRectangle(cornerRadius: 18)
                                .fill(Color.primary.opacity(scheme == .dark ? 0.1 : 0.05))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 18)
                                .stroke(color.itemColor(scheme).opacity(name.isEmpty ? 0.2 : 0.6), lineWidth: name.isEmpty ? 1.5 : 2.5)
                        )
                        .animation(.easeInOut(duration: 0.2), value: name.isEmpty)
                }
                .padding(.bottom, 60)
                
                Spacer()
                
                // Continue button
                NavigationLink {
                    SettingGoals(onDismiss: onDismiss)
                } label: {
                    Text("Continue")
                        .font(.headline)
                        .bold()
                        .foregroundStyle(color.text(scheme))
                        .frame(maxWidth: 300)
                        .padding(.vertical, 16)
                        .padding(.horizontal, 40)
                        .background(color.itemColor(scheme))
                        .clipShape(Capsule())
                        .shadow(color: color.shadow(scheme).opacity(0.3), radius: 8, x: 0, y: 4)
                }
                .buttonStyle(.plain)
                .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                .opacity(name.trimmingCharacters(in: .whitespaces).isEmpty ? 0.5 : 1.0)
                .padding(.bottom, 50)
            }
            .padding(.horizontal, 30)
        }
        .onChange(of: name) {
            UserDefaults.standard.set(name, forKey: "UserName")
        }
        .overlay(
            VStack {
                Spacer()  // ← This pushes the button to the bottom of the screen
                if keyboard {
                    HStack {
                        Spacer()
                        Button{
                            keyboard = false
                        } label: {
                            Image(systemName: "arrow.down")
                                .foregroundStyle(.primary)
                                .padding()
                                .background(
                                    scheme == .light
                                    ? .white
                                    : Color( red: 0.318, green: 0.318, blue: 0.318)

                                )
                                .clipShape(.circle)
                                .padding(.trailing)
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.bottom, 65)  // ← This adds 8 points of space below the button
                }
            }
        )

    }

}

struct SettingGoals: View {
    @Environment(\.colorScheme) var scheme
    @EnvironmentObject var color: ColorManager
    let onDismiss: () -> Void
    
    @State private var selectedGoals: Set<String> = []

    let goals: [String] = [
        "Learn and remember better",
        "Build better habits",
        "Reflect and grow personally",
        "Save meaningful Memories",
        "Collect Youtube clips"
    ]

    var unselectedGradient: LinearGradient {
        LinearGradient(
            colors: [
                Color.primary.opacity(scheme == .dark ? 0.08 : 0.04),
                Color.primary.opacity(scheme == .dark ? 0.06 : 0.03)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    var body: some View {
        ZStack {
            color.mainGradient(scheme)
                .ignoresSafeArea()
            color.overlayGradient(scheme)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                Spacer()
                
                // Icon
                ZStack {
                    Circle()
                        .fill(color.itemColor(scheme).opacity(0.1))
                        .frame(width: 130, height: 130)
                    
                    Circle()
                        .fill(color.itemColor(scheme).opacity(0.18))
                        .frame(width: 100, height: 100)
                    
                    Image(systemName: "target")
                        .font(.system(size: 55, weight: .medium))
                        .foregroundStyle(color.itemColor(scheme))
                }
                .padding(.bottom, 10)

                // Title
                Text("What brings you to")
                    .font(.title)
                    .fontWeight(.semibold)
                    .foregroundStyle(.secondary)
                
                Text("BetterSelf?")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundStyle(color.itemColor(scheme))
                    .padding(.bottom, 12)
                
                // Goal buttons
                VStack(spacing: 14) {
                    ForEach(goals, id: \.self) { goal in
                        GoalButton(
                            text: goal,
                            isSelected: selectedGoals.contains(goal),
                            scheme: scheme
                        ) {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                if selectedGoals.contains(goal) {
                                    selectedGoals.remove(goal)
                                } else {
                                    selectedGoals.insert(goal)
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal, 30)
                .padding(.bottom, 45)
                
                Spacer()
                
                // Continue button
                NavigationLink {
                    GettingStarted(onDismiss: onDismiss)
                } label: {
                    Text("Continue")
                        .font(.headline)
                        .bold()
                        .foregroundStyle(color.text(scheme))
                        .frame(maxWidth: 320)
                        .padding(.vertical, 16)
                        .padding(.horizontal, 40)
                        .background(selectedGoals.isEmpty ? unselectedGradient : color.itemColor(scheme))
                        .clipShape(Capsule())
                        .shadow(color: selectedGoals.isEmpty ? .clear : color.itemShadow(scheme), radius: 8, x: 0, y: 4)
                }
                .buttonStyle(.plain)
                .disabled(selectedGoals.isEmpty)
                .opacity(selectedGoals.isEmpty ? 0.6 : 1.0)
                .padding(.bottom, 50)
                .simultaneousGesture(TapGesture().onEnded {
                    if !selectedGoals.isEmpty {
                        UserDefaults.standard.set(Array(selectedGoals), forKey: "UserGoals")
                    }
                })
            }
            .padding(.horizontal, 20)
        }
    }
}

// MARK: - Goal Button Component
struct GoalButton: View {
    let text: String
    let isSelected: Bool
    let scheme: ColorScheme
    let action: () -> Void
    @EnvironmentObject var color: ColorManager

    var unselectedGradient: LinearGradient {
        LinearGradient(
            colors: [
                Color.primary.opacity(scheme == .dark ? 0.08 : 0.04),
                Color.primary.opacity(scheme == .dark ? 0.06 : 0.03)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    var selectedBackgroundGradient: LinearGradient {
        LinearGradient(
            colors: [
                Color.white.opacity(0.18),
                Color.white.opacity(0.14),
                Color.white.opacity(0.10)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 22, weight: .medium))
                    .foregroundStyle(isSelected ? color.itemColor(scheme) : unselectedGradient)

                Text(text)
                    .font(.body)
                    .fontWeight(isSelected ? .semibold : .regular)
                    .foregroundStyle(.primary)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 18)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(isSelected ? selectedBackgroundGradient : unselectedGradient)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isSelected ? color.itemColor(scheme) : unselectedGradient, lineWidth: isSelected ? 2 : 1)
            )
        }
        .buttonStyle(.plain)
    }
}

struct GettingStarted: View {
    @Environment(\.colorScheme) var scheme
    @EnvironmentObject var color: ColorManager
    let onDismiss: () -> Void

    let features: [(icon: String, text: String)] = [
        ("brain.head.profile", "Always remember what you learn"),
        ("square.and.arrow.down", "Capture lessons in any format"),
        ("bell.badge", "Get daily reminders and instant access")
    ]

    var body: some View {
        ZStack {
            color.mainGradient(scheme)
                .ignoresSafeArea()
            color.overlayGradient(scheme)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                Spacer()
                
                // Hero Icon
                ZStack {
                    Circle()
                        .fill(color.itemColor(scheme).opacity(0.1))
                        .frame(width: 140, height: 140)
                    
                    Circle()
                        .fill(color.itemColor(scheme).opacity(0.2))
                        .frame(width: 110, height: 110)
                    
                    Image(systemName: "sparkles")
                        .font(.system(size: 60, weight: .medium))
                        .foregroundStyle(color.itemColor(scheme))
                }
                .padding(.bottom, 35)
                
                // Title
                VStack(spacing: 8) {
                    Text("Ready to")
                        .font(.title)
                        .fontWeight(.semibold)
                        .foregroundStyle(.secondary)
                    
                    HStack(spacing: 6) {
                        Text("Discover")
                            .font(.system(size: 32, weight: .bold))
                        
                        Text("BetterSelf?")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundStyle(color.itemColor(scheme))
                    }
                    .fixedSize(horizontal: false, vertical: true)
                    .minimumScaleFactor(0.6)
                    .lineLimit(1)
                }
                .multilineTextAlignment(.center)
                .padding(.horizontal, 25)
                .padding(.bottom, 12)
                
                Text("Let's walk through the essentials")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .padding(.bottom, 40)
                
                // Features
                VStack(spacing: 20) {
                    ForEach(features, id: \.text) { feature in
                        HStack(spacing: 16) {
                            ZStack {
                                Circle()
                                    .fill(color.itemColor(scheme).opacity(0.15))
                                    .frame(width: 50, height: 50)
                                
                                Image(systemName: feature.icon)
                                    .font(.system(size: 22, weight: .semibold))
                                    .foregroundStyle(color.itemColor(scheme))
                            }
                            
                            Text(feature.text)
                                .font(.body)
                                .fontWeight(.medium)
                                .foregroundStyle(.primary)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .frame(maxWidth: 320)
                    }
                }
                .padding(.bottom, 50)
                
                Spacer()
                
                // Start button
                Button {
                    TutorialManager.shared.getStarted()
                    UserDefaults().set(true, forKey: "Tutorial \(NotificationManager.shared.version)")
                    TutorialManager.shared.viewId("Folder")
                    TutorialManager.shared.startTutorial("Folder")
                    
                    onDismiss()


                } label: {
                    HStack(spacing: 8) {
                        Text("Start the Tour")
                            .font(.headline)
                            .bold()
                        Image(systemName: "arrow.right.circle.fill")
                            .font(.headline)
                    }
                    .foregroundStyle(color.text(scheme))
                    .frame(maxWidth: 300)
                    .padding(.vertical, 16)
                    .padding(.horizontal, 40)
                    .background(color.itemColor(scheme))
                    .clipShape(Capsule())
                    .shadow(color: color.shadow(scheme).opacity(0.3), radius: 8, x: 0, y: 4)
                }
                .buttonStyle(.plain)
                .padding(.bottom, 50)
            }
            .padding(.horizontal, 30)
        }
    }
}




#Preview {
    WelcomeView()
}
