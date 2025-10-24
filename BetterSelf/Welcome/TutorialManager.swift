//
//  TutorialManager.swift
//  BetterSelf
//
//  Created by Adam Damou on 04/10/2025.
//

import SwiftUI

// MARK: - Tutorial Step Model
struct TutorialStep {
    let id: String
    let title: String
    let message: String
    let buttonText: String
    let position: TutorialPosition
    let targetViewId: String? // Optional: to highlight specific views
    let showClickIndicator: Bool // Whether to show animated click indicator
    let clickIndicatorPosition: ClickIndicatorPosition? // Position of the click indicator
    let expectsAction: Bool // If true, keeps background at full brightness for user actions
    let lastStep: Bool
    let helperButtonText: String? // Optional: text for helper button that opens sheet
    let isInvisible: Bool // If true, this step doesn't show anything
    let hideNextButton: Bool // If true, hides the Next button



    // MARK: - Initializers
    
    // Basic initializer without click indicator
    init(
        id: String,
        title: String,
        message: String,
        buttonText: String,
        position: TutorialPosition,
        targetViewId: String? = nil,
        expectsAction: Bool = false,
        lastStep: Bool = false,
        helperButtonText: String? = nil,
        hideNextButton: Bool = false
    ) {
        self.id = id
        self.title = title
        self.message = message
        self.buttonText = buttonText
        self.position = position
        self.targetViewId = targetViewId
        self.showClickIndicator = false
        self.clickIndicatorPosition = nil
        self.expectsAction = expectsAction
        self.lastStep = lastStep
        self.helperButtonText = helperButtonText
        self.isInvisible = false
        self.hideNextButton = hideNextButton
    }
    
    // Full initializer with click indicator
    init(
        id: String,
        title: String,
        message: String,
        buttonText: String,
        position: TutorialPosition,
        targetViewId: String? = nil,
        showClickIndicator: Bool,
        clickIndicatorPosition: ClickIndicatorPosition? = nil,
        expectsAction: Bool = false,
        lastStep: Bool = false,
        helperButtonText: String? = nil,
        hideNextButton: Bool = false
    ) {
        self.id = id
        self.title = title
        self.message = message
        self.buttonText = buttonText
        self.position = position
        self.targetViewId = targetViewId
        self.showClickIndicator = showClickIndicator
        self.clickIndicatorPosition = clickIndicatorPosition
        self.expectsAction = expectsAction
        self.lastStep = lastStep
        self.helperButtonText = helperButtonText
        self.isInvisible = false
        self.hideNextButton = hideNextButton
    }
    
    // Simple initializer for invisible/empty step
    init(isEmpty: Bool = false) {
        self.id = ""
        self.title = ""
        self.message = ""
        self.buttonText = ""
        self.position = .center
        self.targetViewId = nil
        self.showClickIndicator = false
        self.clickIndicatorPosition = nil
        self.expectsAction = false
        self.lastStep = false
        self.helperButtonText = nil
        self.isInvisible = isEmpty
        self.hideNextButton = false
    }
    
    /// Tutorial bubble positioning options that are relative to device screen size
    /// All positions automatically adapt to different device sizes and safe areas
    enum TutorialPosition {
        // Top positions (10% to 40% from top of safe area)
        case topHigh          // 10% from top - closest to top edge
        case top              // 20% from top - standard top position
        case topMiddle        // 30% from top - between top and center
        case topLow           // 40% from top - closer to center
        
        // Middle positions (40% to 60% from top of safe area)
        case middleHigh       // 40% from top - higher than center
        case center           // 50% from top - exact center
        case middleLow        // 60% from top - lower than center
        
        // Bottom positions (60% to 90% from top of safe area)
        case bottomHigh       // 60% from top - closer to center
        case bottomMiddle     // 70% from top - between center and bottom
        case bottomLow        // 80% from top - closer to bottom
        case bottom           // 90% from top - standard bottom position
        
        // Corner positions (combines horizontal and vertical positioning)
        case topLeft          // Top-left corner (25% width, 20% height)
        case topRight         // Top-right corner (75% width, 20% height)
        case centerLeft       // Center-left (25% width, 50% height)
        case centerRight      // Center-right (75% width, 50% height)
        case bottomLeft       // Bottom-left corner (25% width, 80% height)
        case bottomRight      // Bottom-right corner (75% width, 80% height)
        
        // Custom position (absolute coordinates)
        case custom(x: CGFloat, y: CGFloat)
    }
    
    enum ClickIndicatorPosition {
        case topLeft
        case topRight
        case bottomLeft
        case bottomRight
        case center
        case custom(x: CGFloat, y: CGFloat)
    }
}

// MARK: - Tutorial Manager
class TutorialManager: ObservableObject {
    static let shared = TutorialManager()

    @Published var inTutorial = false
    @Published var HomeView1Done = false

    @Published var isActive = false
    @Published var shouldRender = true // Controls whether tutorial renders as a view
    @Published var currentStepIndex = 0
    @Published var steps: [TutorialStep] = []
    
    @Published var showHelperSheet = false // Controls helper sheet visibility
    @Published var currentDone = true
    @Published var currentViewId = "" // Tracks which view the tutorial is currently running in

    private init() {}
    
    // Returns the tutorial view itself for manual overlay (used in sheets)
    func tutorialView(viewId: String) -> some View {
        ManualTutorialOverlay()
    }



    func startTutorial(_ viewId: String){
        if currentDone && viewId == viewIds[index]{
            self.currentViewId = viewId
            self.currentStepIndex = 0
            self.isActive = true
            self.shouldRender = true
            currentDone = false


        }
    }


    func startTutorialForSheet(_ viewId: String){
        if currentDone {
            self.currentStepIndex = 0
            self.isActive = true // Tutorial is active and running
            self.shouldRender = false // But don't render as a view
            self.currentViewId = viewId
            currentDone = false
        }
    }

    func getStarted(){
        index = 0
        steps = AllSteps[index]
        inTutorial = true

    }

    func check(){
        if currentViewId != viewIds[index] {
            hideTutorial()
        }
        else {
            showTutorial()
        }
    }
    
    // Manually show/hide the tutorial
    func showTutorial() {
        self.isActive = true
    }
    
    func hideTutorial() {
        self.isActive = false
    }

    func viewId(_ id: String){
        self.currentViewId = id
    }

    func handleKeyboardAppeared() {
        // Hide tutorial when keyboard appears (user clicked text field) with animation
        withAnimation(.easeInOut(duration: 0.3)) {
            hideTutorial()
        }
    }
    
    func handleKeyboardDismissed() {
        // Show next tutorial step when keyboard is dismissed (action completed) with animation
        nextStep()
        withAnimation(.easeInOut(duration: 0.4)) {
            showTutorial()
        }
    }
    
    func nextStep() {
        if currentStepIndex < steps.count - 1 {
            currentStepIndex += 1
        } else {
            if let step = currentStep {
                if step.lastStep {
                    inTutorial = false
                }
            }
            endTutorial()
        }
    }
    
    func previousStep() {
        if currentStepIndex > 0 {
            currentStepIndex -= 1
        }
    }
    
    func endTutorial() {
        currentDone = true
        isActive = false
        currentStepIndex = 0
        steps = []
        if inTutorial {
            launchNext()
        }

    }


    func launchNext(){
        index += 1
        steps = AllSteps[index]
    }


    // Static method for views to call when they're clicked
    static func notifyViewClicked(viewId: String) {
        shared.handleTargetViewClick(target: viewId)
    }
    
    func handleTargetViewClick(target: String) {
        // Check if current step is a click indicator step and matches the clicked view
        guard let currentStep = currentStep,
              currentStep.showClickIndicator,
              currentStep.targetViewId == target else {
            return
        }


        // Auto-advance to next step
        nextStep()
    }

    func tutorialIsDone(){
        inTutorial = false
        endTutorial()
    }

    var isHomeView2: Bool {
        index == 5
    }

    var currentStep: TutorialStep? {
        guard currentStepIndex < steps.count else { return nil }
        return steps[currentStepIndex]
    }
    
    var progress: Double {
        guard !steps.isEmpty else { return 0 }
        return Double(currentStepIndex + 1) / Double(steps.count)
    }

    var index = 0

    let AllSteps: [[TutorialStep]] = [StepStorage.folderViewSteps0, StepStorage.HomeViewSteps0, StepStorage.AddReminderSteps, StepStorage.HomeViewSteps1,
                                    StepStorage.reminderSteps, StepStorage.homeViewSteps2, StepStorage.folderViewSteps1, StepStorage.AddFolderSteps,
                                    StepStorage.folderViewSteps2 ]

    let viewIds: [String] = ["Folder", "Home", "AddReminder", "Home", "Reminder", "Home", "Folder", "AddFolder", "Folder"]
//    let AllSteps: [[TutorialStep]] = [StepStorage.folderViewSteps2]
//    let viewIds: [String] = ["Folder"]
}

