# Product Requirements Document (PRD)

## 1. Product Goal
The goal of BuildConnect is to deliver a mobile MVP that demonstrates request management and basic messaging functionality using local mock data.

## 2. Problem Statement
Early-stage projects and educational teams often need a working mobile prototype without backend complexity. BuildConnect provides a frontend-only solution to simulate request handling and user communication.

## 3. Target Audience
- Students
- Junior developers
- Educational institutions
- Small project teams

## 4. User Roles
- User (can view and accept requests, send messages)
- Administrator (local configuration only)

## 5. User Scenarios
Users open the application, view a list of incoming requests, accept a request, and exchange messages related to that request.

## 6. Functional Requirements
The system must:
1. Display a list of requests
2. Allow a user to view request details
3. Allow a user to accept or reject a request
4. Display a list of messages
5. Allow a user to send messages
6. Update UI state based on user actions

## 7. Non-Functional Requirements
- performance: screens load within 2 seconds
- reliability: application must not crash during normal use
- security: no sensitive or personal data stored
- usability: clear and simple user interface
- scalability: architecture supports future backend integration

## 8. MVP Scope
Features included in version 0.1:
- Request list screen
- Request acceptance logic
- Messaging screen
- Local state management

## 9. Out-of-Scope (Backlog)
- Real-time messaging
- User authentication
- Backend API integration
- Push notifications

## 10. Acceptance Criteria
- Requests are displayed correctly on app launch
- User can accept a request
- Accepted requests change status
- Messages can be sent and displayed locally
