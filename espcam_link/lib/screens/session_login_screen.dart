import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'menu_screen.dart'; // For DeviceEntry

class SessionLoginScreen extends StatefulWidget {
  const SessionLoginScreen({Key? key}) : super(key: key);

  @override
  _SessionLoginScreenState createState() => _SessionLoginScreenState();
}

class _SessionLoginScreenState extends State<SessionLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  String username = '';
  String password = '';
  bool _isLoading = false;
  String? _error;

  late DeviceEntry entry;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    entry = ModalRoute.of(context)!.settings.arguments as DeviceEntry;
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    // Replace with your server login URL and logic
    final loginUrl = 'http://${entry.ip}:${entry.port}/login';

    try {
      // Example: POST with username & password
      final response = await http.post(
        Uri.parse(loginUrl),
        body: {'username': username, 'password': password},
      );

      if (response.statusCode == 200) {
        // Success: Navigate to session screen with credentials if needed
        Navigator.pushReplacementNamed(
          context,
          '/session',
          arguments: {
            'entry': entry,
            'username': username,
            'password': password,
          },
        );
      } else {
        setState(() {
          _error = 'Invalid username or password';
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Failed to connect to server';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login to ${entry.name}'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              if (_error != null) ...[
                Text(_error!, style: const TextStyle(color: Colors.red)),
                const SizedBox(height: 12),
              ],
              TextFormField(
                decoration: const InputDecoration(labelText: 'Username'),
                onChanged: (val) => username = val.trim(),
                validator: (val) =>
                    val == null || val.isEmpty ? 'Enter username' : null,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
                onChanged: (val) => password = val.trim(),
                validator: (val) =>
                    val == null || val.isEmpty ? 'Enter password' : null,
              ),
              const SizedBox(height: 20),
              _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _login,
                      child: const Text('Login'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
