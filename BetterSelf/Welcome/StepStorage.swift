//
//  TutorialStepsStorage.swift
//  BetterSelf
//
//  Created by Adam Damou on 07/10/2025.
//

import Foundation


struct StepStorage {

    static let folderViewSteps0 = [
        TutorialStep(
            id: "welcome",
            title: "Welcome to BetterSelf!",
            message: "Let's take a quick tour of your new learning companion",
            buttonText: "Begin",
            position: .center,
            targetViewId: nil,
            showClickIndicator: false
        ),
        TutorialStep(
            id: "Folders",
            title: "Here's Your Main Space",
            message: "Manage Folders and access Pinned reminders",
            buttonText: "Next",
            position: .center,
            targetViewId: nil,
            showClickIndicator: false
        ),
        TutorialStep(
            id: "accessingReminders",
            title: "All Reminders",
            message: "Tap All Reminders to view everything you’ve added",
            buttonText: "Let's go!",
            position: .topMiddle,
            targetViewId: "AllRemindersButton",
            showClickIndicator: true,
            clickIndicatorPosition: nil
        )
    ]

    static let HomeViewSteps0 = [
        TutorialStep(
            id: "AllReminders",
            title: "The All Reminders Folder",
            message: "Every reminder you create shows here",
            buttonText: "Next",
            position: .center,
            targetViewId: nil,
            showClickIndicator: false,
            clickIndicatorPosition: .center
        ),
        TutorialStep(
            id: "ClickingPlus",
            title: "Add your first Reminder ",
            message: "Tap the + at the top right",
            buttonText: "Next",
            position: .center,
            targetViewId: "PlusButton",
            showClickIndicator: true,
            clickIndicatorPosition: .topRight
        )
    ]


    static let AddReminderSteps = [
        TutorialStep(
            id: "AddingFirst",
            title: "Choose a Type",
            message: "🎥 InstantInsight\n📷 EchoSnap\n✍️ TimelessLetter",
            buttonText: "Next",
            position: .top,
            targetViewId: nil,
            showClickIndicator: false,
            expectsAction: true
        ),
        TutorialStep(
            id: "Storing Links",
            title: "Save Links Too",
            message: "Add Youtube videos and web articles by pasting the link below or sharing it from another app\nMore on that soon✨",
            buttonText: "Next",
            position: .center,
            targetViewId: nil,
            showClickIndicator: false,
        ),
        TutorialStep(
            id: "AddingVideo",
            title: "Add an InstantInsight",
            message: "Tap the button and select a video",
            buttonText: "Next",
            position: .middleHigh,
            targetViewId: "CameraIconButton",
            showClickIndicator: true,
            clickIndicatorPosition: .center

        ),
        TutorialStep(
            id: "AddingDescription",
            title: "Add a Description",
            message: "Swipe right and describe your video",
            buttonText: "Next",
            position: .middleHigh,
            targetViewId: nil,
            showClickIndicator: false,
            expectsAction: true,
            hideNextButton: true

        ),

        TutorialStep(
            id: "AddingTitle",
            title: "Add a Title",
            message: "Give your Reminder a clear name",
            buttonText: "Next",
            position: .center,
            targetViewId: nil,
            showClickIndicator: false,
            expectsAction: true,
            hideNextButton: true
        ),
        TutorialStep(
            id: "SavingReminder",
            title: "Save it",
            message: "Tap Save at the top Right",
            buttonText: "Next",
            position: .center,
            targetViewId: "SaveReminderButton",
            showClickIndicator: true,
            clickIndicatorPosition: .topRight,
            expectsAction: true
        )
    ]

    static let HomeViewSteps1 = [
        TutorialStep(
            id: "BackToHomeView",
            title: "Nice work 🎉",
            message: "You’ve added your first Reminder!\nThe video may take a few seconds to load. Check the icons on the right to see its status",
            buttonText: "Next",
            position: .center,
            targetViewId: nil,
            showClickIndicator: false,
            clickIndicatorPosition: .center
        ),
        TutorialStep(
            id: "DiscoveringButtons",
            title: "Explore the Top Bar",
            message: "🎥 Record yourself\n ⋯ Sort and Select\nTry them out whenever you want!",
            buttonText: "Next",
            position: .center,
            targetViewId: nil,
            showClickIndicator: false,
            expectsAction: true
        ),
        TutorialStep(
            id: "AccessingReminder",
            title: "Open Your Reminder",
            message: "See the camera icon on the right? That means a video’s ready. Tap your Reminder to view it.",
            buttonText: "Next",
            position: .center,
            targetViewId: "FirstReminderButton",
            showClickIndicator: true,
            clickIndicatorPosition: nil
        )
    ]

    static let reminderSteps = [
        TutorialStep(
            id: "ViewingReminder",
            title: "Your Reminder 🎬",
            message: "Reminders look different depending on type. Enjoy discovering all styles!",
            buttonText: "Next",
            position: .center,
            targetViewId: nil,
            showClickIndicator: false,
            clickIndicatorPosition: .center
        ),
        TutorialStep(
            id: "ExplainingReminderView",
            title: "What you can do here",

            message: "The main element changes with the reminder type. Use Edit to update your Reminder and ℹ️ to read more or open a link",
            buttonText: "Next",
            position: .center,
            targetViewId: nil,
            showClickIndicator: false,
            expectsAction: true
        ),
        TutorialStep(
            id: "ViewingVideo",
            title: "Watch & Continue",
            message: "Enjoy your video, then swipe or tap the top arrow to continue the tour",
            buttonText: "Ok",
            position: .center,
            targetViewId: nil,
            showClickIndicator: false,
            expectsAction: true
        )
    ]

    static let homeViewSteps2 = [
        TutorialStep(
            id: "HomeView2",
            title: "What else?",
            message: "Swipe right on a reminder to delete it 😢 or move it to a Folder -> we’ll make one soon!",
            buttonText: "Next",
            position: .middleLow,
            targetViewId: nil,
            showClickIndicator: false,
            expectsAction: true
        ),
        TutorialStep(
            id: "Noticing Selection",
            title: "Pro Tip",
            message: "Tap ⋯ then Select Reminders to delete or move several at once",
            buttonText: "Next",
            position: .middleLow,
            targetViewId: nil,
            showClickIndicator: false,
            expectsAction: true
        ),
        TutorialStep(
            id: "HomeView2",
            title: "Pinning a Reminder",
            message: "Swipe left on a reminder and tap the 📌 Pin icon",
            buttonText: "Next",
            position: .middleLow,
            targetViewId: nil,
            showClickIndicator: false,
            expectsAction: true
        ),
        TutorialStep(
            id: "BackToFolders",
            title: "Back to Folders",
            message: "Tap the top arrow or swipe left to return to your Folders",
            buttonText: "Ok",
            position: .middleLow,
            targetViewId: nil,
            showClickIndicator: false,
            expectsAction: true
        ),
        TutorialStep(isEmpty: true)

    ]

    static let folderViewSteps1 = [
        TutorialStep(
            id: "BackToFolders",
            title: "Pinned Reminder 📌",
            message: "Your reminder now appears under Pinned. You can now access it anytime from the widget and get daily notifications!",
            buttonText: "Next",
            position: .middleLow,
            targetViewId: nil,
            showClickIndicator: false,
            expectsAction: true
        ),
        TutorialStep(
            id: "AddingFolder",
            title: "Create a Folder 📁",
            message: "Tap the folder button at the top right",
            buttonText: "Next",
            position: .middleLow,
            targetViewId: "FolderButton",
            showClickIndicator: true,
            expectsAction: false
        )
    ]

    static let AddFolderSteps = [
        TutorialStep(
            id: "NewFolder",
            title: "Name Your Folder",
            message: "Give your folder a name. You can also lock it with FaceID for extra privacy.\nTap Save once you're done to continue the tour",
            buttonText: "Ok",
            position: .top,
            targetViewId: "FolderButton",
            showClickIndicator: false,
            expectsAction: false
        ),
        TutorialStep(isEmpty: true)

    ]
    static let folderViewSteps2 = [
        TutorialStep(
            id: "EndingTutorial",
            title: "All Set",
            message: "Now you know how to use BetterSelf. Store what you learn and let it remind you. Your second brain is ready!",
            buttonText: "Ok",
            position: .center,
            targetViewId: nil,
            showClickIndicator: false,
            expectsAction: false
        ),

        TutorialStep(
            id: "Sharing",
            title: "Try Sharing ✨",
            message: "From YouTube or any website, share content to BetterSelf",
            buttonText: "Ok",
            position: .center,
            targetViewId: "FolderButton",
            showClickIndicator: false,
            expectsAction: false,
            lastStep: true,
            helperButtonText: "Watch Tutorial",
            hideNextButton: true
        )







    ]







}
