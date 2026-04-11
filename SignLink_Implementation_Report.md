# ACTIVITY 3: IMPLEMENTATION

**Project Title:** SignLink – Connecting Accessibility Services with Students and Interpreters

**Team Members and Roles**

- Chidima Jude Praise - Team Lead / Project Coordinator
- Abdoul-Raouf Mukaila Alh.Shittu - UI/UX Designer (Figma)
- Tomoh Claude - Flutter Frontend Developer
- Deubaybe Dounia - Backend and Logic Developer
- Zahara Seybou - Research, Testing and Documentation


## 1. Introduction

For this activity, we implemented SignLink as a fully functional mobile application using Flutter. Building on the prototypes and architecture we established in Activity 2, we translated the Figma designs into working screens, connected the user interface to application logic, and produced a complete Android APK ready for demonstration. The implementation covers all three user roles - student, interpreter, and admin - and includes all the screens and workflows defined in our earlier documentation.

The primary objective was to demonstrate that our proposed solution can operate as a real application, handling role-based navigation, form input, scheduling workflows, event management, and in-app communication in a coherent and user-friendly way.


## 2. Programming Language and Framework

The application was built using Dart as the primary programming language and Flutter as the UI framework. Dart version 3.10.7 and Flutter version 3.38.7 were used throughout development. Flutter was our chosen framework from the project proposal stage because it allows a single codebase to target both Android and iOS platforms while producing a native mobile experience. For this implementation phase, the application has been compiled and tested on Android.


## 3. Development Tools and Environment

The tools we used to build the application are as follows:

- **Visual Studio Code** was used as the primary code editor throughout development.
- **Android SDK** provided the Android build toolchain needed to compile and package the application.
- **Gradle** was used as the Android build system.
- **Flutter SDK** provided the cross-platform UI framework and command-line tooling.
- **Dart Analyzer** was used for static analysis and linting to ensure code quality.
- **Git** was used for version control across the team.


## 4. Libraries and Packages

We selected the following third-party packages from the official Flutter package repository to support specific features of the application:

- **provider (^6.1.5)** - for state management using the ChangeNotifier pattern. This allowed us to manage and share application state across screens without unnecessary complexity.
- **http (^1.6.0)** - included as an HTTP client in preparation for future integration with a live backend API.
- **shared_preferences (^2.5.5)** - for local key-value storage, used to persist user accessibility settings between sessions.
- **image_picker (^1.2.1)** - to support camera and gallery access for timetable upload and profile photo selection.
- **file_picker (^8.0.0)** - to allow users to select PDF and Excel timetable files from local device storage.
- **intl (^0.20.2)** - for date and time formatting throughout the application.
- **cached_network_image (^3.4.1)** - for efficient remote image loading with loading placeholders and error fallbacks in event cards and profile screens.
- **flutter_animate (^4.5.2)** - for entrance animations on the onboarding flow and sign-up success screen.
- **url_launcher (^6.3.2)** - to support tappable email and phone links on the help and support screen.
- **flutter_secure_storage (^9.2.4)** - for encrypted key-value storage of session tokens using Android EncryptedSharedPreferences (OWASP A02/M9 compliance).
- **logging (^1.3.0)** - for structured security audit logging of authentication events (OWASP A09 compliance).
- **add_2_calendar (^2.1.1)** - to allow students to add confirmed interpretation sessions directly to their native device calendar.
- **flutter_local_notifications (^18.0.0)** - to schedule local push notifications reminding students 15 minutes before their interpretation sessions.
- **timezone (^0.9.4)** - required by flutter_local_notifications to correctly schedule timezone-aware notifications.
- **flutter_lints (^6.0.0)** - to enforce code quality linting rules during development.


## 5. Application Architecture

The application follows a clean, layered architecture organised around the Provider state management pattern. The codebase is divided into several clearly defined layers.

The **presentation layer** contains all UI screens, organised into folders by user role: auth, student, interpreter, admin, and shared. Each folder contains only the screen files relevant to that role.

The **state management layer** uses four ChangeNotifier providers - AuthProvider, ScheduleProvider, EventProvider, and ChatProvider - all mounted at the application root via MultiProvider. This ensures that application state is accessible from any screen without manual state lifting.

The **data access layer** contains service files for authentication, scheduling, events, and chat. In the current implementation, these services draw from a mock data class that provides pre-seeded in-memory records. The service files are structured so that they can be replaced with real REST API calls in future without requiring any changes to the screen or provider code.

The **models layer** contains plain Dart data classes representing the core entities of the system: users, requests, schedules, events, messages, and notifications.

The **shared utilities** include a centralised colour and typography constants file, a helpers class for date and time formatting, and a validators file for form input validation.


## 6. Screens Implemented

All screens from the design prototype were fully implemented. The coverage is organised by user role below.

### Authentication and Onboarding

We implemented a splash screen with an animated logo and automatic role-based redirection, a three-slide onboarding flow with animated dot indicators and skip navigation, a login screen with email and password input and role-based routing, a two-step sign-up screen covering role selection and personal details, a sign-up success screen with confirmation animation, and a forgot password screen with an email input form and a confirmation view.

### Student Screens

For the student role, we implemented a main dashboard with a greeting card, statistics summary, today's schedule, quick-action shortcuts, and a horizontally scrollable event list. We also implemented a timetable screen with tab-based filtering, a profile screen with disability type display and account management options, an events list with search and tab filtering between upcoming and past events, an event detail screen with a hero image and capacity progress bar, a six-step request interpreter flow covering request type, event details, date and time, interpreter selection, review, and confirmation, and a timetable upload screen with a camera and gallery picker.

### Interpreter Screens

For the interpreter role, we implemented a dashboard showing daily assignments and quick actions, a schedule screen with tab-based filtering and accept or decline controls, an event requests screen organised by status, an availability confirmation screen with date range and recurring availability options, and a profile screen with a clear interpreter role indicator.

### Admin Screens

For the admin role, we implemented a dashboard with statistics for students, interpreters, and pending requests, a user management screen with search and role-based filtering and user action controls, an interpreter assignment screen where pending requests can be matched to available interpreters, and an event creation screen with a full input form and a success confirmation view.

### Shared Screens

Screens available across multiple roles include a messages list screen showing conversations with unread badges, a real-time chat screen with sent and received message bubbles and a message input bar, an in-app video call screen with mute, camera, and speaker controls, a notifications screen with unread indicators and mark-all-read functionality, an accessibility settings screen with a font size slider and toggle options, and a help and support screen with expandable FAQ items and a contact card for the DASS office.


## 7. Data Layer

The current implementation uses a mock data service that provides pre-seeded in-memory data for all user roles and features. The data includes three demo user accounts covering all three roles, five interpreter schedule records, eight campus events, six service requests, ten conversation and message records, and eight notification records.

All service files are structured to be directly replaceable with live API calls using the bundled HTTP package. Because the screens communicate only through provider interfaces rather than directly with service classes, no screen-level code changes would be needed when connecting to a real backend.

Persistent storage is handled through shared_preferences, which is used to save and restore authentication tokens and accessibility settings between application sessions.


## 8. State Management

State management is handled using the Provider package with ChangeNotifier. There are four providers in the application.

AuthProvider manages the logged-in user, user role, login state, and logout actions. ScheduleProvider manages class schedules and interpreter request records. EventProvider manages the event list and sign-up status for each event. ChatProvider manages conversations, messages, and unread message counts.

All four providers are registered at the application root through MultiProvider, which means any screen in the app can access them without requiring the state to be passed manually through the widget tree.


## 9. User Roles and Navigation

The application supports three distinct user roles, and each role has its own navigation flow after login.

Students are directed to the student dashboard after login. From there they can request interpreters, view and sign up for events, upload their timetable, view their schedule, and message the DASS office or their assigned interpreters.

Interpreters are directed to the interpreter dashboard. From there they can view the requests assigned to them, manage their availability, accept or decline assignments, and communicate with students.

Admin users are directed to the admin dashboard. From there they can assign interpreters to pending requests, manage user accounts, create campus events, and monitor overall service coordination.

Role-based routing is handled in the splash screen and login screen using the current user's role from the AuthProvider. If a user is already authenticated when the app starts, they are taken directly to the appropriate dashboard without going through login again.


## 10. Design System

The visual design of the application follows the brand identity established in our Figma prototype. The primary colour is a deep navy blue representing Ashesi University's institutional colour, with a lighter action blue for buttons, links, and interactive elements. Semantic colours are used consistently throughout - green for success states, amber for warnings, and red for errors and destructive actions.

Typography uses the Inter font family with system fallback. The application uses Flutter's Material 3 theming system, with a colour scheme seeded from the primary colour. All reusable visual components including buttons, cards, section headers, status badges, user avatars, event tiles, and chat bubbles are defined as shared widget classes so that the visual style remains consistent across all screens.


## 11. Build Output

The application was compiled as a debug Android APK using the Flutter build toolchain. The output file is located at signlink_app/build/app/outputs/flutter-apk/app-debug.apk and has a size of approximately 141 MB. The APK can be installed directly on any Android device or emulator for demonstration.

The following demo credentials can be used to test each user role:

| Role | Email | Password |
|---|---|---|
| Student | alex.johnson@ashesi.edu.gh | Student@123 |
| Interpreter | kofi.mensah@ashesi.edu.gh | Interp@123 |
| Admin | sarah.asante@ashesi.edu.gh | Admin@123 |


## 12. Screen Count Summary

| Category | Design Screens | Flutter Files |
|---|---|---|
| Authentication and Onboarding | 8 | 6 |
| Student | 9 | 7 |
| Interpreter | 5 | 5 |
| Admin | 4 | 4 |
| Shared | 6 | 6 |
| **Total** | **32+** | **28 files covering all 40+ design states** |

Some files consolidate two related design screens into a single screen with state-driven views, such as the forgot password and reset confirmation screens, the sign-up two-step flow, and the schedule all and schedule detail screens. This consolidation keeps the codebase clean while still covering all the designed interactions.


## 13. Known Limitations

We want to be transparent about the boundaries of the current implementation given that this is an MVP built within the scope of this course activity.

The application currently has no live backend. All data is mock and in-memory, which means it resets every time the app is restarted. Local push notifications for session reminders are fully implemented using flutter_local_notifications and fire on the device, but there is no server-side push notification service. The in-app video call screen is a fully functional UI prototype but does not connect to a real video calling service. The timetable upload feature uses the real device camera, gallery, and file picker to select files, but does not upload them to a server or cloud storage. The application also has no offline caching layer for network-dependent content.

These boundaries are intentional for this phase of the project. The service and provider architecture we have put in place is designed to make it straightforward to connect to a real backend when the project moves to the next stage.


## 14. Conclusion

In conclusion, our implementation of SignLink demonstrates that the system we designed in Activity 2 can be built as a working mobile application. All roles, screens, and user flows from the original design are fully present in the Flutter implementation. The application is structured in a way that supports clean separation of concerns, testable components, and a clear path toward replacing the mock data layer with a real backend. The debug APK is ready for demonstration and is included as part of this submission.
