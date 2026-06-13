# Xcode Setup Guide

## Steps to Run the App

### 1. Add JSON Files to Xcode Project Bundle
1. In Xcode, drag these files from the Resources folder into your project:
   - `Resources/alphabet.json`
   - `Resources/curriculum.json`
2. When the dialog appears, make sure:
   - "Add to target" is checked for your app target
   - "Copy items if needed" is checked

### 2. Set iOS Deployment Target
1. Select your project in Xcode navigator
2. Under "Deployment Info" set:
   - **iOS Deployment Target: 17.0**

### 3. Verify Project Structure
Make sure all these Swift files are added to your target:
- `App/AtTheTableApp.swift` (main app file)
- `Models/Content.swift`
- `Models/CardProgress.swift`
- `Services/ContentStore.swift`
- `Services/Scheduler.swift`
- `Services/SessionBuilder.swift`
- `Services/Mastery.swift`
- `Services/ReminderScheduler.swift`
- `Views/HomeView.swift`
- `Views/AlphabetView.swift`
- `Views/SessionView.swift`
- `Views/SessionSummaryView.swift`
- `Views/SettingsView.swift`

### 4. Build and Run
1. Select iPhone 15 iOS 17.0 simulator (or any iOS 17+ simulator)
2. Press Cmd+R or click the Play button
3. The app should compile and launch!

## Troubleshooting

### If you get "File not found" errors for JSON:
- Make sure alphabet.json and curriculum.json are in the app bundle
- Right-click the files → "Show File Inspector" → ensure target membership is checked

### If you get SwiftData errors:
- Ensure deployment target is iOS 17.0+
- Clean build folder (Cmd+Shift+K) and rebuild

### If you get import errors:
- All required frameworks (SwiftUI, SwiftData, Foundation) are included in iOS 17+
- UserNotifications is disabled in this version

## What to Expect

When the app launches:
1. You'll see the home screen with level progression
2. Only the "Азбука" (Alphabet) level will be unlocked initially
3. Tap the alphabet level to start the teaching flow
4. Complete the alphabet quiz to unlock phrase levels
5. Use the book icon to access alphabet reference
6. Use the gear icon to access settings

Enjoy learning Macedonian! 🇲🇰