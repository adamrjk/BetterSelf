//
//  TutorialStepsStorage.swift
//  BetterSelf
//
//  Created by Adam Damou on 07/10/2025.
//

import Foundation


struct StepStorage {

    static let folderViewSteps = [
        TutorialStep(
            id: "welcome",
            title: "Welcome to BetterSelf!",
            message: "Let's take a quick tour of your new learning companion.",
            buttonText: "Let's go!",
            position: .center,
            targetViewId: nil,
            showClickIndicator: false
        ),
        TutorialStep(
            id: "Folders",
            title: "Here is the Main Space",
            message: "You have Pinned Reminders, which we'll try later and Folders to organize your Reminders",
            buttonText: "Let's go!",
            position: .center,
            targetViewId: nil,
            showClickIndicator: false
        ),
        TutorialStep(
            id: "accessingReminders",
            title: "Let's make a Reminder",
            message: "Click on All Reminders to access your Reminders",
            buttonText: "Let's go!",
            position: .topLow,
            targetViewId: "AllRemindersButton",
            showClickIndicator: true,
            clickIndicatorPosition: .center
        )
    ]

    static let HomeViewSteps0 = [
        TutorialStep(
            id: "AllReminders",
            title: "This stores all your Reminders",
            message: "All the Reminders you add will show here or inside another Folder",
            buttonText: "Next",
            position: .center,
            targetViewId: nil,
            showClickIndicator: false,
            clickIndicatorPosition: .center
        ),
        TutorialStep(
            id: "ClickingPlus",
            title: "Let's add your first Reminder ",
            message: "Click the + to add a Reminder",
            buttonText: "Next",
            position: .top,
            targetViewId: "PlusButton",
            showClickIndicator: true,
            clickIndicatorPosition: .topRight
        )
    ]


    static let AddReminderSteps = [
        TutorialStep(
                id: "AddingFirst",
                title: "There are three types of Reminder",
                message: "InstantInsight: a Video with a Description \nEchoSnap: a Photo with a description \n TimeLessLetter: Just Text for journaling or quotes",
                buttonText: "Next",
                position: .center,
                targetViewId: nil,
                showClickIndicator: false
            ),
        TutorialStep(
                id: "Storing Links",
                title: "You can also store links",
                message: "Youtube Videos and Web Articles are another Reminder Type. You can enter the link manually or share directly from the Youtube app or a web browser",
                buttonText: "Next",
                position: .center,
                targetViewId: nil,
                showClickIndicator: false,
            ),
        TutorialStep(
                id: "AddingVideo",
                title: "Let's add an InstantInsight",
                message: "Click this Button to select a Video from your Library",
                buttonText: "Next",
                position: .top,
                targetViewId: "CameraIconButton",
                showClickIndicator: true,
                clickIndicatorPosition: .center

            ),
        TutorialStep(
                id: "AddingDescription",
                title: "Your Video is Added!",
                message: "It might take a moment to load \nMeanwhile swipe to the right and Add a Description",
                buttonText: "Next",
                position: .top,
                targetViewId: nil,
                showClickIndicator: false,
                expectsAction: true

            ),

        TutorialStep(
                id: "AddingTitle",
                title: "Good now add a Title",
                message: "",
                buttonText: "Next",
                position: .center,
                targetViewId: nil,
                showClickIndicator: false,
                expectsAction: true
            ),
        TutorialStep(
                id: "SavingReminder",
                title: "Great now Save your Reminder",
                message: "Click the Save button at the top Right",
                buttonText: "Next",
                position: .center,
                targetViewId: "SaveReminderButton",
                showClickIndicator: true,
                clickIndicatorPosition: .topRight
            )
    ]

    static let HomeViewSteps1 = [
        TutorialStep(
            id: "BackToHomeView",
            title: "Well Done, you've just added your first Reminder!",
            message: "It might take a few seconds for the video to load at the first time. The indicators on the right show you if the video is added or not",
            buttonText: "Next",
            position: .center,
            targetViewId: nil,
            showClickIndicator: false,
            clickIndicatorPosition: .center
        ),
        TutorialStep(
            id: "DiscoveringButtons",
            title: "Before watching your Reminder. Let's see what else you can do",
            message: "Look at the top, the camera Icon is for recording Yourself, the Arrows are for Sorting and Selecting. Feel free to try them out!",
            buttonText: "Next",
            position: .middleHigh,
            targetViewId: nil,
            showClickIndicator: false,
            expectsAction: true
        ),
        TutorialStep(
            id: "AccessingReminder",
            title: "Hope you add fun! Now click on your Reminder",
            message: "Notice first the camera icon on the right, it shows that a video is available. Now Click on it",
            buttonText: "Next",
            position: .middleHigh,
            targetViewId: "ReminderButton",
            showClickIndicator: true,
            clickIndicatorPosition: nil
        )
    ]

    static let reminderSteps = [
        TutorialStep(
            id: "ViewingReminder",
            title: "Here we are, viewing your Reminder!",
            message: "You'll see this can look very different depending on the Reminder Type. I hope you'll enjoy discovering all those styles",
            buttonText: "Next",
            position: .center,
            targetViewId: nil,
            showClickIndicator: false,
            clickIndicatorPosition: .center
        ),
        TutorialStep(
            id: "ExplainingReminderView",
            title: "But the goal is the same",
            message: "The Main Thing you see is the central element of your Reminder. Then at the top you have an Edit Button if you'd like to change something, and sometimes you can have a Details Button to access the Description or the link in your Reminder. Feel free to try those out!",
            buttonText: "Next",
            position: .middleHigh,
            targetViewId: nil,
            showClickIndicator: false,
            expectsAction: true
        ),
        TutorialStep(
            id: "ViewingVideo",
            title: "Now of course, the central thing here is this Video",
            message: "Enjoy watching it and come back to your Reminders by swiping or clicking the arrow at the top to continue the visit",
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
            title: "All Right let's what else you can do",
            message: "Try swiping left on the Reminder and clicking the Pin Icon",
            buttonText: "Ok",
            position: .center,
            targetViewId: nil,
            showClickIndicator: false,
            expectsAction: true
        )
    ]




}
