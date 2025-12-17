# System Architecture

## 1. Architecture Style
Chosen architecture style: Monolithic mobile application  
Reason for this choice: simplicity and suitability for a frontend-only MVP.

## 2. System Components
- Front end: Flutter mobile application
- State Management: BLoC
- Data Layer: Local mock repositories
- UI Layer: Feature-based screens

## 3. Component Diagram
User interacts with UI → UI dispatches BLoC events → BLoC updates state → UI re-renders with new state.

## 4. Data Flow
User actions (accept request, send message) trigger BLoC events.  
Mock repositories return predefined data which updates the application state.

## 5. Database Schema
No persistent database is used.  
All data exists in memory for the application session.

## 6. Technology Decisions
- Flutter: cross-platform development
- BLoC: predictable and testable state management
- Mock data: faster development and easier testing

## 7. Future Extensions
- Backend API integration
- Persistent storage
- User authentication
- Real-time messaging
