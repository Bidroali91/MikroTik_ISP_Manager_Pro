# MikroTik ISP Manager Pro — Deployment Guide

## Prerequisites
- Flutter SDK 3.2+
- Firebase project
- Android Studio / VS Code
- Git

## Firebase Setup
1. Create Firebase project at console.firebase.google.com
2. Enable Authentication (Email/Password)
3. Enable Firestore Database
4. Enable Firebase Storage
5. Register Android/iOS app
6. Download `google-services.json` → `android/app/`
7. Download `GoogleService-Info.plist` → `ios/`

## Flutter Setup
```bash
# Install dependencies
flutter pub get

# Generate code (freezed, json_serializable)
flutter pub run build_runner build --delete-conflicting-outputs

# Run on device
flutter run

# Build release APK
flutter build apk --release

# Build iOS
flutter build ios --release

# Build web
flutter build web
```

## Environment Configuration
Create `.env` file:
```
FIREBASE_API_KEY=your_api_key
FIREBASE_PROJECT_ID=mikrotik-isp-pro
FIREBASE_APP_ID=your_app_id
DEFAULT_ROUTER_PORT=8728
CONNECTION_TIMEOUT=8000
```

## Production Checklist
- [ ] Firebase security rules deployed
- [ ] Firestore indexes created
- [ ] APK signed with production keystore
- [ ] App icons and splash screen configured
- [ ] Google Play Console listing ready
- [ ] ProGuard rules enabled for release
- [ ] Environment variables configured
- [ ] SSL/TLS enabled for RouterOS connections
- [ ] Crashlytics enabled
- [ ] Performance monitoring enabled
