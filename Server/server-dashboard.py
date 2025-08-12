from flask import Flask, render_template_string, request, redirect, url_for, session
import RPi.GPIO as GPIO
import Adafruit_DHT
import threading
import time

app = Flask(__name__)
app.secret_key = "supersecretkey"  # Change this!

# GPIO setup
LED_PIN = 17
DHT_SENSOR = Adafruit_DHT.DHT11
DHT_PIN = 4

GPIO.setwarnings(False)
GPIO.setmode(GPIO.BCM)
GPIO.setup(LED_PIN, GPIO.OUT)

# Shared sensor data
sensor_data = {"temp": None, "hum": None}

# Hardcoded login
USERNAME = "admin"
PASSWORD = "1234"

# Background thread to read DHT11 every 2 seconds
def read_dht11():
    while True:
        hum, temp = Adafruit_DHT.read(DHT_SENSOR, DHT_PIN)
        if hum is not None and temp is not None:
            sensor_data["temp"] = round(temp, 1)
            sensor_data["hum"] = round(hum, 1)
        time.sleep(2)

threading.Thread(target=read_dht11, daemon=True).start()

@app.route("/", methods=["GET", "POST"])
def login():
    if session.get("logged_in"):
        return redirect(url_for("dashboard"))

    error = None
    if request.method == "POST":
        user = request.form.get("username")
        pw = request.form.get("password")
        if user == USERNAME and pw == PASSWORD:
            session["logged_in"] = True
            return redirect(url_for("dashboard"))
        else:
            error = "Invalid username or password"
    return render_template_string("""
    <!DOCTYPE html>
    <html>
    <head>
      <title>Login</title>
      <script src="https://cdn.tailwindcss.com"></script>
    </head>
    <body class="bg-gray-900 text-white flex items-center justify-center min-h-screen">
      <form method="POST" class="bg-gray-800 p-8 rounded-lg shadow-lg w-80">
        <h2 class="text-2xl mb-6 text-center font-semibold">Login</h2>
        <input name="username" placeholder="Username" required class="w-full p-2 mb-4 rounded bg-gray-700 text-white"/>
        <input name="password" type="password" placeholder="Password" required class="w-full p-2 mb-6 rounded bg-gray-700 text-white"/>
        {% if error %}
          <p class="text-red-400 mb-4">{{ error }}</p>
        {% endif %}
        <button type="submit" class="w-full bg-blue-600 hover:bg-blue-700 p-2 rounded">Login</button>
      </form>
    </body>
    </html>
    """, error=error)

@app.route("/dashboard")
def dashboard():
    if not session.get("logged_in"):
        return redirect(url_for("login"))
    led_state = GPIO.input(LED_PIN) == GPIO.HIGH
    return render_template_string("""
    <!DOCTYPE html>
    <html>
    <head>
      <title>Simple IoT Dashboard</title>
      <script src="https://cdn.tailwindcss.com"></script>
      <script>
        async function toggleLED() {
          const res = await fetch('/led/toggle', {method: 'POST'});
          const data = await res.json();
          const statusSpan = document.getElementById('led-status');
          statusSpan.textContent = data.state ? 'ON' : 'OFF';
          statusSpan.className = data.state ? 'text-green-400' : 'text-red-500';
          document.getElementById('led-btn').textContent = data.state ? 'Turn LED OFF' : 'Turn LED ON';
        }
        async function fetchSensorData() {
          const res = await fetch('/sensor');
          const data = await res.json();
          document.getElementById('temp').textContent = data.temp !== null ? data.temp + " °C" : "--";
          document.getElementById('hum').textContent = data.hum !== null ? data.hum + " %" : "--";
        }
        setInterval(fetchSensorData, 2000);
        window.onload = fetchSensorData;
      </script>
    </head>
    <body class="bg-gray-900 text-white min-h-screen flex flex-col items-center p-6">
      <h1 class="text-3xl mb-8 font-bold">Simple IoT Dashboard</h1>

      <div class="mb-6 w-full max-w-3xl">
        <iframe src="http://{{request.host.split(':')[0]}}:8080/?action=stream" class="w-full h-72 rounded-lg border-4 border-gray-700" style="object-fit: cover;"></iframe>
      </div>

      <div class="flex flex-col md:flex-row gap-12 items-center mb-8">
        <div class="bg-gray-800 p-6 rounded-lg shadow-lg flex flex-col items-center w-64">
          <button id="led-btn" onclick="toggleLED()" class="bg-red-600 hover:bg-red-700 px-6 py-3 rounded-lg shadow-lg mb-4 font-semibold text-lg w-full">
            {{ "Turn LED OFF" if led_state else "Turn LED ON" }}
          </button>
          <div class="text-xl">
            LED Status:
            <span id="led-status" class="{{ 'text-green-400' if led_state else 'text-red-500' }}">
              {{ "ON" if led_state else "OFF" }}
            </span>
          </div>
        </div>

        <div class="bg-gray-800 p-6 rounded-lg shadow-lg w-64 text-center">
          <h2 class="text-xl mb-4 font-semibold">Environment</h2>
          <p class="text-lg mb-2">Temperature: <span id="temp">--</span></p>
          <p class="text-lg">Humidity: <span id="hum">--</span></p>
        </div>
      </div>

      <div>
        <a href="/logout" class="text-red-500 hover:text-red-700 font-semibold">Logout</a>
      </div>
    </body>
    </html>
    """, led_state=led_state)

@app.route("/led/toggle", methods=["POST"])
def led_toggle():
    current = GPIO.input(LED_PIN)
    GPIO.output(LED_PIN, GPIO.LOW if current else GPIO.HIGH)
    return {"state": GPIO.input(LED_PIN) == GPIO.HIGH}

@app.route("/sensor")
def sensor():
    return {"temp": sensor_data["temp"], "hum": sensor_data["hum"]}

@app.route("/logout")
def logout():
    session.clear()
    return redirect(url_for("login"))

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
