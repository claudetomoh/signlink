# SignLink

A mobile application that connects deaf and hard-of-hearing students at **Ashesi University** with qualified sign language interpreters for academic events, classes, and campus activities.

Built for the **Disability and Accessibility Support Services (DASS)** unit.

---

## Features

| Role | Capabilities |
|---|---|
| **Student** | Browse events, request interpreters (3-step wizard), track request status, upload timetable, in-app chat, notifications |
| **Interpreter** | View assigned requests, confirm/decline availability, manage schedule, in-app chat |
| **Admin** | Create events, manage users (suspend/delete), assign interpreters to requests, full dashboard |

**Shared**: In-app messaging, real-time notifications, video call screen, accessibility settings (font scaling, high contrast, haptic feedback, screen reader support)

---

## Tech Stack

### Mobile App (`signlink_app/`)
- **Flutter 3** / Dart 3
- **Provider** — state management
- `flutter_secure_storage` — AES-256 encrypted token storage
- `flutter_local_notifications` — session reminders
- `http` — REST API communication
- `add_2_calendar`, `file_picker`, `image_picker`, `cached_network_image`, `flutter_animate`

### Backend (`backend/`)
- **PHP 8** REST API (19 endpoints across 7 modules)
- **MySQL** — 8-table relational schema
- Bearer token authentication (30-day expiry)
- bcrypt password hashing

### Prototypes (`<screen>/code.html`)
- 43 high-fidelity interactive screens
- Tailwind CSS + Google Material Symbols
- Dark mode support

---

## Project Structure

```
signlink/
├── signlink_app/          # Flutter mobile app
│   ├── lib/
│   │   ├── main.dart
│   │   ├── app.dart
│   │   ├── models/        # UserModel, EventModel, RequestModel, …
│   │   ├── providers/     # AuthProvider, EventProvider, ChatProvider, …
│   │   ├── screens/       # 40+ screen widgets
│   │   ├── services/      # AuthService, EventService, ChatService, …
│   │   ├── utils/         # constants, validators, theme
│   │   └── widgets/       # AuthGuard, shared components
│   └── pubspec.yaml
├── backend/
│   ├── api/
│   │   ├── auth/          # login, register, logout, me, forgot_password
│   │   ├── events/        # list, create, signup
│   │   ├── requests/      # list, create, update
│   │   ├── messages/      # conversations, list, send
│   │   ├── notifications/ # list, mark_read
│   │   ├── users/         # list, update, delete
│   │   └── config/        # db.php, helpers.php
│   ├── deploy.php         # single-file deploy script
│   └── setup.php          # DB schema + seed data
├── <screen_name>/
│   └── code.html          # interactive HTML prototype (43 screens)
└── SUBMISSION - Activity 3/
```

---

## API Endpoints

| Module | Method | Endpoint | Description |
|---|---|---|---|
| Auth | POST | `/auth/login.php` | Login → Bearer token |
| Auth | POST | `/auth/register.php` | Register (student/interpreter) |
| Auth | POST | `/auth/logout.php` | Invalidate token |
| Auth | GET | `/auth/me.php` | Current user info |
| Auth | POST | `/auth/forgot_password.php` | Password reset email |
| Events | GET | `/events/list.php` | List events (upcoming/past/search) |
| Events | POST | `/events/create.php` | Create event (admin) |
| Events | POST | `/events/signup.php` | Toggle event signup |
| Requests | GET | `/requests/list.php` | List requests (role-filtered) |
| Requests | POST | `/requests/create.php` | Submit interpreter request |
| Requests | PUT | `/requests/update.php` | Approve/decline/assign |
| Messages | GET | `/messages/conversations.php` | List conversations |
| Messages | GET | `/messages/list.php` | Get messages in conversation |
| Messages | POST | `/messages/send.php` | Send message |
| Notifications | GET | `/notifications/list.php` | List notifications |
| Notifications | POST | `/notifications/mark_read.php` | Mark read |
| Users | GET | `/users/list.php` | List users (admin) |
| Users | PUT | `/users/update.php` | Update profile / suspend |
| Users | DELETE | `/users/delete.php` | Soft-delete user (admin) |

---

## Database Schema

| Table | Purpose |
|---|---|
| `users` | All users with role (student/interpreter/admin), avatar, languages, rating |
| `auth_tokens` | 64-char Bearer tokens with 30-day expiry |
| `events` | Campus events with capacity tracking |
| `event_signups` | Student ↔ event many-to-many |
| `interpreter_requests` | Booking requests with status lifecycle |
| `conversations` | Chat thread registry |
| `messages` | Individual chat messages |
| `notifications` | In-app notification inbox |

---

## Security

| Control | Implementation |
|---|---|
| Access control (OWASP A01) | `AuthGuard` widget on every route; role-based redirects |
| Crypto (OWASP A02) | `flutter_secure_storage` AES-256; bcrypt on server |
| Injection (OWASP A03) | Input sanitization in `validators.dart`; PDO prepared statements |
| Auth failures (OWASP A07) | 5-attempt lockout with 15-minute cooldown |
| Logging (OWASP A09) | `logging` package with structured log levels |

---

## Demo Accounts

| Role | Email | Password |
|---|---|---|
| Student | `alex.johnson@ashesi.edu.gh` | `Password1!` |
| Interpreter | `kofi.mensah@ashesi.edu.gh` | `Password1!` |
| Admin | `sarah.asante@ashesi.edu.gh` | `Password1!` |

---

## Deploying the Backend

1. Upload `backend/deploy.php` to the server
2. Visit `https://<server>/deploy.php?k=sl_deploy_2026` — writes all API files
3. Visit `https://<server>/setup.php?key=sl_setup_2026` — creates DB tables and seeds demo data
4. **Delete** `deploy.php` and `setup.php` from the server after setup

---

## Team

| Name | Role |
|---|---|
| Chidima Jude Praise | Team Lead |
| Abdoul-Raouf Mukaila | UI/UX Design |
| Tomoh Claude | Flutter Development |
| Deubaybe Dounia | Backend (PHP/MySQL) |
| Zahara Seybou | Research, Testing & Documentation |

---

*Ashesi University — DASS SignLink Project, 2026*
