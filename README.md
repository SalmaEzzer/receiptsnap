# ReceiptSnap

ReceiptSnap is a modern AI-powered Flutter application that helps users scan, organize, and analyze receipts with a clean fintech-inspired experience.

The app uses OCR (Optical Character Recognition) to automatically extract receipt information such as merchant name, amount, date, and category, then stores everything locally for smart expense tracking.

---

# Features

* AI-powered receipt scanning
* OCR text extraction using Google ML Kit
* Automatic merchant, amount, and date detection
* Smart category detection
* Expense analytics and insights
* Monthly spending filters
* Receipt history management
* PDF report export
* Modern fintech-inspired UI
* Local offline storage with Hive
* Smooth mobile-first experience

---

# Screenshots

## Home

![Home](docs/screenshots/home.png)

## Scan

![Scan](docs/screenshots/scan.png)

## Receipt Review

![Review](docs/screenshots/review.png)

## Receipts

![Receipts](docs/screenshots/receipts.png)

## Insights

![Insights](docs/screenshots/insights.png)

## Profile

![Profile](docs/screenshots/profile.png)

---

# Tech Stack

* Flutter
* Dart
* Hive Database
* Google ML Kit OCR
* FL Chart
* PDF Package

---

# Project Structure

```bash
lib/
├── screens/
├── services/
├── widgets/
├── models/
└── main.dart
```

---

# Installation

## Clone the repository

```bash
git clone https://github.com/SalmaEzzer/receiptsnap.git
```

## Navigate to project

```bash
cd receiptsnap
```

## Install dependencies

```bash
flutter pub get
```

## Run the app

```bash
flutter run
```

---

# APK Build

Generate APK:

```bash
flutter build apk --release
```

APK output:

```bash
build/app/outputs/flutter-apk/app-release.apk
```

---

# Future Improvements

* Cloud backup
* Authentication system
* AI spending recommendations
* Dark mode
* Budget goals
* Multi-currency support
* Firebase sync

---

# Author

Developed by Salma Ezzerrouti

GitHub:
https://github.com/SalmaEzzer

---

# License

This project is licensed under the MIT License.
