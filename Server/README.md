# Server Side (Flask + Raspberry Pi)

### Overview
The server runs on a Raspberry Pi using:
- **Flask** (HTTP server)
- **RPi.GPIO** (GPIO control)
- **Adafruit_DHT** (temperature/humidity sensor)

It provides API endpoints for the Flutter app to:
1. Authenticate (`/login`)
2. Get sensor readings (`/data`)
3. Control GPIO devices (`/led`)

---

### Main Components
- **Flask** → HTTP request handling
- **RPi.GPIO** → GPIO control
- **Adafruit_DHT** → Sensor readings
- **Threading** → Continuous sensor data updates

---

### API Endpoints

| Endpoint  | Method | Purpose                        | Example Response                          |
|-----------|--------|--------------------------------|--------------------------------------------|
| `/login`  | POST   | Authenticate username/password | `{ "status": "success" }`                  |
| `/data`   | GET    | Get sensor readings            | `{ "temp": 23, "hum": 45 }`                |
| `/led`    | POST   | Control LED on/off             | `{ "status": "on" }`                        |

---
# Installition
```bash
sudo apt update
sudo apt install python3-pip python3-flask python3-rpi.gpio
pip3 install adafruit-circuitpython-dht
python3 server-dashboard.py
```
Visit on this url 
```Url
http://<raspberry-pi-ip>:5000
```
