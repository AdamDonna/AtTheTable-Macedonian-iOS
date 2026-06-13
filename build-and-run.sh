#!/bin/bash

echo "🏗️  Building At the Table iOS App..."

# Check if we're in the right directory
if [ ! -f "App/AtTheTableApp.swift" ]; then
    echo "❌ Error: Please run this script from the AtTheTable project directory"
    exit 1
fi

echo "📱 Looking for Xcode project..."

# Find the Xcode project
PROJECT_FILE=$(find . -name "*.xcodeproj" -type d | head -n 1)

if [ -z "$PROJECT_FILE" ]; then
    echo "⚠️  No Xcode project found. Please:"
    echo "   1. Create a new iOS project in Xcode named 'AtTheTable'"
    echo "   2. Add all Swift files to the project"
    echo "   3. Drag alphabet.json and curriculum.json into Xcode"
    echo "   4. Set deployment target to iOS 17.0+"
    echo "   5. Then run this script again"
    exit 1
fi

echo "📦 Found project: $PROJECT_FILE"
echo "🔧 Setting deployment target to iOS 17.0..."

# Try to build the project
echo "🚀 Building project..."
xcodebuild -project "$PROJECT_FILE" -scheme "AtTheTable" -destination "platform=iOS Simulator,OS=17.0,name=iPhone 15" build

if [ $? -eq 0 ]; then
    echo "✅ Build successful!"
    echo "🏃 Running on simulator..."
    xcodebuild -project "$PROJECT_FILE" -scheme "AtTheTable" -destination "platform=iOS Simulator,OS=17.0,name=iPhone 15" run
else
    echo "❌ Build failed. Please check Xcode for errors."
    echo "💡 Common issues:"
    echo "   - Ensure JSON files are added to the app bundle"
    echo "   - Verify all Swift files are added to the target"
    echo "   - Check deployment target is set to iOS 17.0+"
fi