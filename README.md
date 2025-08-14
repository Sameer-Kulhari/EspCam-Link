# EspCamLink

EspCamLink is a smart IoT dashboard application designed for managing ESP32-CAM and Raspberry Pi cameras. This Flutter mobile app provides a user-friendly interface to control camera streams and monitor sensor data.

## Features

- **Splash Screen**: Displays the app logo with a loading animation.
- **Menu Screen**: A scrollable list of camera entries with options to start sessions, edit, or delete entries.
- **Add/Edit Entry**: A form to add or modify camera entries, including IP address and port number.
- **Session Screen**: 
  - **Camera Tab**: Live MJPEG stream from the camera.
  - **IoT Dashboard Tab**: Control LED and view sensor data (temperature and humidity).
  - **Exit Tab**: Confirm exit and return to the Menu Screen.

## Setup Instructions
### Using flutter
1. **Clone the Repository**:
   ```bash
   git clone <repository-url>
   cd espcamlink
   ```

2. **Install Dependencies**:
   Make sure you have Flutter installed. Then run:
   ```bash
   flutter pub get
   ```

3. **Run the Application**:
   Use the following command to run the app on your device or emulator:
   ```bash
   flutter run
   ```
### Using Apk 

Dowload the app-release.apk and install it on any android phone to use it 

## Usage Guidelines

- Add new camera entries by tapping the "Add Entry" button on the Menu Screen.
- Start a session by tapping the "Start" button next to the desired entry.
- Control the LED and monitor sensor data in the IoT Dashboard tab.
- Use the three-dot menu for options to edit or delete entries.

## Backend API Endpoints

- `GET /stream`: Returns live MJPEG video stream.
- `GET /led/status`: Returns the current LED status.
- `POST /led/on`: Turns the LED on.
- `POST /led/off`: Turns the LED off.
- `GET /sensor`: Returns current sensor data (temperature and humidity).

