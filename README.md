# At the Table (на маса)

A native iOS app for learning conversational Macedonian, designed for someone joining a Macedonian-speaking family.

## Features

- **Cyrillic Alphabet Learning**: Interactive teaching flow with recognition quiz
- **Spaced Repetition**: Leitner system with 5 boxes for optimal retention
- **Themed Lessons**: Greetings, Family, At the Table, Small Talk, At Home
- **Fully Local**: No network, no accounts, no external dependencies
- **Daily Reminders**: Local notifications for practice sessions

## Requirements

- iOS 17.0+
- Xcode 15.0+

## Setup Instructions

### Option 1: Clone and Setup in Xcode
1. Clone this repository: `git clone <repo-url>`
2. Open Xcode and create a new iOS App project:
   - Product Name: "AtTheTable"
   - Interface: SwiftUI
   - Language: Swift
   - Minimum Deployment: iOS 17.0

3. Replace the default files with our structure:
   - Copy all `.swift` files to your Xcode project
   - Add `alphabet.json` and `curriculum.json` to the app bundle (drag into Xcode)
   - Replace the default Info.plist with ours

4. In Xcode project settings:
   - Add UserNotifications capability
   - Set bundle identifier (e.g., `com.yourname.atthetable`)

5. Build and run on iOS 17 simulator

### Option 2: Direct Xcode Usage  
If you have this code open in Xcode already:
1. Make sure all files are added to the target
2. Verify `alphabet.json` and `curriculum.json` are in the app bundle
3. Add UserNotifications capability in project settings
4. Set deployment target to iOS 17.0+
5. Build and run

## Project Structure

```
AtTheTable/
├── App/
│   └── AtTheTableApp.swift          # Main app entry point
├── Models/
│   ├── Content.swift                # Content data models
│   └── CardProgress.swift           # SwiftData progress model
├── Services/
│   ├── ContentStore.swift           # Content loading service
│   ├── Scheduler.swift              # Leitner spaced repetition
│   ├── SessionBuilder.swift         # Session card selection
│   ├── Mastery.swift                # Level progression logic
│   └── ReminderScheduler.swift      # Local notifications
├── Views/
│   ├── HomeView.swift               # Main level selection
│   ├── AlphabetView.swift           # Alphabet teaching & reference
│   ├── SessionView.swift            # Flashcard session
│   ├── SessionSummaryView.swift     # Session completion
│   └── SettingsView.swift           # App settings
└── Resources/
    ├── alphabet.json                # 31 Macedonian letters
    └── curriculum.json              # Levels and card decks
```

## Learning Flow

1. **Alphabet (Level 0)**: Learn all 31 Cyrillic letters with teaching flow and recognition quiz
2. **Phrase Levels (1-5)**: Progress through themed vocabulary with spaced repetition
   - Поздрави (Greetings)
   - Семејство (Family) 
   - На маса (At the Table)
   - Мал разговор (Small Talk)
   - Дома (At Home)

## Spaced Repetition Algorithm

- 5 Leitner boxes with intervals: 1, 2, 4, 8, 16 days
- "Got it" → advance to next box
- "Not yet" → back to box 1
- Level unlock requires 80% of cards in box 3+

## Technical Notes

- Built with SwiftUI and SwiftData
- Uses `@Observable` for view models
- Local notifications only (no remote push)
- No third-party dependencies
- Macedonian-specific Cyrillic letters: Ѓ ѓ, Ќ ќ, Ѕ ѕ, Џ џ, Љ љ, Њ њ, Ј ј

## Content Attribution

The Macedonian content is provided as educational placeholder material and should be reviewed by a native speaker before production use.