# Google Sign-In Setup Guide

## Prerequisites

1. **Firebase Project Setup**
   - Go to [Firebase Console](https://console.firebase.google.com/)
   - Create a new project or use an existing one
   - Enable Authentication and Google Sign-In

2. **Android Configuration**
   - Download `google-services.json` from Firebase Console
   - Replace the placeholder file in `android/app/google-services.json`
   - Update the package name in Firebase Console to match your app's package name

3. **Web Configuration (if needed)**
   - Update `web/firebase-config.js` with your Firebase configuration
   - Add the Firebase SDK to `web/index.html`

## Steps to Configure

### 1. Firebase Console Setup
1. Go to Firebase Console
2. Create a new project named "legalcm-app"
3. Enable Authentication
4. Add Google as a sign-in provider
5. Download the `google-services.json` file

### 2. Android Setup
1. Replace `android/app/google-services.json` with your downloaded file
2. The build.gradle files are already configured
3. Make sure your package name matches in Firebase Console

### 3. Dependencies
The following dependencies are already added to `pubspec.yaml`:
- `google_sign_in: ^6.2.1`
- `firebase_auth: ^4.17.4`
- `firebase_core: ^2.25.4`

### 4. Run the App
1. Run `flutter pub get` to install dependencies
2. Run `flutter run` to start the app
3. The app will start at the login screen
4. Use Google Sign-In to authenticate

## Features Implemented

- ✅ Google Sign-In authentication
- ✅ User data stored in Hive local storage
- ✅ Automatic navigation to dashboard after login
- ✅ Sign-out functionality from dashboard
- ✅ Beautiful login UI with loading states
- ✅ Error handling for authentication failures

## File Structure

```
lib/app/modules/login/
├── controller.dart    # Login logic and Google Sign-In
├── binding.dart       # GetX dependency injection
└── view.dart          # Login UI

lib/app/data/models/user_model.dart  # Updated user model
lib/app/routes/app_routes.dart       # Updated routes
lib/main.dart                        # Firebase initialization
```

## Troubleshooting

1. **"Target of URI doesn't exist" errors**: Run `flutter pub get`
2. **Google Sign-In not working**: Check Firebase Console configuration
3. **Build errors**: Make sure `google-services.json` is properly configured
4. **Authentication errors**: Verify Google Sign-In is enabled in Firebase Console

## Next Steps

1. Replace placeholder Firebase configuration with real values
2. Test on both Android and web platforms
3. Add additional authentication providers if needed
4. Implement user profile management 