# MikroTik ISP Manager Pro

Enterprise-grade ISP Management System for MikroTik networks built with Flutter.

## Tech Stack

- **Frontend:** Flutter + Riverpod + GoRouter + Material 3
- **Backend:** Firebase Auth + Firestore + FCM + Storage
- **Router Integration:** Native RouterOS API binary protocol (TCP:8728)
- **Architecture:** Clean Architecture + MVVM + Repository Pattern

## Modules

| Module | Features |
|--------|----------|
| Authentication | Login, Register, Forgot Password, Remember Me |
| Dashboard | Stats cards, Revenue chart, Quick actions, Auto-refresh |
| Hotspot | CRUD users, Search/Filter, Enable/Disable, Active sessions |
| PPPoE | Subscribers, Active sessions, Bandwidth profiles |
| Sales | Dashboard, Charts, History, Daily/Monthly reports |
| Backup | Manual/Auto, Cloud backup, Restore, Download |
| Security | NetCut detection, Firewall audit, Security events |
| Complaints | Tickets, Priority, Assignment, Resolution tracking |
| Notifications | Push alerts, Expiry, Payment, System alerts |
| Maintenance | Session cleanup, Expired users, Reboot, History |
| Electricity | Power/Generator status, Voltage monitoring |
| Telegram Bot | /info, /active, /users, /pppoe, /sales, /backup, /reboot |
| Settings | Theme, Language, Router management, User roles |

## Folder Structure

```
lib/
├── core/          # Constants, Theme, Errors, Router, Utils
├── data/          # Models, Datasources (Firebase + RouterOS), Repositories
├── domain/        # Entities, Repository interfaces, Use cases
└── presentation/  # Auth, Dashboard, Hotspot, PPPoE, Sales, etc.
```

## Getting Started

```bash
# Install dependencies
flutter pub get

# Generate code
flutter pub run build_runner build

# Run
flutter run

# Build release
flutter build apk --release
```

## Firebase Setup

1. Create project at [Firebase Console](https://console.firebase.google.com)
2. Enable Authentication (Email/Password)
3. Enable Firestore Database
4. Download `google-services.json` → `android/app/`
5. Download `GoogleService-Info.plist` → `ios/`

## RouterOS API

The system uses the native MikroTik RouterOS API binary protocol on port 8728.
- Supports RouterOS v6 and v7
- Login with MD5 challenge for older versions
- Direct connection (no middle server)

## License

Proprietary - All Rights Reserved
