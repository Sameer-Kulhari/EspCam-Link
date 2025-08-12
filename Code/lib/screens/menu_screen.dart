import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class MenuScreen extends StatefulWidget {
  const MenuScreen({Key? key}) : super(key: key);

  @override
  _MenuScreenState createState() => _MenuScreenState();
}

class DeviceEntry {
  String name;
  String ip;
  String port;

  DeviceEntry({required this.name, required this.ip, required this.port});

  Map<String, dynamic> toJson() => {
        'name': name,
        'ip': ip,
        'port': port,
      };

  factory DeviceEntry.fromJson(Map<String, dynamic> json) => DeviceEntry(
        name: json['name'],
        ip: json['ip'],
        port: json['port'],
      );
}

class _MenuScreenState extends State<MenuScreen> {
  List<DeviceEntry> _entries = [];

  @override
  void initState() {
    super.initState();
    _loadEntries();
  }

  Future<void> _loadEntries() async {
    final prefs = await SharedPreferences.getInstance();
    final String? entriesString = prefs.getString('device_entries');
    if (entriesString != null) {
      List<dynamic> jsonList = jsonDecode(entriesString);
      setState(() {
        _entries = jsonList
            .map((json) => DeviceEntry.fromJson(json as Map<String, dynamic>))
            .toList();
      });
    }
  }

  Future<void> _saveEntries() async {
    final prefs = await SharedPreferences.getInstance();
    final String jsonString =
        jsonEncode(_entries.map((e) => e.toJson()).toList());
    await prefs.setString('device_entries', jsonString);
  }

  void _showAddEditDialog({DeviceEntry? entry, int? index}) {
    final nameController = TextEditingController(text: entry?.name ?? '');
    final ipController = TextEditingController(text: entry?.ip ?? '');
    final portController = TextEditingController(text: entry?.port ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(entry == null ? 'Add Entry' : 'Edit Entry'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Entry Name'),
              ),
              TextField(
                controller: ipController,
                decoration: const InputDecoration(labelText: 'IP Address'),
                keyboardType: TextInputType.url,
              ),
              TextField(
                controller: portController,
                decoration: const InputDecoration(labelText: 'Port Number'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final newName = nameController.text.trim();
              final newIp = ipController.text.trim();
              final newPort = portController.text.trim();

              if (newName.isEmpty ||
                  newIp.isEmpty ||
                  newPort.isEmpty ||
                  int.tryParse(newPort) == null) {
                // Show simple error dialog
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Invalid Input'),
                    content: const Text(
                        'Please enter a valid name, IP address, and port number.'),
                    actions: [
                      TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('OK'))
                    ],
                  ),
                );
                return;
              }

              setState(() {
                final newEntry =
                    DeviceEntry(name: newName, ip: newIp, port: newPort);
                if (entry != null && index != null) {
                  _entries[index] = newEntry;
                } else {
                  _entries.add(newEntry);
                }
              });
              _saveEntries();
              Navigator.pop(context);
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _deleteEntry(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: const Text('Are you sure you want to delete this entry?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _entries.removeAt(index);
              });
              _saveEntries();
              Navigator.pop(context);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _startSession(DeviceEntry entry) {
    Navigator.pushNamed(context, '/session_login', arguments: entry);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('EspCamLink'),
      ),
      body: _entries.isEmpty
          ? const Center(child: Text('No entries yet. Add one below.'))
          : ListView.builder(
              itemCount: _entries.length,
              itemBuilder: (context, index) {
                final entry = _entries[index];
                return Card(
                  margin:
                      const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                  child: ListTile(
                    title: Text(entry.name),
                    subtitle: Text('${entry.ip}:${entry.port}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ElevatedButton(
                          onPressed: () => _startSession(entry),
                          child: const Text('Start'),
                        ),
                        PopupMenuButton<String>(
                          onSelected: (value) {
                            if (value == 'edit') {
                              _showAddEditDialog(entry: entry, index: index);
                            } else if (value == 'delete') {
                              _deleteEntry(index);
                            }
                          },
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: 'edit',
                              child: Text('Edit'),
                            ),
                            const PopupMenuItem(
                              value: 'delete',
                              child: Text('Delete'),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddEditDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
