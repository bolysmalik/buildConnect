# BuildConnect

## Overview
BuildConnect is a mobile application MVP developed using Flutter.  
The product aims to provide users with a structured interface for managing location-based tasks and navigation-related workflows using local and mock data.

The main problem addressed by the product is the lack of lightweight, easily deployable mobile solutions for testing navigation and location-based user flows without backend dependencies.

The target users include students, developers, and small teams who need a mobile MVP for demonstration, prototyping, or educational purposes.

## Tech Stack
- Front end: Flutter (Dart)
- State Management: BLoC
- Data Storage: Local in-memory storage / mock data
- Maps: Flutter Map (OpenStreetMap)
- Tools: Git, GitHub

## Project Structure
- /lib – application source code
- /lib/core – shared utilities and constants
- /lib/features – feature-based modules
- /lib/features/routing – routing and map-related logic
- /test – unit and widget tests
- /docs – project documentation

## How to Run the Project
System requirements:
- Flutter SDK (stable)
- Dart SDK
- Android Studio or VS Code
- Android emulator or physical device

Installation steps:
1. Clone the repository
2. Run `flutter pub get`
3. Ensure a device or emulator is running

Start command:
flutter run
flutter test
