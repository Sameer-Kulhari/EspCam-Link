# 📱 ESPCam-Link Flutter App

## Overview
The Flutter app connects to the ESPCam-Link server running on a Raspberry Pi.  
It allows users to:
1. View a splash screen with fade animation
2. Select a device from the menu
3. Log in to the device
4. View live sensor readings
5. Control GPIO devices (LED)

---

## App Structure

### Screens
1. **SplashScreen**
   - Displays logo with fade-in/out animation
   - Navigates to `/menu`

2. **MenuScreen**
   - Lists devices with IP & port
   - Navigates to `/session_login` when a device is selected

3. **SessionLoginScreen**
   - Prompts for username & password
   - Sends POST request to `http://<ip>:<port>/login`
   - On success → navigates to `/session`

4. **SessionScreen**
   - Displays temperature & humidity
   - LED control buttons



---

## Navigation Routes
```dart
routes: {
  '/': (context) => const SplashScreen(),
  '/menu': (context) => const MenuScreen(),
  '/session_login': (context) => const SessionLoginScreen(),
  '/session': (context) => const SessionScreen(),
}
```
## Notes

- The app communicates with the server over HTTP — ensure devices are on the same network.

- Update IP & port in MenuScreen when adding devices.

- Default login: admin / 1234 (must match server configuration).
