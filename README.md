# PedalUp - Premium Bike Rental App

A beautiful, minimalist Flutter MVP for a bike rental system with gamification elements. This showcase app features an elegant design with typography-focused UI and pastel gradients.

## Features

### 🚴 Core Functionality (Simulated)
- **Onboarding**: 3-screen introduction to sustainable mobility
- **Station Map**: Interactive map with bike station locations
- **QR Scanning**: Visual simulation of bike unlocking
- **Ride Tracking**: Timer, distance, speed, and points tracking
- **Ride Summary**: Post-ride statistics and achievements
- **User Profile**: Personal stats and ride history

### 🏆 Gamification
- Achievement system with progress tracking
- Points earning system
- Multiple achievement types:
  - Beginner Rider
  - Weekend Warrior
  - Eco Hero
  - Distance Champion
  - Early Bird
  - Night Owl

### 🎨 Design Philosophy
- **Minimalist**: Extensive use of negative space
- **Typography-focused**: Elegant serif (Playfair Display) and clean sans-serif (Inter)
- **Pastel gradients**: Subtle radial gradients with pink and peach tones
- **Premium feel**: Inspired by eco-tech lifestyle aesthetics
- **Clean UI**: Ghost buttons, thin lines, no shadows

## Color Palette

- **Primary**: #6B4AFF (Cool Purple)
- **Pastel Pink**: #FFBBD0
- **Pastel Peach**: #FFE4B8
- **Success**: #4CAF50
- **Warning**: #FF9800
- **Error**: #E91E63

## Installation

1. **Prerequisites**
   - Flutter SDK (3.0.0 or higher)
   - Dart SDK
   - Xcode / VSCode (for mobile development)

2. **Setup**
   ```bash
   # Clone the repository
   cd pedalup

   # Get dependencies
   flutter pub get

   # Run the app
   flutter run
   ```

## Project Structure

```
lib/
├── main.dart                 # App entry point
├── models/
│   └── models.dart          # Data models
├── data/
│   └── mock_data.dart       # Static mock data
├── screens/
│   ├── splash_screen.dart   # Splash screen
│   ├── onboarding_screen.dart
│   ├── map_screen.dart
│   ├── qr_scan_screen.dart
│   ├── ride_screen.dart
│   ├── ride_summary_screen.dart
│   ├── achievements_screen.dart
│   └── profile_screen.dart
├── widgets/
│   ├── station_card.dart
│   └── bottom_nav.dart
└── utils/
    └── app_theme.dart       # Theme configuration
```

## User Flow

1. **App Launch** → Splash Screen (3s)
2. **Onboarding** → 3 informative screens
3. **Main Map** → View bike stations
4. **Select Station** → View availability
5. **Start Ride** → QR scan simulation
6. **Active Ride** → Live tracking simulation
7. **End Ride** → Summary and points
8. **Achievements** → View progress
9. **Profile** → Personal statistics

## Mock Data

All data is hardcoded for showcase purposes:
- 5 bike stations with different availability
- User profile with ride history
- 6 achievements with progress tracking
- Simulated ride statistics

## Key Features Implementation

### Animations
- Fade and scale transitions between screens
- Pulse animation on active ride screen
- Staggered list animations
- Smooth page indicators

### Typography
- **Headers**: Playfair Display (serif)
- **Body**: Inter (sans-serif)
- Increased letter spacing for premium feel
- Hierarchical text sizing

### Visual Design
- Radial gradient backgrounds
- Minimal use of colors
- Extensive white space
- Rounded corners (8-12px radius)
- Thin borders (1-2px)

## Development Notes

This is a **showcase MVP** without backend integration:
- No authentication system
- No real GPS/map integration
- No actual QR code scanning
- All data is static/mocked
- Focus on UI/UX presentation

## Future Enhancements

Potential additions for production version:
- Real-time GPS tracking
- Backend integration
- User authentication
- Payment processing
- Push notifications
- Real QR code scanning
- Social features
- Detailed analytics

## License

This is a showcase project for demonstration purposes.

---

**Created with Flutter** • Elegant, Minimal, Premium
