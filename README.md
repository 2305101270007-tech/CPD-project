# Smart Calculator – Flutter (CPD Tiny Project)

A cross-platform calculator built with **Flutter & Dart**. One codebase runs on Android, iOS, Web, Windows, macOS and Linux.

## Features
- Basic operations: `+  -  ×  ÷  %`
- Correct operator precedence (e.g. `2+3×4 = 14`)
- Live result preview while typing
- Backspace, Clear, and +/- sign toggle
- Decimal input with validation, divide-by-zero handling
- Calculation history (last 20)
- Light / Dark theme toggle
- Responsive layout

## Tech Stack
Flutter 3.x · Dart 3.x · Material 3

## How to Run
```bash
git clone <your-repo-link>
cd smart_calculator
flutter create .        # generates android/ios/web platform folders (first time only)
flutter pub get
flutter run             # or: flutter run -d chrome
```

## Run Tests
```bash
flutter test
```

## Project Structure
```
smart_calculator/
├── lib/main.dart          # UI + calculation logic
├── test/widget_test.dart  # widget test
├── pubspec.yaml
└── README.md
```

## Screenshots
Add your screenshots in a `screenshots/` folder and link them here:
`Capture.png`

## Author
<Your Name> – UG-7, Cross Platform Development
