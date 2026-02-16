
# Silero TTS Desktop UI

A Flutter-based desktop application that provides a graphical interface for the **Silero TTS API**. This app allows users to convert text to speech locally by bundling a Python-based backend.

## Features

* **Full GUI:** Easy-to-use interface for text input and audio playback.
* **Parameter Control:** Select languages (`uz`, `ru`, `en`), choose speakers, and adjust speech speed.
* **Offline Processing:** Works entirely offline once the backend is bundled.
* **Executable Integration:** Designed to run a standalone Python binary from assets.

## Project Setup

### 1. Build the Python Backend

You must first create a standalone executable of the [Python TTS API](https://github.com/BekNaji/tts_python). To include all language models in one file, use the following command:

```powershell
pyinstaller --onefile --add-data "silero_uz_model.pt;." --add-data "silero_ru_model.pt;." --add-data "silero_en_model.pt;." run.py

```

### 2. Add Binary to Flutter

1. Locate the generated `run.exe` (Windows) or binary (macOS) in the `dist/` folder.
2. Move it to your Flutter project: `assets/bin/run.exe`.
3. Register the asset in `pubspec.yaml`:
```yaml
flutter:
  assets:
    - assets/run.exe

```



### 3. Install & Run

```bash
# Install Flutter dependencies
flutter pub get

# Run the application
flutter run -d windows # or macos

```

## How It Works

1. **Startup:** The Flutter app extracts and launches the `run.exe` on a background port (default: `5005`).
2. **Communication:** The UI sends `POST` requests with JSON data to the local server.
3. **Playback:** The app receives the path to the generated `.wav` file and plays it back to the user.

## Requirements

* **Flutter SDK:** Stable channel.
* **OS:** Windows 10+ or macOS 11+.
* **Hardware:** Minimum 4GB RAM (Models are loaded into memory).
