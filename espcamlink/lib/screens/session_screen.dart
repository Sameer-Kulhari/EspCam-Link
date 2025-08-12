import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'menu_screen.dart';  // For DeviceEntry class

class SessionScreen extends StatefulWidget {
  const SessionScreen({Key? key}) : super(key: key);

  @override
  _SessionScreenState createState() => _SessionScreenState();
}

class _SessionScreenState extends State<SessionScreen> {
  late DeviceEntry entry;
  late String username;
  late String password;

  int _currentIndex = 0;
  bool ledOn = false;
  double temperature = 0.0;
  double humidity = 0.0;
  Timer? _timer;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

    entry = args['entry'] as DeviceEntry;
    username = args['username'] as String;
    password = args['password'] as String;

    _fetchStatus();
    _timer = Timer.periodic(const Duration(seconds: 2), (_) => _fetchStatus());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String get baseUrl => 'http://${entry.ip}:${entry.port}';

  Map<String, String> get authHeaders => {
        'Authorization':
            'Basic ${base64Encode(utf8.encode('$username:$password'))}',
      };

  Future<void> _fetchStatus() async {
    try {
      final ledRes = await http.get(
        Uri.parse('$baseUrl/led/status'),
        headers: authHeaders,
      );
      final sensorRes = await http.get(
        Uri.parse('$baseUrl/sensor'),
        headers: authHeaders,
      );

      if (ledRes.statusCode == 200 && sensorRes.statusCode == 200) {
        final ledJson = jsonDecode(ledRes.body);
        final sensorJson = jsonDecode(sensorRes.body);

        setState(() {
          ledOn = ledJson['led'] == 'on';
          temperature = (sensorJson['temperature'] ?? 0).toDouble();
          humidity = (sensorJson['humidity'] ?? 0).toDouble();
        });
      }
    } catch (e) {
      // Optionally handle errors
    }
  }

  Future<void> _toggleLed(bool turnOn) async {
    final url = turnOn ? '$baseUrl/led/on' : '$baseUrl/led/off';

    try {
      final res = await http.post(Uri.parse(url), headers: authHeaders);
      if (res.statusCode == 200) {
        setState(() {
          ledOn = turnOn;
        });
      }
    } catch (e) {
      // Handle errors
    }
  }

  void _exitSession() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Exit Session'),
        content: const Text('Are you sure you want to exit this session?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.popUntil(context, ModalRoute.withName('/menu'));
            },
            child: const Text('Exit'),
          ),
        ],
      ),
    );
  }

  Widget _buildCameraTab() {
    final streamUrl = 'http://${entry.ip}:${entry.port}/stream';

    return Center(
      child: Image.network(
        streamUrl,
        gaplessPlayback: true,
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return const Center(child: CircularProgressIndicator());
        },
        errorBuilder: (context, error, stackTrace) {
          return const Center(child: Text('Failed to load video stream'));
        },
        fit: BoxFit.contain,
      ),
    );
  }

  Widget _buildIotDashboardTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          SwitchListTile(
            title: const Text('LED Control'),
            subtitle: Text(ledOn ? 'On' : 'Off'),
            activeColor: Colors.green,
            inactiveThumbColor: Colors.red,
            value: ledOn,
            onChanged: (val) {
              _toggleLed(val);
            },
          ),
          const SizedBox(height: 20),
          Text(
            'Temperature: ${temperature.toStringAsFixed(1)} °C',
            style: const TextStyle(fontSize: 18),
          ),
          const SizedBox(height: 10),
          Text(
            'Humidity: ${humidity.toStringAsFixed(1)} %',
            style: const TextStyle(fontSize: 18),
          ),
        ],
      ),
    );
  }

  Widget _buildExitTab() {
    return Center(
      child: ElevatedButton(
        onPressed: _exitSession,
        child: const Text('Exit Session'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tabs = [
      _buildCameraTab(),
      _buildIotDashboardTab(),
      _buildExitTab(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('Session: ${entry.name}'),
      ),
      body: tabs[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.videocam),
            label: 'Camera',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'IoT Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.exit_to_app),
            label: 'Exit',
          ),
        ],
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}
