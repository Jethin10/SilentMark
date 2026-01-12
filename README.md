# SilentMark 🔐

A modern, secure attendance system built with Flutter. Supports web and mobile platforms.

![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Firebase](https://img.shields.io/badge/Firebase-FFCA28?style=for-the-badge&logo=firebase&logoColor=black)
![License](https://img.shields.io/badge/License-MIT-green?style=for-the-badge)

## ✨ Features

### For Teachers
- 📊 **Create Sessions** - Generate QR codes for students to scan
- 👥 **Live Attendance** - See students check in real-time
- 🛑 **End Session** - Close attendance with one tap
- 📈 **Dashboard** - View attendance statistics

### For Students
- 📱 **QR Scan** - Quick check-in by scanning teacher's QR code
- 📍 **Location Verification** - Ensures student is in the classroom
- 🤳 **Selfie Capture** - Identity verification with photo
- 🏆 **Leaderboard** - Track attendance streaks

### Security
- 🔒 One check-in per session (no duplicates)
- 🌐 Google Sign-In authentication
- 📍 Geofencing verification
- 📸 Photo verification

## 🚀 Live Demo

**Web App:** [https://jet-auth-v1.web.app](https://jet-auth-v1.web.app)

**Android APK:** [Download from Releases](https://github.com/Jethin10/SilentMark/releases)

## 🛠️ Tech Stack

- **Frontend:** Flutter (Dart)
- **Backend:** Firebase (Firestore, Auth, Hosting)
- **Authentication:** Google Sign-In
- **Location:** Geolocator
- **Camera:** Flutter Camera Plugin

## 📦 Installation

### Prerequisites
- Flutter SDK 3.0+
- Firebase CLI
- Android Studio / Xcode

### Setup

1. Clone the repository
```bash
git clone https://github.com/Jethin10/SilentMark.git
cd SilentMark
```

2. Install dependencies
```bash
flutter pub get
```

3. Run the app
```bash
# For web
flutter run -d chrome

# For Android
flutter run -d android

# For iOS
flutter run -d ios
```

### Build

```bash
# Web
flutter build web --release

# Android APK
flutter build apk --release

# iOS
flutter build ios --release
```

## 📱 Screenshots

| Login | Teacher Dashboard | Student Check-In |
|-------|-------------------|------------------|
| Gradient SilentMark branding | QR code display with live attendance | 3-step verification flow |

## 📄 License

This project is licensed under the MIT License.

## 👨‍💻 Author

**Jethin** - [GitHub](https://github.com/Jethin10)

---

<p align="center">Made with ❤️ using Flutter</p>
