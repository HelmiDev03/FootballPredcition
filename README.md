# Flutter Football Predictions App

This Flutter application displays football (soccer) match schedules and prediction probabilities fetched from the API-Football service. It allows users to browse leagues, view matches for a selected date (within a +/- 7 day range from today), and switch between light and dark themes.

## Features

*   **League Listing:** Displays a list of available football leagues.
*   **Match Schedule:** Shows matches for a selected league and date.
*   **Prediction Probabilities:** Displays win/draw/loss probabilities for each match.
*   **Calendar Navigation:** Allows users to select a date using a calendar strip (limited to +/- 7 days from the current date).
*   **API Integration:** Fetches real-time data from API-Football.
*   **State Management:** Uses the Provider package for managing application state.
*   **Theme Switching:** Supports both light and dark modes.

## Project Structure

```
football_predictions_app/
├── android/         # Android specific files
├── build/           # Build output (including APK)
├── ios/             # iOS specific files (not configured in this setup)
├── lib/
│   ├── main.dart      # App entry point, navigation, theme setup
│   ├── models/        # Data models (League, Match)
│   │   ├── league.dart
│   │   └── match.dart
│   ├── providers/     # State management (ChangeNotifier)
│   │   ├── league_provider.dart
│   │   ├── match_provider.dart
│   │   └── theme_provider.dart
│   ├── services/      # Data fetching logic
│   │   └── api_football_service.dart
│   ├── views/         # UI Screens
│   │   ├── leagues_screen.dart
│   │   ├── match_list_screen.dart
│   │   └── settings_screen.dart
│   └── widgets/       # Reusable UI components
│       └── calendar_strip.dart
├── linux/           # Linux specific files
├── test/            # Unit and widget tests
├── web/             # Web specific files (not configured)
├── windows/         # Windows specific files (not configured)
├── pubspec.yaml     # Project dependencies and metadata
├── README.md        # This file
└── upload-keystore.jks # Keystore for signing Android APK
```

## Setup and Running

1.  **Prerequisites:**
    *   Flutter SDK: Ensure you have the Flutter SDK installed. See [Flutter installation guide](https://docs.flutter.dev/get-started/install).
    *   Android SDK: Required for building the Android app. Ensure `ANDROID_HOME` environment variable is set.
    *   Java Development Kit (JDK): Required for Android development and signing.

2.  **API Key:**
    *   This app requires an API key from [API-Football](https://www.api-football.com/).
    *   Register on their website to get a free API key (offers 100 requests/day).
    *   Open `lib/services/api_football_service.dart`.
    *   Replace the placeholder `YOUR_API_FOOTBALL_KEY` with your actual API key:
        ```dart
        const String _apiKey = "YOUR_API_FOOTBALL_KEY"; // Replace with your key
        ```

3.  **Install Dependencies:**
    *   Navigate to the project root directory (`football_predictions_app`).
    *   Run `flutter pub get`.

4.  **Run the App (Emulator/Device):**
    *   Ensure you have an emulator running or a device connected.
    *   Run `flutter run`.

## Building the App

### Android (Signed APK)

1.  **Keystore:**
    *   A keystore file (`upload-keystore.jks`) is included in the project root.
    *   The passwords and alias used are configured in `android/key.properties`.
    *   **Important:** For production use, you should generate your own secure keystore and update `android/key.properties` and `android/app/build.gradle` accordingly. The included keystore uses placeholder details and the password "helmi2003".

2.  **Build Command:**
    *   Run `flutter build apk --release`.
    *   The signed APK will be located at `build/app/outputs/flutter-apk/app-release.apk`.

### Linux

1.  **Build Command:**
    *   Ensure Linux development dependencies are installed (see Flutter Linux setup guide).
    *   Run `flutter build linux --release`.
    *   The build output will be in `build/linux/x64/release/bundle`.

## Dependencies

*   `provider`: For state management.
*   `http`: For making API requests.
*   `google_fonts`: For custom fonts.
*   `table_calendar`: For the calendar widget.
*   `intl`: For date formatting.


