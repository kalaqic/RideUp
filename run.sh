#!/bin/bash

# PedalUp Flutter App Runner Script

echo "🚴 PedalUp - Premium Bike Rental App"
echo "======================================"
echo ""

# Check if Flutter is installed
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter is not installed. Please install Flutter first."
    echo "Visit: https://flutter.dev/docs/get-started/install"
    exit 1
fi

echo "📦 Installing dependencies..."
flutter pub get

echo ""
echo "🔍 Running Flutter doctor..."
flutter doctor -v

echo ""
echo "📱 Available devices:"
flutter devices

echo ""
echo "Choose how to run the app:"
echo "1) Run on connected device/emulator"
echo "2) Run on Chrome (web)"
echo "3) Run on iOS Simulator (macOS only)"
echo "4) Run on Android Emulator"
echo ""

read -p "Enter your choice (1-4): " choice

case $choice in
    1)
        echo "🚀 Running on connected device..."
        flutter run
        ;;
    2)
        echo "🌐 Running on Chrome..."
        flutter run -d chrome
        ;;
    3)
        echo "📱 Running on iOS Simulator..."
        flutter run -d ios
        ;;
    4)
        echo "🤖 Running on Android Emulator..."
        flutter run -d android
        ;;
    *)
        echo "Invalid choice. Running on default device..."
        flutter run
        ;;
esac
