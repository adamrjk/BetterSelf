//
//  ProblemSolverViewswift.swift
//  BetterSelf
//
//  Created by Adam Damou on 15/08/2025.
//

import SwiftUI

struct ProblemSolverView: View {
    @EnvironmentObject var color: ColorManager
    @Environment(\.colorScheme) var scheme

    var body: some View {
        NavigationStack {
            ZStack {
                color.mainGradient(scheme)
                    .ignoresSafeArea()
                color.overlayGradient(scheme)
                    .ignoresSafeArea()

                VStack {
                    Image(systemName: "sparkles")
                        .foregroundStyle(color.itemColor(scheme))
                        .font(.largeTitle)


                    Text("Coming Soon")
                        .font(.largeTitle)
                        .bold()
                        .padding()


                    Group{
                        Text("ProblemSolver uses AI to pick the reminder that best fits your current situation.")
                        
                             Text(" For now, add reminders, get familiar with BetterSelf")
                             Text("By the time you have too many to sort through, ProblemSolver will be there to help.")
                    }
                    .multilineTextAlignment(.center)
                    .frame(width: 350)
                    .italic()
                    .font(.subheadline)
                }

            }
            .onAppear{
                if TutorialManager.shared.inTutorial {
                    TutorialManager.shared.viewId("ProblemSolver")
                }
            }
            .navigationTitle("ProblemSolver")
        }
    }
}

#Preview {
    ProblemSolverView()
}
