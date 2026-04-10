//
//  ProblemSolverViewswift.swift
//  BetterSelf
//
//  Created by Adam Damou on 15/08/2025.
//

import SwiftData
import SwiftUI

struct ProblemSolverView: View {
    @EnvironmentObject var color: ColorManager
    @Environment(\.colorScheme) var scheme
    @Environment(\.modelContext) var modelContext
    @Query(filter: #Predicate<Reminder> {
        $0.isChecked == true
    }) var reminders: [Reminder]

    var reminderTitles: [String] {
        reminders.map{ $0.title }
    }

    @State private var chosenReminder: Reminder?

    @State private var available = true

    @State private var solvingProblem = false


    @StateObject var solver: ProblemSolverManager = ProblemSolverManager.shared

    var body: some View {

            ZStack {
                color.mainGradient(scheme)
                    .ignoresSafeArea()
                color.overlayGradient(scheme)
                    .ignoresSafeArea()

                VStack {
                    if available {
                        Image(systemName: "sparkles")
                            .foregroundStyle(color.itemColor(scheme))
                            .font(.largeTitle)


                        Text("Tell me your struggle")
                            .font(.largeTitle)
                            .bold()
                            .padding()



                        AudioRecorderView(onTranscription: {input in
                            solvingProblem = true
                            startSolving(input)
                        })

                    }
                    else {
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

            }
            .onAppear{
                if TutorialManager.shared.inTutorial {
                    TutorialManager.shared.viewId("ProblemSolver")
                }

            }
            .sheet(item: $chosenReminder){ reminder in
                ReminderView(reminder: reminder)
            }
            .navigationTitle("ProblemSolver")
        
    }
    func startSolving(_ input: String){
        Task {
            let reminderTitle = try await solver.solveProblem("I struggle to go to the gym.", reminders: reminderTitles)
            if let reminder = reminders.first(where: { $0.title == reminderTitle }) {
                chosenReminder = reminder
            }

        }


    }
}

#Preview {
    ProblemSolverView()
}
