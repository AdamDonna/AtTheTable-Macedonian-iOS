# ✅ Xcode Setup Checklist

## Step 1: Add JSON Files to Bundle
- [ ] Drag `Resources/alphabet.json` into Xcode project
- [ ] Drag `Resources/curriculum.json` into Xcode project  
- [ ] Ensure "Add to target" is checked for both files
- [ ] Verify files appear in project navigator

## Step 2: Set Deployment Target
- [ ] Click on project name at top of navigator
- [ ] Select your app target 
- [ ] Under "Deployment Info" → set "iOS Deployment Target" to **17.0**

## Step 3: Verify All Swift Files Added
- [ ] `App/AtTheTableApp.swift` ✓
- [ ] `Models/Content.swift` ✓
- [ ] `Models/CardProgress.swift` ✓
- [ ] `Services/ContentStore.swift` ✓
- [ ] `Services/Scheduler.swift` ✓
- [ ] `Services/SessionBuilder.swift` ✓
- [ ] `Services/Mastery.swift` ✓
- [ ] `Services/ReminderScheduler.swift` ✓
- [ ] `Views/HomeView.swift` ✓
- [ ] `Views/AlphabetView.swift` ✓
- [ ] `Views/SessionView.swift` ✓
- [ ] `Views/SessionSummaryView.swift` ✓
- [ ] `Views/SettingsView.swift` ✓

## Step 4: Build and Run
- [ ] Select iPhone 15 (or any iOS 17+) simulator
- [ ] Press **Cmd+R** or click ▶️ button
- [ ] App should compile successfully
- [ ] App launches showing "At the Table" home screen

## Expected Behavior
When running successfully, you should see:
- Home screen with "At the Table / на маса" header
- Alphabet level unlocked (others locked)
- Book icon and gear icon in top right
- Clean UI with level progression indicators

🎉 **Success!** You now have a fully functional Macedonian learning app!